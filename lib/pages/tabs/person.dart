import 'package:flutter/material.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/utils/cache.dart';

class Person extends StatefulWidget {
  const Person({super.key});

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> {
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      ListTile(
        title: Text(
          userInfo['username'],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(userInfo['info']),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(20.0), // 必须与 Container 的 borderRadius 相同
          child: Image.network(
            userInfo['avatar'], // 替换为你的图片URL
            width: 60.0,
            height: 60.0,
            fit: BoxFit.cover,
          ),
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
        title: const Text("朋友圈"),
        leading: const Icon(Icons.photo),
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
        title: const Text("收藏"),
        leading: const Icon(Icons.collections),
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
        title: const Text("设置"),
        leading: const Icon(Icons.settings),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/person-setting',
          );
        },
      ),
    ]);
  }
}
