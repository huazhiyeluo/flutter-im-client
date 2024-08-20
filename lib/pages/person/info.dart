import 'package:flutter/material.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/routes/route.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/widget/custom_button.dart';

class PersonInfo extends StatefulWidget {
  const PersonInfo({super.key});

  @override
  State<PersonInfo> createState() => _PersonInfoState();
}

class _PersonInfoState extends State<PersonInfo> {
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
        title: const Text("个人信息"),
      ),
      body: const PersonInfoPage(),
    );
  }
}

class PersonInfoPage extends StatefulWidget {
  const PersonInfoPage({super.key});

  @override
  State<PersonInfoPage> createState() => _PersonInfoPageState();
}

class _PersonInfoPageState extends State<PersonInfoPage> {
  Map userInfo = {};
  @override
  void initState() {
    super.initState();
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const SizedBox(height: 20),
      ListTile(
        title: const Text("头像"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0), // 必须与 Container 的 borderRadius 相同
              child: Image.network(
                userInfo['avatar'], // 替换为你的图片URL
                width: 60.0,
                height: 60.0,
                fit: BoxFit.cover,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {},
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: const Divider(),
      ),
      ListTile(
        title: const Text("昵称"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userInfo['nickname'],
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {},
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: const Divider(),
      ),
      ListTile(
        title: const Text("用户名"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userInfo['username'],
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {},
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: const Divider(),
      ),
      ListTile(
        title: const Text("个性签名"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userInfo['info'],
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {},
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: const Divider(),
      ),
      const SizedBox(height: 20),
    ]);
  }
}
