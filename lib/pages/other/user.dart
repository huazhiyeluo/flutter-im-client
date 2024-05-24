import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/talkobj.dart';

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
            const SizedBox(width: 25), // 添加一些间距
          ],
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
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
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/entry",
                    (route) => false,
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ), // 按钮背景色
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.red,
                  ), // 文字颜色
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  ), // 内边距
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ), // 文字样式
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ), // 圆角边框
                ),
                child: const Text("删除好友"),
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
