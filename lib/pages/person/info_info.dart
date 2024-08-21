import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/user.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/userinfo.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';

class PersonInfoInfo extends StatefulWidget {
  const PersonInfoInfo({super.key});

  @override
  State<PersonInfoInfo> createState() => _PersonInfoInfoState();
}

class _PersonInfoInfoState extends State<PersonInfoInfo> {
  final UserInfoController userInfoController = Get.find();
  final TextEditingController infoController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  final FocusNode _focusNode1 = FocusNode();
  bool _isFocusNode1 = false;

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    infoController.text = userInfo['info'];

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("个性签名"),
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
            height: 150, // 设置TextField的高度
            child: TextField(
              controller: infoController, // 用户名控制器
              keyboardType: TextInputType.text,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '请输入个性签名',
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
        ],
      ),
    );
  }

  void _actUser() {
    var params = {
      'info': infoController.text,
      'uid': uid,
    };
    UserApi.actUser(params, onSuccess: (res) async {
      userInfoController.setUserInfo({...userInfoController.userInfo, 'info': params['info']});
      CacheHelper.saveData(Keys.userInfo, userInfoController.userInfo);
      Navigator.pop(context);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
