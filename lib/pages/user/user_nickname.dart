import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/user.dart';
import 'package:qim/data/cache/keys.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/utils/cache.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';

class UserNickname extends StatefulWidget {
  const UserNickname({super.key});

  @override
  State<UserNickname> createState() => _UserNicknameState();
}

class _UserNicknameState extends State<UserNickname> {
  final UserInfoController userInfoController = Get.find();
  final TextEditingController _nicknameController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  final FocusNode _focusNode1 = FocusNode();
  bool _isFocusNode1 = false;

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    _nicknameController.text = userInfo['nickname'];

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
  }

  @override
  void dispose() {
    super.dispose();
    _nicknameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("更改名字"),
        actions: [
          CustomButton(
            onPressed: () {
              _actUser();
            },
            text: "保存",
            backgroundColor: const Color.fromARGB(255, 223, 219, 219),
            foregroundColor: Colors.grey,
            borderRadius: BorderRadius.circular(2),
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
          SizedBox(
            height: 50, // 设置TextField的高度
            child: TextField(
              controller: _nicknameController, // 用户名控制器
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: '请输入昵称',
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
          const SizedBox(height: 10),
          Text("好名字可以让你的朋友更容易记住", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _actUser() {
    var params = {
      'nickname': _nicknameController.text,
      'uid': uid,
    };
    UserApi.actUser(params, onSuccess: (res) async {
      userInfoController.setUserInfo({...userInfoController.userInfo, 'nickname': params['nickname']});
      CacheHelper.saveData(Keys.userInfo, userInfoController.userInfo);
      Navigator.pop(context);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
