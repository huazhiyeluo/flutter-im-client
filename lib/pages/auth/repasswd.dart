import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qim/common/widget/custom_text_field_more.dart';
import 'package:qim/data/api/login.dart';
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    _usernameController.dispose();
    _passwordController.dispose();
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
          child: CustomTextFieldMore(
            focusNode: _focusNode1,
            isFocused: _isFocusNode1,
            controller: _usernameController,
            hintText: '请输入用户名',
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), // 只允许字母和数字
            ],
            prefixIcon: Icon(
              Icons.person,
              color: _isFocusNode1 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
            ),
            focusedColor: const Color.fromARGB(255, 60, 183, 21),
            unfocusedColor: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50, // 设置TextField的高度
          child: CustomTextFieldMore(
            focusNode: _focusNode2,
            isFocused: _isFocusNode2,
            controller: _passwordController,
            obscureText: _obscureText,
            hintText: '请输入密码',
            keyboardType: TextInputType.text,
            prefixIcon: Icon(
              Icons.lock,
              color: _isFocusNode2 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: _isFocusNode2 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
              ),
              onPressed: _togglePasswordVisibility,
            ),
            focusedColor: const Color.fromARGB(255, 60, 183, 21),
            unfocusedColor: Colors.grey,
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
    var params = {'username': _usernameController.text, 'password': _passwordController.text};
    LoginApi.repassword(params, onSuccess: (res) async {}, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
