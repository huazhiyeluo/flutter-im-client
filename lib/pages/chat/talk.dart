import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/date.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/savedata.dart';
import 'package:qim/widget/chat_message.dart';
import 'package:qim/widget/custom_chat_text_field.dart';

class Talk extends StatefulWidget {
  const Talk({super.key});

  @override
  State<Talk> createState() => _TalkState();
}

class _TalkState extends State<Talk> {
  final TalkobjController talkobjController = Get.find();

  @override
  Widget build(BuildContext context) {
    Map? talkObj = talkobjController.talkObj;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to previous route
          },
        ),
        title: Row(
          children: [
            Obx(
              () => CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(talkObj['icon'] ?? ''),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Text(
                talkObj['remark'] ?? talkObj['name'],
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 更多选项的操作
              if (talkObj['type'] == 1) {
                Navigator.pushNamed(
                  context,
                  '/user',
                );
              } else if (talkObj['type'] == 2) {
                Navigator.pushNamed(
                  context,
                  '/group',
                );
              }
            },
          ),
        ],
        backgroundColor: Colors.grey[100],
      ),
      body: const TalkPage(),
    );
  }
}

class TalkPage extends StatefulWidget {
  const TalkPage({super.key});

  @override
  State<TalkPage> createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  final MessageController messageController = Get.find();
  final TalkobjController talkobjController = Get.find();
  final TextEditingController inputController = TextEditingController();
  final ChatController chatController = Get.put(ChatController());

  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};
  int isShowEmoji = 0;
  int isShowSend = 0;

  final List<String> emojis = [];

  @override
  void initState() {
    super.initState();
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    talkObj = talkobjController.talkObj;

    for (var i = 0; i <= 124; i++) {
      String temp = i < 10 ? '0$i' : '$i';
      emojis.add('lib/assets/emojis/$temp.gif');
    }
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 1,
          child: ChatMessage(),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10 - isShowEmoji * 10),
          color: const Color.fromARGB(255, 248, 248, 248),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: CustomChatTextField(
                        controller: inputController,
                        hintText: '输入消息...',
                        expands: true,
                        maxHeight: 200,
                        minHeight: 25,
                        onTap: () {
                          // 处理点击事件的逻辑
                        },
                        onChanged: (String text) {
                          int flag = 0;
                          if (text == '') {
                            flag = 0;
                          } else {
                            flag = 1;
                          }
                          setState(() {
                            isShowSend = flag;
                          });
                        }),
                  ),
                  SizedBox(
                    width: 31,
                    child: IconButton(
                      icon: const Icon(Icons.emoji_emotions),
                      iconSize: 35,
                      padding: const EdgeInsets.all(2),
                      onPressed: () {
                        setState(() {
                          isShowEmoji = 1 - isShowEmoji;
                        });
                      },
                    ),
                  ),
                  isShowSend == 0
                      ? SizedBox(
                          width: 31,
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            iconSize: 35,
                            padding: const EdgeInsets.all(2),
                            onPressed: () {},
                          ),
                        )
                      : SizedBox(
                          width: 31,
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            iconSize: 35,
                            padding: const EdgeInsets.all(2),
                            onPressed: () {
                              _send();
                            },
                          ),
                        ),
                ],
              );
            },
          ),
        ),
        isShowEmoji == 1
            ? Container(
                height: 350,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                color: const Color.fromARGB(255, 237, 237, 237),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    crossAxisSpacing: 10.0, // 列之间的间距
                    mainAxisSpacing: 0.0, // 行之间的间距
                    childAspectRatio: 1.2, // 宽高比
                  ),
                  itemCount: emojis.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        emojis[index],
                        scale: 0.75,
                      ),
                    );
                  },
                ),
              )
            : Container(),
      ],
    );
  }

  void _send() async {
    // 发送按钮的操作
    Map msg = {
      'fromId': uid,
      'toId': talkObj['objId'],
      'content': {"data": inputController.text, "url": "", "name": ""},
      'msgMedia': 1,
      'msgType': talkObj['type']
    };

    String jsonStr = jsonEncode(msg);
    Get.arguments['channel'].sendMessage(jsonStr);
    msg['createTime'] = getTime();
    msg['avatar'] = userInfo['avatar'];
    messageController.addMessage(msg);
    inputController.text = "";

    processReceivedMessage(uid, msg, chatController);

    saveMessage(msg);
  }
}
