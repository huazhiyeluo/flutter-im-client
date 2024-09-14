import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact_friend.dart';
import 'package:qim/api/contact_group.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/contact_group.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/contact_friend.dart';
import 'package:qim/controller/userinfo.dart';
import 'package:qim/dbdata/deldbdata.dart';
import 'package:qim/utils/date.dart';
import 'package:qim/dbdata/savedbdata.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_search_field.dart';

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
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          flexibleSpace: Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: CustomSearchField(
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
        ),
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
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final ChatController chatController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        itemCount: chatController.allShowChats.length,
        itemBuilder: (BuildContext context, int index) {
          var temp = chatController.allShowChats[index];
          double extentRatioTop = 2.0;
          String textTop = "置顶";
          int flexTop = 3;
          if (temp['isTop'] == 1) {
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
                  padding: EdgeInsets.zero,
                  flex: flexTop,
                  onPressed: (slidCtx) {
                    _setTop(temp);
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
            child: Container(
              padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: const Border(
                  bottom: BorderSide(color: Color.fromARGB(255, 203, 201, 201), width: 1.0),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(temp["icon"]),
                    ),
                    title: Text(temp["remark"] != '' ? temp["remark"] : temp["name"]),
                    subtitle: Text(
                      _getContent(temp["msgMedia"], temp["content"]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        getSpecialDate(temp["operateTime"]),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 3),
                      temp['isQuiet'] == 1
                          ? const Icon(Icons.notifications_off_outlined)
                          : Container(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              decoration: BoxDecoration(
                                color: temp["type"] == 1 ? Colors.red[200] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${temp["tips"]}',
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              )),
                    ]),
                    onTap: () {
                      Map talkObj = {
                        "objId": temp["objId"],
                        "type": temp["type"],
                      };
                      talkobjController.setTalkObj(talkObj);

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
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _setTop(Map temp) {
    Map chatData = {};
    chatData['objId'] = temp['objId'];
    chatData['type'] = temp['type'];
    chatData['isTop'] = 1 - temp['isTop'];
    chatController.upsetChat(chatData);
    saveDbChat(chatData);
    _actContact(temp['objId'], 'isTop', chatData['isTop'], temp['type']);
  }

  void _actContact(int toId, String field, int value, int type) {
    var params = {
      'fromId': uid,
      'toId': toId,
      field: value,
    };
    if (type == 1) {
      ContactFriendApi.actContactFriend(params, onSuccess: (res) {
        contactFriendController.upsetContactFriend(res['data']);
        saveDbContactFriend(res['data']);
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    }
    if (type == 2) {
      ContactGroupApi.actContactGroup(params, onSuccess: (res) {
        contactGroupController.upsetContactGroup(res['data']);
        saveDbContactGroup(res['data']);
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    }
  }

  String _getContent(int msgMedia, Map content) {
    if ([1, 10, 11, 13].contains(msgMedia)) {
      return content['data'];
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

    if (msgMedia == 6) {
      return "[表情]";
    }

    if (msgMedia == 12) {
      return "通话时长: ${formatSecondsToHMS(int.parse(content['data']))}";
    }
    if (msgMedia == 21) {
      return "邀请你加入群聊";
    }

    return "";
  }
}
