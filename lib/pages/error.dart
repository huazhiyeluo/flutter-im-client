import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  void initState() {
    super.initState();
    // 在2秒后自动跳转到其他路由
    Future.delayed(const Duration(seconds: 2), () {
      Get.toNamed(
        '/',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("App错误,快去反馈给开发者!"));
  }
}
