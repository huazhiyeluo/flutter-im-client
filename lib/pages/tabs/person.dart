import 'package:flutter/material.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/routes/route.dart';
import 'package:qim/utils/cache.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String? _initialRoute;
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        title: Text(userInfo['username']),
        subtitle: Text(userInfo['info']),
        leading: CircleAvatar(
          // Example Avatar
          backgroundImage: NetworkImage(userInfo['avatar']),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            // Handle add contact action
          },
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: const Divider(),
      ),
      ListTile(
        title: const Text("Account"),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            // Handle add contact action
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            // Handle add contact action
          },
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: const Divider(),
      ),
      ListTile(
        title: const Text("Chat"),
        leading: IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () {
            // Handle add contact action
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            // Handle add contact action
          },
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: const Divider(),
      ),
      ListTile(
        title: const Text("Data Usage"),
        leading: IconButton(
          icon: const Icon(Icons.wallet),
          onPressed: () {
            // Handle add contact action
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            // Handle add contact action
          },
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: const Divider(),
      ),
      ListTile(
        title: const Text("Help"),
        leading: IconButton(
          icon: const Icon(Icons.help_center),
          onPressed: () {
            // Handle add contact action
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            // Handle add contact action
          },
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: TextButton(
              onPressed: () async {
                CacheHelper.remove(Keys.userInfo);
                CacheHelper.remove(Keys.entryPage);
                String initialRouteData = await initialRoute();
                setState(() {
                  _initialRoute = initialRouteData;
                });
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  _initialRoute!,
                  (route) => false,
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.red,
                ), // 按钮背景色
                foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white,
                ), // 文字颜色
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                ), // 内边距
                textStyle: MaterialStateProperty.all<TextStyle>(
                  const TextStyle(fontSize: 18),
                ), // 文字样式
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ), // 圆角边框
              ),
              child: const Text("退出登录"),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    ]);
  }
}
