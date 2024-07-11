import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/date.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/functions.dart';

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

  final ScrollController _scrollController = ScrollController();

  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};
  String key = "";

  @override
  void initState() {
    super.initState();
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    talkObj = talkobjController.talkObj;
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
      final List<Map<dynamic, dynamic>> messageList = messageController.allUserMessages[key]!;
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
                  !isSentByMe ? _showRightPhoto(messageList, index) : Container(),
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width * 0.1,
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                      ),
                      decoration: BoxDecoration(
                        color: isSentByMe ? const Color.fromARGB(255, 169, 234, 122) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _getContent(isSentByMe, messageList[index]),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(messageList[index]['createTime'], customFormat: "MM-dd HH:mm"),
                            style: TextStyle(
                              fontSize: 13,
                              color: isSentByMe ? Colors.black54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  isSentByMe ? _showLeftPhoto(messageList, index) : Container(),
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

  Padding _showLeftPhoto(List<Map<dynamic, dynamic>> messageList, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: CircleAvatar(
        // 聊天对象的头像
        radius: 25,
        backgroundImage: NetworkImage(messageList[index]['avatar']),
      ),
    );
  }

  Padding _showRightPhoto(List<Map<dynamic, dynamic>> messageList, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        // 聊天对象的头像
        radius: 25,
        backgroundImage: NetworkImage(messageList[index]['avatar']),
      ),
    );
  }

  Widget _getContent(bool isSentByMe, Map data) {
    Widget item = const Text("");
    if ([1, 10, 11, 12, 13].contains(data['msgMedia'])) {
      item = Text(
        '${data['content']['data'] ?? ''}',
        style: TextStyle(
          fontSize: 16,
          color: isSentByMe ? Colors.black54 : Colors.black54,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      );
    }
    if ([12].contains(data['msgMedia'])) {
      item = Text(
        formatSecondsToHMS(int.parse(data['content']['data'])),
        style: TextStyle(
          fontSize: 16,
          color: isSentByMe ? Colors.black54 : Colors.black54,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      );
    }
    if (data['msgMedia'] == 6) {
      item = Image.asset(data['content']['url']);
    }
    if (data['msgMedia'] == 5) {
      item = Image.network(data['content']['url']);
    }

    return item;
  }

  Future<void> _getMessageList() async {
    final messagesList = messageController.allUserMessages[key];
    if (messagesList == null || messagesList.isEmpty) {
      List messages = await DBHelper.getData('message', [
        ['toId', '=', uid]
      ]);
      logPrint(messages);
      for (var item in messages) {
        Map<String, dynamic> modifiedItem = Map.from(item); // 复制到新的Map
        modifiedItem['content'] = jsonDecode(item['content']); // 修改新的Map中的内容
        messageController.addMessage(modifiedItem);
      }
    }
  }
}
