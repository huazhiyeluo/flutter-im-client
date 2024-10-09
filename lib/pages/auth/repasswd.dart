import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/login.dart';
import 'package:qim/data/cache/keys.dart';
import 'package:qim/routes/route.dart';
import 'package:qim/common/utils/cache.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';

class Repasswd extends StatefulWidget {
  const Repasswd({super.key});

  @override
  State<Repasswd> createState() => _RepasswdState();
}

class _RepasswdState extends State<Repasswd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        title: const Text("重置密码"),
      ),
      body: const RepasswdPage(),
    );
  }
}

class RepasswdPage extends StatefulWidget {
  const RepasswdPage({super.key});

  @override
  State<RepasswdPage> createState() => _RepasswdPageState();
}

class _RepasswdPageState extends State<RepasswdPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  bool _isFocusNode1 = false;
  bool _isFocusNode2 = false;

  bool _obscureText = true; // 用于控制密码是否显示
  bool _isDelayed = false;

  @override
  void initState() {
    super.initState();

    // 监听焦点变化事件
    _focusNode1.addListener(() {
      if (_focusNode1.hasFocus) {
        setState(() {
          _isFocusNode1 = true;
        });
      } else {
        setState(() {
          _isFocusNode1 = false;
        });
      }
    });

    _focusNode2.addListener(() {
      if (_focusNode2.hasFocus) {
        setState(() {
          _isFocusNode2 = true;
        });
      } else {
        setState(() {
          _isFocusNode2 = false;
        });
      }
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // 切换密码可见性
    });

    if (!_obscureText) {
      // 如果密码显示状态，设置3秒后恢复为隐藏
      setState(() {
        _isDelayed = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (_isDelayed) {
          setState(() {
            _obscureText = true; // 恢复为密码模式
            _isDelayed = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    // 确保在不再需要时清理 FocusNode
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 30),
        SizedBox(
          height: 50, // 设置TextField的高度
          child: TextField(
            focusNode: _focusNode1,
            controller: usernameController, // 用户名控制器
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), // 只允许字母和数字
            ],
            decoration: InputDecoration(
              hintText: '请输入用户名',
              prefixIcon: Icon(
                Icons.person,
                color: _isFocusNode1 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
              ),
              border: UnderlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: _isFocusNode1 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50, // 设置TextField的高度
          child: TextField(
            focusNode: _focusNode2,
            controller: passwordController, // 用户名控制器
            obscureText: _obscureText,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: '请输入密码',
              prefixIcon: Icon(
                Icons.lock,
                color: _isFocusNode2 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color.fromARGB(199, 171, 175, 169),
                ),
                onPressed: _togglePasswordVisibility,
              ),
              border: UnderlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: _isFocusNode2 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomButton(
          onPressed: () {
            _repasswdAction();
          },
          text: "重置",
          backgroundColor: const Color.fromARGB(255, 60, 183, 21),
          foregroundColor: Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  _repasswdAction() async {
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
