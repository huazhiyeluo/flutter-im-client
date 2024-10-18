import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qim/common/widget/custom_text_field_more.dart';
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
        title: const Text("更改昵称"),
        centerTitle: true,
        actions: [
          CustomButton(
            onPressed: () {
              _actUser();
            },
            text: "保存",
            backgroundColor: const Color.fromARGB(255, 87, 189, 106),
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(6),
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
            child: Stack(
              children: [
                CustomTextFieldMore(
                  focusNode: _focusNode1,
                  isFocused: _isFocusNode1,
                  controller: _nicknameController,
                  hintText: '请输入昵称',
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                  ],
                  focusedColor: const Color.fromARGB(255, 60, 183, 21),
                  unfocusedColor: Colors.grey,
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Text(
                    "${_nicknameController.text.characters.length}/15字",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
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
