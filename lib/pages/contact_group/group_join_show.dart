import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/controller/userinfo.dart';

class GroupJoinShow extends StatefulWidget {
  const GroupJoinShow({super.key});

  @override
  State<GroupJoinShow> createState() => _GroupJoinShowState();
}

class _GroupJoinShowState extends State<GroupJoinShow> {
  final UserInfoController userInfoController = Get.find();

  int uid = 0;
  Map userInfo = {};

  Map toObj = {};

  @override
  void initState() {
    super.initState();

    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    if (Get.arguments != null) {
      toObj = Get.arguments;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.close),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              const Text("该群聊邀请已发送"),
              const SizedBox(
                height: 80,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
                child: Image(
                  image: CachedNetworkImageProvider(toObj['icon'] ?? ""), // 使用 CachedNetworkImageProvider
                  width: 60.0,
                  height: 60.0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "${toObj['name']}(${toObj['num']})",
                style: const TextStyle(fontSize: 17),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}
