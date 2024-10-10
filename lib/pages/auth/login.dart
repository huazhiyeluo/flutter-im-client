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
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
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
            _loginAction();
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
                _loginVisitorAction();
              },
              child: const Text(
                '游客登录',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const Text("|"),
            TextButton(
              onPressed: () {
                _signInWithGoogle();
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

  _loginAction() async {
    var params = {
      'platform': "account",
      'username': _usernameController.text,
      'password': _passwordController.text,
    };
    LoginApi.login(params, onSuccess: (res) async {
      _loginAfter(res['data']);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  _loginVisitorAction() async {
    var params = {
      'platform': "visitor",
    };
    LoginApi.login(params, onSuccess: (res) async {
      _loginAfter(res['data']);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      TipHelper.instance.showToast("用户取消登录，请重试");
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
    });
  }

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

  Future<void> _loginAfter(Map data) async {
    _setFcm(data['user']['uid']);
    CacheHelper.saveData(Keys.userInfo, data['user']);
    CacheHelper.saveData(Keys.token, data['token']);
    String initialRouteData = await initialRoute();
    Get.offAndToNamed(initialRouteData);
  }
}
