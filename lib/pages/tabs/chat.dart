import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/dbdata/deldbdata.dart';
import 'package:qim/utils/date.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/dbdata/savedbdata.dart';
import 'package:qim/widget/custom_text_field.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Column(children: [
          AppBar(
            title: CustomTextField(
              controller: inputController,
              hintText: '搜索',
              expands: false,
              maxHeight: 40,
              minHeight: 40,
              onTap: () {
                // 处理点击事件的逻辑
              },
            ),
          ),
        ]),
      ),
      body: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TalkobjController talkobjController = Get.put(TalkobjController());
  final ChatController chatController = Get.put(ChatController());

  @override
  void initState() {
    super.initState();
    _getChatList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        itemCount: chatController.allChats.length,
        itemBuilder: (BuildContext context, int index) {
          var temp = chatController.allChats[index];
          double extentRatioTop = 2.0;
          String textTop = "置顶";
          int flexTop = 3;
          if (temp['weight'] == 1) {
            extentRatioTop = 2.2;
            textTop = '取消置顶';
            flexTop = 4;
          }

          return Slidable(
            key: const ValueKey(0),
            useTextDirection: false,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: extentRatioTop / 3,
              children: [
                CustomSlidableAction(
                  flex: flexTop,
                  onPressed: (slidCtx) {
                    Map chatData = {};
                    chatData['objId'] = temp['objId'];
                    chatData['type'] = temp['type'];
                    chatData['weight'] = 1 - temp['weight'];
                    chatController.upsetChat(chatData);
                    saveDbChat(chatData);
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 水平居中对齐
                    children: [
                      Text(
                        textTop,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
                CustomSlidableAction(
                  flex: 4,
                  onPressed: (slidCtx) {
                    Map chatData = {};
                    chatData['objId'] = temp['objId'];
                    chatData['type'] = temp['type'];
                    chatData['tips'] = 0;
                    chatController.upsetChat(chatData);
                    saveDbChat(chatData);
                  },
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 水平居中对齐
                    children: [
                      Text(
                        '标为已读',
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
                CustomSlidableAction(
                  flex: 3,
                  onPressed: (slidCtx) {
                    chatController.delChat(temp['objId'], temp['type']);
                    delDbChat(temp['objId'], temp['type']);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 水平居中对齐
                    children: [
                      Text(
                        '删除',
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  temp["icon"],
                ),
              ),
              title: Text(temp["name"]),
              subtitle: Text(_getContent(temp["msgMedia"], temp["content"])),
              trailing: Column(children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  _getDate(temp["operateTime"]),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  '${temp["tips"]}',
                  style: const TextStyle(fontSize: 15),
                ),
              ]),
              onTap: () {
                Map talkobj = {
                  "objId": temp["objId"],
                  "type": temp["type"],
                };
                talkobjController.setTalkObj(talkobj);

                Map chatData = {};
                chatData['objId'] = temp["objId"];
                chatData['type'] = temp["type"];
                chatData['tips'] = 0;
                chatController.upsetChat(chatData);
                saveDbChat(chatData);

                Navigator.pushNamed(
                  context,
                  '/talk',
                );
              },
            ),
          );
        },
      );
    });
  }

  _getChatList() async {
    if (chatController.allChats.isEmpty) {
      List chats = await DBHelper.getData('chats', []);

      for (var item in chats) {
        Map<String, dynamic> temp = Map.from(item);
        temp['content'] = jsonDecode(item['content']);
        chatController.upsetChat(temp);
      }
    }
  }

  String _getContent(int msgMedia, Map content) {
    if ([1, 10, 11, 13].contains(msgMedia)) {
      return content['data'];
    }
    if (msgMedia == 6) {
      return "[表情]";
    }

    if (msgMedia == 2) {
      return "[图片]";
    }

    if (msgMedia == 3) {
      return "[音频]";
    }

    if (msgMedia == 4) {
      return "[视频]";
    }

    if (msgMedia == 5) {
      return "[文件]";
    }

    if (msgMedia == 12) {
      return "通话时长: ${formatSecondsToHMS(int.parse(content['data']))}";
    }
    return "";
  }

  String _getDate(int createTime) {
    int nowtime = getTime();
    String today = formatDate(nowtime, customFormat: "yyyy-MM-dd");
    String mDay = formatDate(createTime, customFormat: "yyyy-MM-dd");
    if (today == mDay) {
      return formatDate(createTime, customFormat: "HH:mm");
    } else {
      return formatDate(createTime, customFormat: "MM-dd");
    }
  }
}
