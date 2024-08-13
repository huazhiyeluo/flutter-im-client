import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/utils/cache.dart';

AppBar contactBar() {
  Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
  String avatar = userInfo == null ? "" : userInfo['avatar'];
  return AppBar(
    centerTitle: false,
    title: Row(
      children: [
        CircleAvatar(
          // 聊天对象的头像
          radius: 14,
          backgroundImage: NetworkImage(avatar),
        ),
        const SizedBox(width: 8),
        const Text(
          "联系人",
          style: TextStyle(
            fontSize: 20,
          ),
        ), // 聊天对象的名称
      ],
    ),
    backgroundColor: Colors.grey[100],
    actions: [
      IconButton(
          onPressed: () {
            Get.toNamed('/add-contact');
          },
          icon: const Icon(Icons.person_add_alt))
    ],
    // 其他属性设置...
  );
}
