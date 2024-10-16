import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';

class UserUsername extends StatefulWidget {
  const UserUsername({super.key});

  @override
  State<UserUsername> createState() => _UserUsernameState();
}

class _UserUsernameState extends State<UserUsername> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 80,
          ),
          Image.asset("lib/assets/images/safe.png", width: 75, height: 75),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "用户名:",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                userInfo['username'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "用户名是账号的唯一凭证，一年只能修改一次",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 40,
          ),
          Expanded(child: Container()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                onPressed: () {
                  _actUser();
                },
                text: "修改用户名",
                backgroundColor: const Color.fromARGB(255, 237, 237, 237),
                foregroundColor: Colors.black,
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              ),
            ],
          ),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  void _actUser() {
    TipHelper.instance.showToast("暂不支持");
    return;
  }
}
