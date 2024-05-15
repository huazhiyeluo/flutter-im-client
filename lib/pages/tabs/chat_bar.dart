import 'package:flutter/material.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/utils/cache.dart';

AppBar chatBar() {
  Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
  String username = userInfo == null ? "" : userInfo['username'];
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
        Text(
          username,
          style: const TextStyle(
            fontSize: 20,
          ),
        ), // 聊天对象的名称
      ],
    ),
    backgroundColor: Colors.grey[100],
    actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
    // 其他属性设置...
  );
}
