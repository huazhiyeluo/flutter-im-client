import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact_friend.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/contact_friend.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/dbdata/savedbdata.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';
import 'package:qim/widget/dialog_confirm.dart';

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
        backgroundColor: Colors.grey[100],
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

  Map talkObj = {};
  int uid = 0;
  Map userInfo = {};

  Map userObj = {};
  Map contactFriendObj = {};

  @override
  void initState() {
    talkObj = talkobjController.talkObj;
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";

    userObj = userController.getOneUser(talkObj['objId'])!;
    contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId'])!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(contactFriendObj['remark'] != '' ? contactFriendObj['remark'] : userObj['username']),
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
          onTap: delMessage,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        Row(
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
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            '被骚扰了？举报该用户',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  void delMessage() {
    showCustomDialog(
      context: context,
      content: Text(
        '确定要删除和${userObj['username'] ?? ''}的聊天记录吗？',
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
          Map chatData = {};
          chatData['objId'] = talkObj['objId'];
          chatData['type'] = 1;
          chatData[field] = res['data'][field];
          chatController.upsetChat(chatData);
          saveDbChat(chatData);
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
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
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
