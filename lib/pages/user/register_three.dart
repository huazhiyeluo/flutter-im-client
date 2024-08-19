import 'package:flutter/material.dart';
import 'package:qim/widget/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterThree extends StatefulWidget {
  const RegisterThree({super.key});

  @override
  State<RegisterThree> createState() => _RegisterThreeState();
}

class _RegisterThreeState extends State<RegisterThree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('填写用户名和密码'),
        backgroundColor: Colors.grey[100],
      ),
      body: const RegisterThreePage(),
    );
  }
}

class RegisterThreePage extends StatefulWidget {
  const RegisterThreePage({super.key});

  @override
  State<RegisterThreePage> createState() => _RegisterThreePageState();
}

class _RegisterThreePageState extends State<RegisterThreePage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController nicknameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
              onTap: () {},
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(fit: BoxFit.contain, image: AssetImage("lib/assets/images/upload.jpg")),
                ),
              )),
          const SizedBox(height: 40),
          SizedBox(
              height: 50, // 设置TextField的高度
              child: TextField(
                controller: nicknameController, // 用户名控制器
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: '用户名',
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
          const SizedBox(height: 20),
          SizedBox(
              height: 50, // 设置TextField的高度
              child: TextField(
                controller: passwordController, // 密码控制器
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: '密码',
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
                obscureText: true,
              )),
          const SizedBox(height: 60),
          CustomButton(
            onPressed: () {
              // 处理登录逻辑
              setCacheData();
              Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
            },
            text: "保存",
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          Expanded(child: Container())
        ],
      ),
    );
  }
}

setCacheData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('loggedIn', true);
}
