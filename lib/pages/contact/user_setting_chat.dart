import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/widget/custom_button.dart';

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

  Map talkObj = {};
  Map userObj = {};

  @override
  void initState() {
    talkObj = talkobjController.talkObj;
    userObj = userController.getOneUser(talkObj['objId'])!;
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
            value: true,
            onChanged: (bool value) {},
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
            value: true,
            onChanged: (bool value) {},
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
            value: true,
            onChanged: (bool value) {},
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          title: Text("删除聊天记录"),
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
}
