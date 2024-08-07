import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact_friend.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/functions.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';
import 'package:qim/widget/dialog_confirm.dart';

class UserSettingChat extends StatefulWidget {
  const UserSettingChat({super.key});

  @override
  State<UserSettingChat> createState() => _UserSettingChatState();
}

class _UserSettingChatState extends State<UserSettingChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("聊天设置"),
        backgroundColor: Colors.grey[100],
      ),
      body: const UserSettingChatPage(),
    );
  }
}

class UserSettingChatPage extends StatefulWidget {
  const UserSettingChatPage({super.key});

  @override
  State<UserSettingChatPage> createState() => _UserSettingChatPageState();
}

class _UserSettingChatPageState extends State<UserSettingChatPage> {
  final TalkobjController talkobjController = Get.find();
  final UserController userController = Get.find();
  final MessageController messageController = Get.find();

  Map talkObj = {};
  Map userObj = {};
  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    talkObj = talkobjController.talkObj;
    userObj = userController.getOneUser(talkObj['objId'])!;
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(userObj['username'] ?? ''),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userObj['avatar'] ?? ''),
          ),
          trailing: const Icon(
            Icons.chevron_right,
          ),
          onTap: () {},
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
            value: userObj['isTop'] == 1 ? true : false,
            onChanged: (bool value) {
              actContactFriend('isTop', value as int);
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
            value: userObj['isHidden'] == 1 ? true : false,
            onChanged: (bool value) {
              actContactFriend('isHidden', value as int);
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
            value: userObj['isQuiet'] == 1 ? true : false,
            onChanged: (bool value) {
              actContactFriend('isQuiet', value as int);
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
                onPressed: () {},
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
      content: '确定要删除和${userObj['username'] ?? ''}的聊天记录吗？',
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

  void actContactFriend(String field, int value) {
    var params = {
      'fromId': uid,
      'toId': talkObj['objId'],
      field: value,
    };
    ContactFriendApi.actContactFriend(params, onSuccess: (res) {
      logPrint(res);
      setState(() {
        // _groupUsers = res['data'];
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
