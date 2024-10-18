import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qim/common/widget/custom_text_field_more.dart';
import 'package:qim/data/api/register.dart';
import 'package:qim/data/cache/keys.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/utils/cache.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';

class UserUsernameBind extends StatefulWidget {
  const UserUsernameBind({super.key});

  @override
  State<UserUsernameBind> createState() => _UserUsernameBindState();
}

class _UserUsernameBindState extends State<UserUsernameBind> {
  final UserInfoController userInfoController = Get.find();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repasswordController = TextEditingController();

  bool _obscureText = true;
  bool _isDelayed = false;

  bool _obscureTextRe = true;
  bool _isDelayedRe = false;

  bool _isShowUsernameClear = false;

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();

  bool _isFocusNode1 = false;
  bool _isFocusNode2 = false;
  bool _isFocusNode3 = false;

  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

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

    _focusNode3.addListener(() {
      if (_focusNode3.hasFocus) {
        setState(() {
          _isFocusNode3 = true;
        });
      } else {
        setState(() {
          _isFocusNode3 = false;
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
    _usernameController.text = "";
    setState(() {
      _isShowUsernameClear = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("绑定用户名"),
        centerTitle: true,
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
                child: Stack(
                  children: [
                    CustomTextFieldMore(
                      focusNode: _focusNode1,
                      isFocused: _isFocusNode1,
                      controller: _usernameController,
                      hintText: '请输入用户名',
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      suffixIcon: _isShowUsernameClear && _isFocusNode1
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.grey,
                              ),
                              onPressed: _clearUsername,
                            )
                          : const SizedBox.shrink(),
                      focusedColor: const Color.fromARGB(255, 60, 183, 21),
                      unfocusedColor: Colors.grey,
                      showUnderline: false,
                      onChanged: (val) {
                        _checkUsername(val);
                      },
                    ),
                    Positioned(
                      right: 0,
                      bottom: 1,
                      child: Text(
                        "${_usernameController.text.characters.length}/15字",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            color: _isFocusNode1 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
          ),
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
                child: Stack(
                  children: [
                    CustomTextFieldMore(
                      focusNode: _focusNode2,
                      isFocused: _isFocusNode2,
                      controller: _passwordController,
                      obscureText: _obscureText,
                      hintText: '请输入密码',
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                      suffixIcon: _isFocusNode2 && _passwordController.text.trim() != ""
                          ? IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: _togglePasswordVisibility,
                            )
                          : const SizedBox.shrink(),
                      focusedColor: const Color.fromARGB(255, 60, 183, 21),
                      unfocusedColor: Colors.grey,
                      showUnderline: false,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 1,
                      child: Text(
                        "${_passwordController.text.characters.length}/20字",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            color: _isFocusNode2 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
          ),
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
                child: Stack(
                  children: [
                    CustomTextFieldMore(
                      focusNode: _focusNode3,
                      isFocused: _isFocusNode3,
                      controller: _repasswordController,
                      obscureText: _obscureTextRe,
                      hintText: '请输入确认密码',
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                      suffixIcon: _isFocusNode3 && _repasswordController.text.trim() != ""
                          ? IconButton(
                              icon: Icon(
                                _obscureTextRe ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: _toggleRepasswordVisibility,
                            )
                          : const SizedBox.shrink(),
                      focusedColor: const Color.fromARGB(255, 60, 183, 21),
                      unfocusedColor: Colors.grey,
                      showUnderline: false,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 1,
                      child: Text(
                        "${_repasswordController.text.characters.length}/20字",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            color: _isFocusNode3 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
          ),
          const SizedBox(height: 10),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  void _bind() {
    var params = {'uid': uid, 'username': _usernameController.text, 'password': _passwordController.text, 'repassword': _repasswordController.text};
    RegisterApi.bind(params, onSuccess: (res) async {
      CacheHelper.saveData(Keys.userInfo, res['data']);
      userInfoController.setUserInfo(res['data']);
      Navigator.of(context).pop(false);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
