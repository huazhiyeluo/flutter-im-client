import 'package:flutter/material.dart';

AppBar settingBar() {
  return AppBar(
    centerTitle: false,
    title: const Text(
      '个人中心',
      style: TextStyle(fontSize: 20),
    ),
    backgroundColor: Colors.grey[100],
    // 其他属性设置...
  );
}
