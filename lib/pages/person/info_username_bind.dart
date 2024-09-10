import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qim/api/register.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/userinfo.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/functions.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';

class PersonInfoUsernameBind extends StatefulWidget {
  const PersonInfoUsernameBind({super.key});

  @override
  State<PersonInfoUsernameBind> createState() => _PersonInfoUsernameBindState();
}

class _PersonInfoUsernameBindState extends State<PersonInfoUsernameBind> {
  final UserInfoController userInfoController = Get.find();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();

  bool _obscureText = true;
  bool _isDelayed = false;

  bool _obscureTextRe = true;
  bool _isDelayedRe = false;

  bool _isShowUsernameClear = false;

  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
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

  void _toggleRepasswordVisibility() {
    setState(() {
      _obscureTextRe = !_obscureTextRe; // 切换密码可见性
    });

    if (!_obscureTextRe) {
      // 如果密码显示状态，设置3秒后恢复为隐藏
      setState(() {
        _isDelayedRe = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (_isDelayedRe) {
          setState(() {
            _obscureTextRe = true; // 恢复为密码模式
            _isDelayedRe = false;
          });
        }
      });
    }
  }

  _checkUsername(val) {
    if (val != "") {
      setState(() {
        _isShowUsernameClear = true;
      });
    } else {
      setState(() {
        _isShowUsernameClear = false;
      });
    }
  }

  _clearUsername() {
    usernameController.text = "";
    setState(() {
      _isShowUsernameClear = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("绑定用户名"),
        actions: [
          CustomButton(
            onPressed: () {
              _bind();
            },
            text: "完成",
            backgroundColor: const Color.fromARGB(255, 60, 183, 21),
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(5),
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          ),
          const SizedBox(
            width: 15,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            textBaseline: TextBaseline.alphabetic,
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  '用户名',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: usernameController,
                  keyboardType: TextInputType.text,
                  onChanged: (val) {
                    _checkUsername(val);
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), // 只允许字母和数字
                  ],
                  decoration: InputDecoration(
                    suffixIcon: _isShowUsernameClear
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Color.fromARGB(199, 171, 175, 169),
                            ),
                            onPressed: _clearUsername,
                          )
                        : const SizedBox.shrink(),
                    hintText: '请输入用户名',
                    border: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            textBaseline: TextBaseline.alphabetic,
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  '密码',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: passwordController, // 用户名控制器
                  obscureText: _obscureText,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: '请输入密码',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: const Color.fromARGB(199, 171, 175, 169),
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            textBaseline: TextBaseline.alphabetic,
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  '确认密码',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: repasswordController, // 用户名控制器
                  obscureText: _obscureTextRe,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: '请输入确认密码',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureTextRe ? Icons.visibility_off : Icons.visibility,
                        color: const Color.fromARGB(199, 171, 175, 169),
                      ),
                      onPressed: _toggleRepasswordVisibility,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  void _bind() {
    var params = {
      'uid': uid,
      'username': usernameController.text,
      'password': passwordController.text,
      'repassword': repasswordController.text
    };
    RegisterApi.bind(params, onSuccess: (res) async {
      CacheHelper.saveData(Keys.userInfo, res['data']);
      userInfoController.setUserInfo(res['data']);
      Navigator.of(context).pop(false);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
