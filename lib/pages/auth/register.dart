import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qim/common/widget/custom_text_field_more.dart';
import 'package:qim/data/api/common.dart';
import 'package:qim/data/api/register.dart';
import 'package:qim/common/utils/common.dart';
import 'package:qim/common/utils/permission.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';
import 'package:dio/dio.dart' as dio;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("取消"),
        ),
      ),
      body: const RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repasswordController = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();

  bool _isFocusNode1 = false;
  bool _isFocusNode2 = false;
  bool _isFocusNode3 = false;
  bool _isFocusNode4 = false;

  bool _obscureText = true;
  bool _isDelayed = false;

  bool _obscureTextRe = true;
  bool _isDelayedRe = false;

  bool _isChecked = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  bool _isShowNicknameClear = false;
  bool _isShowUsernameClear = false;

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

    _focusNode4.addListener(() {
      if (_focusNode4.hasFocus) {
        setState(() {
          _isFocusNode4 = true;
        });
      } else {
        setState(() {
          _isFocusNode4 = false;
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

  @override
  void dispose() {
    super.dispose();
    _nicknameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        const Text(
          "用户名注册",
          style: TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Container()),
            GestureDetector(
              onTap: () {
                _uploadAvatar();
              },
              child: _imageFile == null
                  ? Image.asset("lib/assets/images/upload.jpg", width: 75, height: 75)
                  : Stack(
                      children: [
                        Image.file(
                          width: 75,
                          height: 75,
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: -15,
                          bottom: -15,
                          child: IconButton(
                            color: Colors.black,
                            padding: EdgeInsets.zero, // 移除内部填充
                            constraints: const BoxConstraints(), // 移除默认约束
                            iconSize: 25,
                            onPressed: () {
                              _clearAvatar();
                            },
                            icon: const Icon(
                              Icons.clear,
                              color: Color.fromARGB(197, 244, 3, 3),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Expanded(child: Container()),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          textBaseline: TextBaseline.alphabetic,
          children: [
            const SizedBox(
              width: 80,
              child: Text(
                '昵称',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              child: CustomTextFieldMore(
                focusNode: _focusNode1,
                isFocused: _isFocusNode1,
                controller: _nicknameController,
                hintText: '请输入昵称',
                keyboardType: TextInputType.text,
                suffixIcon: _isShowNicknameClear
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: _isFocusNode1 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
                        ),
                        onPressed: _clearNickname,
                      )
                    : const SizedBox.shrink(),
                focusedColor: const Color.fromARGB(255, 60, 183, 21),
                unfocusedColor: Colors.grey,
                showUnderline: false,
                onChanged: (val) {
                  _checkNickname(val);
                },
              ),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 20),
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
              child: CustomTextFieldMore(
                focusNode: _focusNode2,
                isFocused: _isFocusNode2,
                controller: _usernameController,
                hintText: '请输入用户名',
                keyboardType: TextInputType.text,
                suffixIcon: _isShowUsernameClear
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: _isFocusNode1 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
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
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 20),
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
              child: CustomTextFieldMore(
                focusNode: _focusNode3,
                isFocused: _isFocusNode3,
                controller: _passwordController,
                obscureText: _obscureText,
                hintText: '请输入密码',
                keyboardType: TextInputType.text,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: _isFocusNode3 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
                focusedColor: const Color.fromARGB(255, 60, 183, 21),
                unfocusedColor: Colors.grey,
                showUnderline: false,
              ),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 20),
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
              child: CustomTextFieldMore(
                focusNode: _focusNode4,
                isFocused: _isFocusNode4,
                controller: _repasswordController,
                obscureText: _obscureTextRe,
                hintText: '请输入确认密码',
                keyboardType: TextInputType.text,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureTextRe ? Icons.visibility_off : Icons.visibility,
                    color: _isFocusNode4 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
                  ),
                  onPressed: _toggleRepasswordVisibility,
                ),
                focusedColor: const Color.fromARGB(255, 60, 183, 21),
                unfocusedColor: Colors.grey,
                showUnderline: false,
              ),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: _isChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value!;
                });
              },
              visualDensity: const VisualDensity(
                horizontal: 0,
                vertical: 0,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const Text("我已阅读并同意"),
            TextButton(
              onPressed: () {
                Get.toNamed(
                  '/term',
                  arguments: {"title": "QIM软件许可及服务协议", "htmlFilePath": "lib/assets/term/register.html"},
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0), // 设置水平内边距
              ),
              child: const Text("《QIM软件许可及服务协议》"),
            ),
          ],
        ),
        CustomButton(
          onPressed: () {
            _registerAction();
          },
          text: "注册",
          backgroundColor: const Color.fromARGB(255, 60, 183, 21),
          foregroundColor: Colors.white,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  _clearAvatar() {
    setState(() {
      _imageFile = null;
    });
  }

  _checkNickname(val) {
    if (val != "") {
      setState(() {
        _isShowNicknameClear = true;
      });
    } else {
      setState(() {
        _isShowNicknameClear = false;
      });
    }
  }

  _clearNickname() {
    _nicknameController.text = "";
    setState(() {
      _isShowNicknameClear = false;
    });
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

  Future<void> _uploadAvatar() async {
    var isGrantedStorage = await PermissionUtil.requestStoragePermission();
    if (!isGrantedStorage) {
      TipHelper.instance.showToast("未允许存储读写权限");
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  _registerAction() async {
    if (_imageFile == null) {
      TipHelper.instance.showToast("请选择头像");
      return;
    }
    if (!_isChecked) {
      TipHelper.instance.showToast("请勾选同意条款");
      return;
    }
    XFile compressedFile = await compressImage(_imageFile!);
    dio.MultipartFile file = await dio.MultipartFile.fromFile(compressedFile.path);
    CommonApi.upload({'file': file}, onSuccess: (res) async {
      var params = {
        'avatar': res['data'],
        'nickname': _nicknameController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        'repassword': _repasswordController.text
      };
      RegisterApi.register(params, onSuccess: (res) async {
        Navigator.of(context).pop(false);
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
