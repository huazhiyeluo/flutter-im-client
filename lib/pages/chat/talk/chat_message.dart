import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/userinfo.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/date.dart';
import 'package:qim/utils/db.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:qim/widget/play_audio.dart';
import 'package:qim/widget/play_video.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    super.key,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  final MessageController messageController = Get.find();
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();

  final ScrollController _scrollController = ScrollController();

  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};
  String key = "";

  @override
  void initState() {
    super.initState();
    talkObj = talkobjController.talkObj;
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    key = getKey(msgType: talkObj['type'], fromId: uid, toId: talkObj['objId']);
    _initData();
  }

  _initData() async {
    await _getMessageList();
  }

  @override
  void dispose() {
    // 取消监听或处理数据
    _scrollController.dispose(); // 如果需要手动关闭流
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final RxList<Map>? messageList = messageController.allUserMessages[key];
      if (messageList == null) {
        return const Text("");
      }
      return Container(
        color: Colors.grey[200], // 设置背景色
        child: ListView.builder(
          key: UniqueKey(),
          controller: _scrollController,
          itemBuilder: (BuildContext context, int index) {
            bool isSentByMe = uid == messageList[index]['fromId'];
            return Container(
              margin: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !isSentByMe ? _showLeftPhoto(messageList, index) : Container(),
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width * 0.1,
                        maxWidth: MediaQuery.of(context).size.width * 0.65,
                      ),
                      decoration: BoxDecoration(
                        color: isSentByMe ? const Color.fromARGB(255, 169, 233, 123) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _getContentAll(isSentByMe, messageList[index]),
                      ),
                    ),
                  ),
                  isSentByMe ? _showRightPhoto(messageList, index) : Container(),
                ],
              ),
            );
          },
          reverse: true,
          itemCount: messageList.length,
          dragStartBehavior: DragStartBehavior.start,
        ),
      );
    });
  }

  List<Widget> _getContentAll(bool isSentByMe, Map data) {
    List<Widget> lists = [];

    if (data['msgType'] == 2) {
      lists.add(Text(
        data['nickname'],
        style: const TextStyle(
          fontSize: 13,
        ),
      ));
    } else {
      lists.add(const SizedBox(height: 4));
    }
    lists.add(const SizedBox(height: 4));
    lists.add(_getContent(isSentByMe, data));
    lists.add(Text(
      formatDate(data['createTime'], customFormat: "MM-dd HH:mm"),
      style: TextStyle(
        fontSize: 13,
        color: isSentByMe ? Colors.black54 : Colors.black54,
      ),
    ));
    return lists;
  }

  Padding _showLeftPhoto(List<Map<dynamic, dynamic>> messageList, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, top: 10),
      child: GestureDetector(
        onTap: () {
          Map talkobj = {
            "objId": messageList[index]['fromId'],
            "type": 1,
          };
          Navigator.pushNamed(
            context,
            '/friend-detail',
            arguments: talkobj,
          );
        },
        child: CircleAvatar(
          radius: 24,
          backgroundImage: CachedNetworkImageProvider(messageList[index]['avatar']),
        ),
      ),
    );
  }

  Padding _showRightPhoto(List<Map<dynamic, dynamic>> messageList, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 2.0, top: 10),
      child: GestureDetector(
        onTap: () {
          Map talkobj = {
            "objId": uid,
            "type": 1,
          };
          Navigator.pushNamed(
            context,
            '/friend-detail',
            arguments: talkobj,
          );
        },
        child: CircleAvatar(
          radius: 24,
          backgroundImage: CachedNetworkImageProvider(messageList[index]['avatar']),
        ),
      ),
    );
  }

  Widget _getContent(bool isSentByMe, Map data) {
    Widget item = const Text("");

    if ([1, 10, 11, 13].contains(data['msgMedia'])) {
      //1 文本  //10 不在线 //11 未接通  //13 挂断电话
      item = Text(
        '${data['content']['data'] ?? ''}',
        style: TextStyle(
          fontSize: 16,
          color: isSentByMe ? Colors.black54 : Colors.black54,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      );
    } else if (data['msgMedia'] == 2) {
      // 图片
      if (isImageFile(data['content']['url'])) {
        item = GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return Scaffold(
                  body: SizedBox.expand(
                    child: PhotoView(
                      imageProvider: CachedNetworkImageProvider(
                        data['content']['url'],
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: 3.0,
                      initialScale: PhotoViewComputedScale.contained,
                      enableRotation: true,
                      onTapUp: (c, f, s) => Navigator.of(context).pop(),
                      loadingBuilder: (context, event) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
            ));
          },
          child: CachedNetworkImage(
            imageUrl: data['content']['url'],
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      } else {
        // item = Image.network(data['content']['url']);
      }
    } else if (data['msgMedia'] == 3) {
      // 音频
      item = PlayAudio(data['content']['url']);
    } else if (data['msgMedia'] == 4) {
      // 视频
      item = PlayVideo(data['content']['url']);
    } else if (data['msgMedia'] == 5) {
      // 文件
      item = InkWell(
        onTap: () {
          _launchUrl(data['content']['url']);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            data['content']['name'],
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    } else if (data['msgMedia'] == 6) {
      // 表情
      item = Image.asset(data['content']['url']);
    } else if ([12].contains(data['msgMedia'])) {
      // 通话时长
      item = Text(
        "通话时长：${formatSecondsToHMS(int.parse(data['content']['data']))}",
        style: TextStyle(
          fontSize: 16,
          color: isSentByMe ? Colors.black54 : Colors.black54,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      );
    } else if ([21].contains(data['msgMedia'])) {
      Map temp = json.decode(data['content']['data']);
      // 邀请入群消息
      item = GestureDetector(
        onTap: () {
          !isSentByMe
              ? Navigator.pushNamed(context, '/group-join', arguments: temp['group'])
              : Navigator.pushNamed(context, '/group-join-show', arguments: temp['group']);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "邀请你加入群聊",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 17),
            ),
            Text('"${data['nickname']}"邀请你加入群里群聊"${temp['group']['name']}",进入可查看详情'),
          ],
        ),
      );
    }

    return item;
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _getMessageList() async {
    final messagesList = messageController.allUserMessages[key];
    if (messagesList == null || messagesList.isEmpty) {
      List messages = [];

      if (talkObj['type'] == 1) {
        List messages1 = await DBHelper.getData('message', [
          ['msgType', '=', talkObj['type']],
          ['toId', '=', talkObj['objId']],
          ['fromId', '=', uid]
        ]);
        List messages2 = await DBHelper.getData('message', [
          ['msgType', '=', talkObj['type']],
          ['toId', '=', uid],
          ['fromId', '=', talkObj['objId']]
        ]);

        messages = [...messages1, ...messages2];
        messages.sort((a, b) => a['createTime'].compareTo(b['createTime']));
      }

      if (talkObj['type'] == 2) {
        messages = await DBHelper.getData('message', [
          ['msgType', '=', talkObj['type']],
          ['toId', '=', talkObj['objId']]
        ]);
      }

      for (var item in messages) {
        Map<String, dynamic> modifiedItem = Map.from(item); // 复制到新的Map
        modifiedItem['content'] = jsonDecode(item['content']); // 修改新的Map中的内容
        messageController.addMessage(modifiedItem);
      }
    }
  }
}
