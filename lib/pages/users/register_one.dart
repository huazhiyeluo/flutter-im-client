import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterOne extends StatefulWidget {
  const RegisterOne({super.key});

  @override
  State<RegisterOne> createState() => _RegisterOneState();
}

class _RegisterOneState extends State<RegisterOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: const RegisterOnePage(),
    );
  }
}

class RegisterOnePage extends StatefulWidget {
  const RegisterOnePage({super.key});

  @override
  State<RegisterOnePage> createState() => _RegisterOnePageState();
}

class _RegisterOnePageState extends State<RegisterOnePage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(40, 110, 40, 0),
            child: const Text(
              'Enter Your Phone Number',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
            child: const Text(
              'Please confirm your country code and enter your phone number',
              style: TextStyle(
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
              height: 50, // 设置TextField的高度
              child: TextField(
                controller: phoneController, // 密码控制器
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '手机号',
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: "+86 ",
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              )),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: () {
              // Navigator.pushNamed(
              //   context,
              //   '/register-two',
              //   arguments: {"phone": phoneController.text},
              // );
              Get.toNamed('/register-two',
                  arguments: {"phone": phoneController.text});
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.blue,
              ), // 按钮背景色
              foregroundColor: MaterialStateProperty.all<Color>(
                Colors.white,
              ), // 文字颜色
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.fromLTRB(20, 15, 20, 15),
              ), // 内边距
            ),
            child: const Text('下一步'),
          ),
          Expanded(child: Container())
        ],
      ),
    );
  }
}
