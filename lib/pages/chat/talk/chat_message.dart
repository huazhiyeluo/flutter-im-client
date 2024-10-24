import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/common/widget/play_audio_manager.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/controller/message.dart';
import 'package:qim/data/controller/talk.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/del.dart';
import 'package:qim/common/utils/common.dart';
import 'package:qim/common/utils/date.dart';
import 'package:qim/common/utils/db.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:qim/common/widget/play_audio.dart';
import 'package:qim/common/widget/play_video.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class AudioPlayerManager {
  static final Map<String, AudioManager> _controllers = {};

  static AudioManager getController(String audioUrl) {
    if (!_controllers.containsKey(audioUrl)) {
      AudioManager audioManager = AudioManager();
      audioManager.setAudioSource(audioUrl);
      _controllers[audioUrl] = audioManager;
    }
    return _controllers[audioUrl]!;
  }

  static void disposeAll() {
    for (var controller in _controllers.values) {
      controller.disposeA();
    }
    _controllers.clear();
  }
}

class VideoPlayerManager {
  static final Map<String, ChewieController> _controllers = {};

  static ChewieController getController(String videoUrl) {
    if (!_controllers.containsKey(videoUrl)) {
      VideoPlayerController videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _controllers[videoUrl] = ChewieController(
        videoPlayerController: videoPlayerController,
        autoInitialize: true,
        showControlsOnInitialize: false,
        autoPlay: false,
        aspectRatio: 16 / 9,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
    }
    return _controllers[videoUrl]!;
  }

  static void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    super.key,
  });
  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  final MessageController messageController = Get.find();
  final TalkController talkController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final ScrollController _scrollController = ScrollController();

  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};
  String key = "";

  @override
  void initState() {
    logPrint("ChatMessage-initState");
    super.initState();
    talkObj = talkController.talkObj;
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    key = getKey(msgType: talkObj['type'], fromId: uid, toId: talkObj['objId']);
    logPrint("ChatMessage-$key");
    _initData();
  }

  _initData() async {
    await _getMessageList();
  }

  @override
  void dispose() {
    logPrint("ChatMessage-dispose");
    super.dispose();
    _scrollController.dispose();
    AudioPlayerManager.disposeAll();
    VideoPlayerManager.disposeAll();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final RxList<Map>? messageList = messageController.allUserMessages[key];
      if (messageList == null) {
        return const Text("");
      }
      return Container(
        color: Colors.grey[200],
        child: ListView.builder(
          key: UniqueKey(),
          controller: _scrollController,
          reverse: true,
          itemCount: messageList.length,
          dragStartBehavior: DragStartBehavior.start,
          itemBuilder: (BuildContext context, int index) {
            bool isSentByMe = uid == messageList[index]['fromId'];
            return Container(
              margin: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _showLeft(isSentByMe, messageList[index]),
                  Flexible(
                    child: _showCenter(isSentByMe, messageList[index]),
                  ),
                  _showRight(isSentByMe, messageList[index]),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _showLeft(bool isSentByMe, Map msg) {
    return !isSentByMe
        ? Padding(
            padding: const EdgeInsets.only(left: 2.0, top: 10),
            child: GestureDetector(
              onTap: () {
                Map talkObj = {
                  "objId": msg['fromId'],
                  "type": ObjectTypes.user,
                };
                Navigator.pushNamed(
                  context,
                  '/friend-detail',
                  arguments: talkObj,
                );
              },
              child: CircleAvatar(
                radius: 24,
                backgroundImage: CachedNetworkImageProvider(msg['avatar']),
              ),
            ),
          )
        : Container();
  }

  Widget _showRight(bool isSentByMe, Map msg) {
    return isSentByMe
        ? Padding(
            padding: const EdgeInsets.only(right: 2.0, top: 10),
            child: GestureDetector(
              onTap: () {
                Map talkObj = {
                  "objId": uid,
                  "type": ObjectTypes.user,
                };
                Navigator.pushNamed(
                  context,
                  '/friend-detail',
                  arguments: talkObj,
                );
              },
              child: CircleAvatar(
                radius: 24,
                backgroundImage: CachedNetworkImageProvider(msg['avatar']),
              ),
            ),
          )
        : Container();
  }

  Widget _showCenter(bool isSentByMe, Map msg) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.1,
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: GestureDetector(
        onLongPressStart: (LongPressStartDetails details) {
          _loadData(msg, details);
        },
        child: Column(
          crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: _getContentAll(isSentByMe, msg),
        ),
      ),
    );
  }

  List<Widget> _getContentAll(bool isSentByMe, Map msg) {
    List<Widget> lists = [];
    if (msg['msgType'] == ObjectTypes.group) {
      lists.add(Text(
        msg['nickname'],
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[550],
        ),
      ));
    } else {
      lists.add(const SizedBox(
        height: 4,
      ));
    }
    lists.add(const SizedBox(height: 4));
    lists.add(_getContent(isSentByMe, msg));
    lists.add(const SizedBox(height: 4));
    lists.add(Text(
      formatDate(msg['createTime'], customFormat: "MM-dd HH:mm"),
      style: TextStyle(
        fontSize: 13,
        color: isSentByMe ? Colors.black54 : Colors.black54,
      ),
    ));
    return lists;
  }

  Widget _getContent(bool isSentByMe, Map msg) {
    Widget item = const Text("");
    if ([
      AppWebsocket.msgMediaText,
      AppWebsocket.msgMediaNotOnline,
      AppWebsocket.msgMediaNoConnect,
      AppWebsocket.msgMediaOff,
    ].contains(msg['msgMedia'])) {
      Widget tempWidget = Text(
        '${msg['content']['data'] ?? ''}',
        style: TextStyle(
          fontSize: 16,
          color: isSentByMe ? Colors.black54 : Colors.black54,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      );
      item = _getContentSkin(isSentByMe, tempWidget);
    } else if ([AppWebsocket.msgMediaImage].contains(msg['msgMedia'])) {
      if (isImageFile(msg['content']['url'])) {
        item = GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return Scaffold(
                  body: SizedBox.expand(
                    child: PhotoView(
                      imageProvider: CachedNetworkImageProvider(
                        msg['content']['url'],
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
            imageUrl: msg['content']['url'],
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      } else {
        // item = Image.network(data['content']['url']);
      }
    } else if ([AppWebsocket.msgMediaAudio].contains(msg['msgMedia'])) {
      Widget tempWidget = Column(
        children: [
          Text(
            msg['content']['name'],
          ),
          PlayAudio(AudioPlayerManager.getController(msg['content']['url'])),
        ],
      );
      item = _getContentSkin(isSentByMe, tempWidget);
    } else if ([AppWebsocket.msgMediaVideo].contains(msg['msgMedia'])) {
      item = PlayVideo(VideoPlayerManager.getController(msg['content']['url']));
    } else if ([AppWebsocket.msgMediaFile].contains(msg['msgMedia'])) {
      item = InkWell(
        onTap: () {
          _launchUrl(msg['content']['url']);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            msg['content']['name'],
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    } else if ([AppWebsocket.msgMediaEmoji].contains(msg['msgMedia'])) {
      Widget tempWidget = Image.asset(msg['content']['url']);
      item = _getContentSkin(isSentByMe, tempWidget);
    } else if ([AppWebsocket.msgMediaTimes].contains(msg['msgMedia'])) {
      Widget tempWidget = Text(
        "通话时长：${formatSecondsToHMS(int.parse(msg['content']['data']))}",
        style: TextStyle(
          fontSize: 16,
          color: isSentByMe ? Colors.black54 : Colors.black54,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      );
      item = _getContentSkin(isSentByMe, tempWidget);
    } else if ([AppWebsocket.msgMediaInvite].contains(msg['msgMedia'])) {
      Map temp = json.decode(msg['content']['data']);
      Widget tempWidget = GestureDetector(
        onTap: () {
          !isSentByMe
              ? Navigator.pushNamed(
                  context,
                  '/group-join',
                  arguments: temp['group'],
                )
              : Navigator.pushNamed(
                  context,
                  '/group-join-show',
                  arguments: temp['group'],
                );
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
            const SizedBox(height: 4),
            Text('"${msg['nickname']}"邀请你加入群里群聊"${temp['group']['name']}",进入可查看详情'),
          ],
        ),
      );
      item = _getContentSkin(isSentByMe, tempWidget);
    } else if ([AppWebsocket.msgMediaUser].contains(msg['msgMedia'])) {
      // 个人名片消息
      Map temp = json.decode(msg['content']['data']);
      item = GestureDetector(
        onTap: () {
          Map talkObj = {
            "objId": temp['user']['uid'],
            "type": ObjectTypes.user,
          };
          Navigator.pushNamed(context, '/friend-detail', arguments: talkObj);
        },
        child: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(
                    temp['user']['avatar'],
                  ),
                ),
                title: Text('${temp['user']['nickname']}'),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 5, 0, 5),
                child: Text(
                  "个人名片",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    } else if ([AppWebsocket.msgMediaGroup].contains(msg['msgMedia'])) {
      // 群名片消息
      Map temp = json.decode(msg['content']['data']);
      item = GestureDetector(
        onTap: () {
          Map talkObj = {
            "objId": temp['group']['groupId'],
            "type": ObjectTypes.group,
          };
          Navigator.pushNamed(context, '/group-detail', arguments: talkObj);
        },
        child: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(
                    temp['group']['icon'],
                  ),
                ),
                title: Text('${temp['group']['name']}'),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 5, 0, 5),
                child: Text(
                  "群聊名片",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return item;
  }

  Widget _getContentSkin(bool isSentByMe, Widget temp) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isSentByMe ? const Color.fromARGB(255, 168, 208, 128) : Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: temp,
    );
  }

  Future<void> _loadData(Map data, LongPressStartDetails details) async {
    final Offset position = details.globalPosition;

    // 弹出菜单
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, // 左边距离
        position.dy, // 顶部距离
        position.dx + 1, // 右边距离，通常 +1 即可
        position.dy + 1, // 底部距离，通常 +1 即可
      ),
      items: [
        const PopupMenuItem<int>(
          value: 1,
          child: Text('转发'),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text('复制'),
        ),
        const PopupMenuItem<int>(
          value: 3,
          child: Text('引用'),
        ),
        const PopupMenuItem<int>(
          value: 4,
          child: Text('删除'),
        ),
      ],
      elevation: 8.0,
    );

    // 处理菜单选项
    if (result != null) {
      if (result == 1) {
        Map msgObj = {'content': data['content'], 'msgMedia': data['msgMedia']};
        Get.toNamed(
          '/share',
          arguments: {"ttype": ShareTypes.single, "msgObj": msgObj},
        );
      }
      if (result == 2) {}
      if (result == 3) {}
      if (result == 4) {
        delDbMessageById(data['id']);
        messageController.delMessageById(data);
      }
    }
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

      if (talkObj['type'] == ObjectTypes.user) {
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

      if (talkObj['type'] == ObjectTypes.group) {
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
