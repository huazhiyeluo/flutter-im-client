import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/widget/custom_button.dart';

class GroupJoin extends StatefulWidget {
  const GroupJoin({super.key});

  @override
  State<GroupJoin> createState() => _GroupJoinState();
}

class _GroupJoinState extends State<GroupJoin> {
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
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              const Text("·该群聊人数较多，为减少新消息给你带来的打扰，建议谨慎加入。"),
              const SizedBox(
                height: 10,
              ),
              const Text("·为维护秋聊平台绿色网络环境，请勿在群内传播违法违规内容。"),
              Expanded(child: Container()),
              CustomButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/add-contact-group-do',
                    arguments: toObj,
                  );
                },
                text: "加入群聊",
                backgroundColor: const Color.fromARGB(255, 60, 183, 21),
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(
                height: 120,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
