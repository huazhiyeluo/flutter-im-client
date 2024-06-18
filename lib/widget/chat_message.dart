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
        // 初始化 WebSocket 监听
        messageController.allUserMessages[key]?.listen((message) {
          _scrollToBottom();
        });
        return Container(
          color: Colors.grey[200], // 设置背景色
          child: ListView.builder(
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
          ),
        );
      },
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
    if (data['msgMedia'] == 2) {
      item = Image.network(data['content']['url']);
    }
    if (data['msgMedia'] == 6) {
      item = Image.asset(data['content']['url']);
    }
    return item;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
