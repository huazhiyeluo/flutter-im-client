import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/routes/route.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/widget/custom_button.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
      ),
      body: const SettingPage(),
    );
  }
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? _initialRoute;
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      ListTile(
        title: const Text("新消息提醒"),
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
        title: const Text("聊天"),
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
        title: const Text("通用"),
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
        title: const Text("朋友权限"),
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
        title: const Text("关于微信"),
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
        title: const Text("帮助与反馈"),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {},
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: CustomButton(
              onPressed: () async {
                CacheHelper.remove(Keys.userInfo);
                String initialRouteData = await initialRoute();
                if (!mounted) return;
                setState(() {
                  _initialRoute = initialRouteData;
                });
                Get.offAllNamed(initialRouteData);
              },
              text: "退出登录",
              backgroundColor: Colors.red,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    ]);
  }
}
