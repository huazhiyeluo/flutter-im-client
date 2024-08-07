import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/login.dart';
import 'package:qim/api/user.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/routes/route.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('登录'),
        backgroundColor: Colors.grey[100],
      ),
      body: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
              height: 50, // 设置TextField的高度
              child: TextField(
                controller: usernameController, // 用户名控制器
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: '用户名',
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
          const SizedBox(height: 20),
          SizedBox(
              height: 50, // 设置TextField的高度
              child: TextField(
                controller: passwordController, // 密码控制器
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: '密码',
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
                obscureText: true,
              )),
          const SizedBox(height: 20),
          CustomButton(
            onPressed: () {
              _loginAction();
            },
            text: "登录",
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // 处理注册账号逻辑
                  // Navigator.pushNamed(context, '/register-one');
                  Get.toNamed("/register-one");
                },
                child: const Text(
                  '注册账号',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () {
                  // 处理忘记密码逻辑
                  // Navigator.pushNamed(context, '/repasswd');
                  Get.toNamed("/repasswd");
                },
                child: const Text(
                  '忘记密码?',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          Expanded(child: Container())
        ],
      ),
    );
  }

  _loginAction() async {
    var params = {'username': usernameController.text, 'password': passwordController.text};
    LoginApi.login(params, onSuccess: (res) async {
      CacheHelper.saveData(Keys.userInfo, res['data']);
      String initialRouteData = await initialRoute();
      Get.offAndToNamed(initialRouteData);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
