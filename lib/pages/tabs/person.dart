import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/controller/userinfo.dart';

class Person extends StatefulWidget {
  const Person({super.key});

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> {
  final UserInfoController userInfoController = Get.find();

  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      userInfo = userInfoController.userInfo;
      return ListView(children: [
        const SizedBox(
          height: 10,
        ),
        ListTile(
          title: Text(
            userInfo['nickname'] ?? "",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          subtitle: Text('QID: ${userInfo['uid'] ?? ""}'),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(20.0), // 设置圆角半径
            child: Image(
              image: CachedNetworkImageProvider(userInfo['avatar'] ?? ""), // 使用 CachedNetworkImageProvider
              width: 60.0,
              height: 60.0,
              fit: BoxFit.cover,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: () {
                  Navigator.pushNamed(context, '/user-info');
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  Navigator.pushNamed(context, '/user-detail');
                },
              ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/user-detail',
            );
          },
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
              '/setting',
            );
          },
        ),
      ]);
    });
  }
}
