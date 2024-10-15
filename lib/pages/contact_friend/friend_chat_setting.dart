import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/message.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/db.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';
import 'package:qim/common/widget/dialog_confirm.dart';

class FriendSettingChat extends StatefulWidget {
  const FriendSettingChat({super.key});

  @override
  State<FriendSettingChat> createState() => _FriendSettingChatState();
}

class _FriendSettingChatState extends State<FriendSettingChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("聊天设置"),
      ),
      body: const FriendSettingChatPage(),
    );
  }
}

class FriendSettingChatPage extends StatefulWidget {
  const FriendSettingChatPage({super.key});

  @override
  State<FriendSettingChatPage> createState() => _FriendSettingChatPageState();
}

class _FriendSettingChatPageState extends State<FriendSettingChatPage> {
  final TalkobjController talkobjController = Get.find();
  final MessageController messageController = Get.find();
  final ChatController chatController = Get.find();
  final UserController userController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final UserInfoController userInfoController = Get.find();

  Map talkObj = {};
  int uid = 0;
  Map userInfo = {};

  Map userObj = {};
  Map contactFriendObj = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    _initData();
  }

  void _initData() async {
    await initOneUser(talkObj['objId']);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (talkObj.isEmpty) {
          return const Center(child: Text(""));
        }
        userObj = userController.getOneUser(talkObj['objId']);
        if (userObj.isEmpty) {
          return const Center(child: Text(""));
        }
        contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
        String textObj = "";
        if (contactFriendObj.isNotEmpty && contactFriendObj['joinTime'] > 0) {
          textObj = contactFriendObj['remark'] != '' ? contactFriendObj['remark'] : userObj['nickname'];
        } else {
          textObj = "${userObj['nickname']}(临时聊天)";
        }

        return ListView(
          children: [
            ListTile(
              title: Text(textObj),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(userObj['avatar'] ?? ''),
              ),
              onTap: () {
                Map talkobj = {
                  "objId": talkObj['objId'],
                  "type": 1,
                };
                Navigator.pushNamed(
                  context,
                  '/friend-detail',
                  arguments: talkobj,
                );
              },
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: const Divider(),
            ),
            ListTile(
              title: const Text('查找聊天记录'),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('图片、视频、文件'),
                  Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {},
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: const Divider(),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              title: const Text("设为置顶"),
              trailing: Switch(
                value: contactFriendObj['isTop'] == 1 ? true : false,
                onChanged: (bool val) {
                  int v = val == true ? 1 : 0;
                  _actContact('isTop', v);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: const Divider(),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              title: const Text("隐藏会话"),
              trailing: Switch(
                value: contactFriendObj['isHidden'] == 1 ? true : false,
                onChanged: (bool val) {
                  int v = val == true ? 1 : 0;
                  _actContact('isHidden', v);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: const Divider(),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              title: const Text("消息免打扰"),
              trailing: Switch(
                value: contactFriendObj['isQuiet'] == 1 ? true : false,
                onChanged: (bool val) {
                  int v = val == true ? 1 : 0;
                  _actContact('isQuiet', v);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: const Divider(),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              title: const Text("删除聊天记录"),
              onTap: _delMessage,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: const Divider(),
            ),
            talkObj['objId'] != uid && contactFriendObj.isNotEmpty && contactFriendObj['joinTime'] > 0
                ? Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomButton(
                          onPressed: () {
                            _delContact();
                          },
                          text: "删除好友",
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  )
                : Container(),
            talkObj['objId'] != uid
                ? TextButton(
                    onPressed: () {},
                    child: const Text(
                      '被骚扰了？举报该用户',
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }

  void _delMessage() {
    showCustomDialog(
      context: context,
      content: Text(
        '确定要删除和${userObj['nickname'] ?? ''}的聊天记录吗？',
        style: const TextStyle(fontSize: 18),
      ),
      onConfirm: () async {
        await DBHelper.deleteData('message', [
          ['msgType', '=', talkObj['type']],
          ['toId', '=', talkObj['objId']],
          ['fromId', '=', uid]
        ]);
        await DBHelper.deleteData('message', [
          ['msgType', '=', talkObj['type']],
          ['toId', '=', uid],
          ['fromId', '=', talkObj['objId']]
        ]);
        messageController.delMessage(talkObj['type'], uid, talkObj['objId']);
        TipHelper.instance.showToast("删除成功");
      },
      onConfirmText: "清空",
      onCancel: () {
        // 处理取消逻辑
      },
      onCancelText: "取消",
    );
  }

  void _actContact(String field, int value) {
    var params = {
      'fromId': uid,
      'toId': talkObj['objId'],
      field: value,
    };
    ContactFriendApi.actContactFriend(params, onSuccess: (res) {
      if (!mounted) return;
      setState(() {
        contactFriendObj[field] = res['data'][field];
        contactFriendController.upsetContactFriend(res['data']);
        saveDbContactFriend(res['data']);

        if (["isTop", "isHidden", "isQuiet"].contains(field)) {
          Map chat = chatController.getOneChat(talkObj['objId'], 1);
          if (chat.isNotEmpty) {
            Map chatData = {};
            chatData['objId'] = talkObj['objId'];
            chatData['type'] = 1;
            chatData[field] = res['data'][field];
            chatController.upsetChat(chatData);
            saveDbChat(chatData);
          }
        }
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  void _delContact() {
    showCustomDialog(
      context: context,
      content: const Text(
        '确定要删除该好友吗？删除后将清理聊天记录。',
        style: TextStyle(fontSize: 18),
      ),
      onConfirm: () async {
        var params = {
          'fromId': uid,
          'toId': talkObj['objId'],
        };
        ContactFriendApi.delContactFriend(params, onSuccess: (res) {
          talkobjController.setTalkObj({});
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            ModalRoute.withName('/'),
          );
        }, onError: (res) {
          TipHelper.instance.showToast(res['msg']);
        });
      },
      onConfirmText: "确定",
      onCancel: () {
        // 处理取消逻辑
      },
      onCancelText: "取消",
    );
  }
}
