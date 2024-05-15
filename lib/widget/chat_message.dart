import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/date.dart';
import 'package:qim/utils/db.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    super.key,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  final ScrollController _scrollController = ScrollController();
  final MessageController messageController = Get.find();
  final TalkobjController talkobjController = Get.find();

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
    key = getKey(msgType: talkObj['type'], fromId: talkObj['objId'], toId: uid);

    _getMessageList().then((result) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (messageController.allUserMessages[key] != null) {
          _scrollToBottom();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        messageController.listenToMessages(key, onChange: () {
          _scrollToBottom();
        });
        return ListView.builder(
          key: UniqueKey(),
          controller: _scrollController,
          itemCount: messageController.allUserMessages[key]?.length,
          itemBuilder: (BuildContext context, int index) {
            final messageList = messageController.allUserMessages[key];
            if (messageList != null && index < messageList.length) {
              bool isSentByMe = uid == messageList[index]['fromId'];
              return Container(
                margin: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    !isSentByMe
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              // 聊天对象的头像
                              radius: 25,
                              backgroundImage: NetworkImage(messageList[index]['avatar']),
                            ),
                          )
                        : Container(),
                    Flexible(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width * 0.1,
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${messageList[index]['content']['data'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16,
                                color: isSentByMe ? Colors.white : Colors.black,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatDate(messageList[index]['createTime'], customFormat: "MM-dd HH:mm"),
                              style: TextStyle(
                                fontSize: 13,
                                color: isSentByMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    isSentByMe
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: CircleAvatar(
                              // 聊天对象的头像
                              radius: 25,
                              backgroundImage: NetworkImage(messageList[index]['avatar']),
                            ),
                          )
                        : Container(),
                  ],
                ),
              );
            } else {
              return const Text(""); // 返回一个空的SizedBox ,会有问题
            }
          },
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _getMessageList() async {
    if (messageController.allUserMessages.isEmpty) {
      List messages = await DBHelper.getData('message', []);
      for (var item in messages) {
        Map<String, dynamic> modifiedItem = Map.from(item); // 复制到新的Map
        modifiedItem['content'] = jsonDecode(item['content']); // 修改新的Map中的内容
        messageController.addMessage(modifiedItem);
      }
    }
  }
}
