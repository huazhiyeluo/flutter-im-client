import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/widget/custom_button.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("聊天设置"),
        backgroundColor: Colors.grey[100],
      ),
      body: UserPage(),
    );
  }
}

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TalkobjController talkobjController = Get.find();
  @override
  Widget build(BuildContext context) {
    Map? talkObj = talkobjController.talkObj;
    return ListView(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          title: Text(talkObj['name'] ?? ''),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(talkObj['icon'] ?? ''),
          ),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        Row(
          children: [
            const SizedBox(
              width: 18,
            ),
            const Text(
              "查找聊天记录",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Expanded(child: Container()),
            const Text('图片、视频、文件'), // 文本
            IconButton(
              onPressed: () {
                // 按钮点击事件处理
              },
              icon: const Icon(Icons.chevron_right), // 图标
            ),
            const SizedBox(width: 12), // 添加一些间距
          ],
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
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
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