import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qim/api/login.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';

class LoginCode extends StatefulWidget {
  const LoginCode({super.key});

  @override
  State<LoginCode> createState() => _LoginCodeState();
}

class _LoginCodeState extends State<LoginCode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      body: const LoginCodePage(),
    );
  }
}

class LoginCodePage extends StatefulWidget {
  const LoginCodePage({super.key});

  @override
  State<LoginCodePage> createState() => _LoginCodePageState();
}

class _LoginCodePageState extends State<LoginCodePage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  bool _isFocusNode1 = false;
  bool _isFocusNode2 = false;

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
        Row(
          children: [
            const Text(
              "验证码登录",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Expanded(child: Container()),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50, // 设置TextField的高度
          child: TextField(
            focusNode: _focusNode1,
            controller: phoneController, // 用户名控制器
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '请输入手机号',
              prefixIcon: Icon(
                Icons.phone,
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
          height: 50, //
          child: TextField(
            focusNode: _focusNode2,
            controller: codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 数字
            ],
            decoration: InputDecoration(
              hintText: '请输入验证码',
              prefixIcon: Icon(
                Icons.code,
                color: _isFocusNode2 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
              ),
              suffixIcon: Column(
                children: [
                  CustomButton(
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    onPressed: () {},
                    text: "获取验证码",
                    backgroundColor: Colors.white,
                    foregroundColor: const Color.fromARGB(255, 60, 183, 21),
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 60, 183, 21), width: 1),
                  )
                ],
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
            _loginCodeAction();
          },
          text: "登录",
          backgroundColor: const Color.fromARGB(255, 60, 183, 21),
          foregroundColor: Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  _loginCodeAction() async {
    var params = {'phone': phoneController.text, 'code': codeController.text};
    LoginApi.login(params, onSuccess: (res) async {}, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
