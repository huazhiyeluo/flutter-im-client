import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qim/common/widget/custom_text_field_more.dart';
import 'package:qim/data/api/login.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';

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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

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
    _phoneController.dispose();
    _codeController.dispose();
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
          child: CustomTextFieldMore(
            focusNode: _focusNode1,
            isFocused: _isFocusNode1,
            controller: _phoneController,
            hintText: '请输入手机号',
            keyboardType: TextInputType.phone,
            prefixIcon: Icon(
              Icons.phone,
              color: _isFocusNode1 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
            ),
            focusedColor: const Color.fromARGB(255, 60, 183, 21),
            unfocusedColor: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50, //
          child: CustomTextFieldMore(
            focusNode: _focusNode2,
            isFocused: _isFocusNode2,
            controller: _codeController,
            hintText: '请输入验证码',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
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
            focusedColor: const Color.fromARGB(255, 60, 183, 21),
            unfocusedColor: Colors.grey,
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
    var params = {'phone': _phoneController.text, 'code': _codeController.text};
    LoginApi.login(params, onSuccess: (res) async {}, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
