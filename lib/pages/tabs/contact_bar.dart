import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/controller/userinfo.dart';

AppBar contactBar() {
  final UserInfoController userInfoController = Get.find();
  Map userInfo = userInfoController.userInfo;
  String avatar = userInfo['avatar'];
  return AppBar(
    centerTitle: false,
    title: Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(avatar),
        ),
        const SizedBox(width: 8),
        const Text(
          "联系人",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Get.toNamed('/add-contact');
          },
          icon: const Icon(
            Icons.person_add_alt,
            size: 28,
          ))
    ],
  );
}
