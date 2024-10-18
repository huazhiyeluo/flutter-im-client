import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qim/common/widget/custom_text_field_more.dart';
import 'package:qim/data/api/login.dart';
import 'package:qim/data/api/user.dart';
import 'package:qim/data/cache/keys.dart';
import 'package:qim/routes/route.dart';
import 'package:qim/common/utils/cache.dart';
import 'package:qim/common/utils/device_info.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  bool _isFocusNode1 = false;
  bool _isFocusNode2 = false;

  bool _obscureText = true;
  bool _isDelayed = false;

  bool isButtonEnabled = true;

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
        const SizedBox(height: 50),
        Row(
          children: [
            Expanded(child: Container()),
            TextButton(
              onPressed: () {
                Get.toNamed("/register");
              },
              child: const Text(
                "注册",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 60, 183, 21),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Image.asset("lib/assets/images/person.png", width: 80, height: 80),
        const SizedBox(height: 25),
        SizedBox(
          height: 50,
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
                prefixIcon: Icon(
                  Icons.person,
                  color: _isFocusNode1 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
                ),
                suffixIcon: _isFocusNode1 && _usernameController.text.trim() != ""
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _usernameController.text = "";
                          setState(() {});
                        },
                      )
                    : const SizedBox.shrink(),
                focusedColor: const Color.fromARGB(255, 160, 163, 159),
                unfocusedColor: Colors.grey,
                onChanged: (val) {
                  setState(() {});
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
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
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
                prefixIcon: Icon(
                  Icons.lock,
                  color: _isFocusNode2 ? const Color.fromARGB(255, 60, 183, 21) : Colors.grey,
                ),
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
                onChanged: (value) {
                  setState(() {});
                },
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
        const SizedBox(height: 20),
        CustomButton(
          onPressed: () {
            isButtonEnabled ? _loginAction() : null;
          },
          text: "登录",
          backgroundColor: const Color.fromARGB(255, 60, 183, 21),
          foregroundColor: Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                isButtonEnabled ? _loginVisitorAction() : null;
              },
              child: const Text(
                '游客登录',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const Text("|"),
            TextButton(
              onPressed: () {
                isButtonEnabled ? _loginGoogleAction() : null;
              },
              child: const Text(
                '谷歌登录',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Expanded(child: Container()),
            TextButton(
              onPressed: () {
                Get.toNamed("/repasswd");
              },
              child: const Text(
                '忘记密码?',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  //1、账号登录
  _loginAction() async {
    if (!isButtonEnabled) return;
    setState(() {
      isButtonEnabled = false;
    });

    if (_usernameController.text.trim() == "") {
      TipHelper.instance.showToast("请输入用户名");
      setState(() {
        isButtonEnabled = true;
      });
      return;
    }

    if (_passwordController.text.trim() == "") {
      TipHelper.instance.showToast("请输入密码");
      setState(() {
        isButtonEnabled = true;
      });
      return;
    }

    var params = {
      'platform': "account",
      'username': _usernameController.text.trim(),
      'password': _passwordController.text.trim(),
    };
    LoginApi.login(params, onSuccess: (res) async {
      _loginAfter(res['data']);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
      setState(() {
        isButtonEnabled = true;
      });
    });
  }

  //2、游客登录
  _loginVisitorAction() async {
    if (!isButtonEnabled) return;
    setState(() {
      isButtonEnabled = false;
    });
    var params = {
      'platform': "visitor",
    };
    LoginApi.login(params, onSuccess: (res) async {
      _loginAfter(res['data']);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
      setState(() {
        isButtonEnabled = true;
      });
    });
  }

  //3、谷歌登录
  _loginGoogleAction() async {
    if (!isButtonEnabled) return;
    setState(() {
      isButtonEnabled = false;
    });
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      TipHelper.instance.showToast("用户取消登录，请重试");
      setState(() {
        isButtonEnabled = true;
      });
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    var params = {
      'platform': "google",
      'avatar': userCredential.additionalUserInfo?.profile?["picture"],
      'nickname': userCredential.additionalUserInfo?.profile?["name"],
      "token": googleAuth.accessToken,
      'siteuid': userCredential.additionalUserInfo?.profile?["sub"],
    };
    LoginApi.login(params, onSuccess: (res) async {
      _loginAfter(res['data']);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
      setState(() {
        isButtonEnabled = true;
      });
    });
  }

  // 设置设备token
  Future<void> _setFcm(int uid) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final type = await DeviceInfo.getPlatformType();
    var params = {
      'uid': uid,
      'token': fcmToken,
      'type': type,
    };
    UserApi.actDeviceToken(params, onSuccess: (res) async {}, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  // 登录后操作
  Future<void> _loginAfter(Map data) async {
    _setFcm(data['user']['uid']);
    CacheHelper.saveData(Keys.userInfo, data['user']);
    CacheHelper.saveData(Keys.token, data['token']);
    String initialRouteData = await initialRoute();
    Get.offAndToNamed(initialRouteData);
  }
}
