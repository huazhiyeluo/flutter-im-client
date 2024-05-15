import 'package:flutter/material.dart';

AppBar contactBar() {
  return AppBar(
    centerTitle: false,
    title: const Text(
      '联系人',
      style: TextStyle(fontSize: 20),
    ),
    backgroundColor: Colors.grey[100],
    actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
    // 其他属性设置...
  );
}
