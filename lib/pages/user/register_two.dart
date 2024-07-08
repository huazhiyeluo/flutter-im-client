import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/widget/custom_button.dart';

class RegisterTwo extends StatefulWidget {
  const RegisterTwo({super.key});

  @override
  State<RegisterTwo> createState() => _RegisterTwoState();
}

class _RegisterTwoState extends State<RegisterTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: RegisterTwoPage(arguments: Get.arguments),
    );
  }
}

class RegisterTwoPage extends StatefulWidget {
  final Map arguments;
  const RegisterTwoPage({super.key, required this.arguments});

  @override
  State<RegisterTwoPage> createState() => _RegisterTwoPageState();
}

class _RegisterTwoPageState extends State<RegisterTwoPage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    String phone = widget.arguments['phone'];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(40, 110, 40, 0),
            child: const Text('Enter Code',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
            child: Text('We have sent you an SMS with the code to +86 $phone',
                style: const TextStyle(fontSize: 13), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 40),
          SizedBox(
              height: 70, // 设置TextField的高度
              child: TextField(
                controller: codeController, // 密码控制器
                keyboardType: TextInputType.number,
                maxLength: 6, // 设置验证码长度
                decoration: InputDecoration(
                  labelText: '验证码',
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 1.0),
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(15)),
                ),
              )),
          const SizedBox(height: 60),
          CustomButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register-three');
            },
            text: "下一步",
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          TextButton(
            onPressed: () {
              // 处理忘记密码逻辑
              Navigator.pushNamed(context, '/repasswd');
            },
            child: const Text(
              '没收到？重发验证码',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(child: Container())
        ],
      ),
    );
  }
}
