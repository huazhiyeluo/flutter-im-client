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

class UserDetailInfo extends StatefulWidget {
  const UserDetailInfo({super.key});

  @override
  State<UserDetailInfo> createState() => _UserDetailInfoState();
}

class _UserDetailInfoState extends State<UserDetailInfo> {
  final UserInfoController userInfoController = Get.find();
  final TextEditingController _infoController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  final FocusNode _focusNode1 = FocusNode();
  bool _isFocusNode1 = false;

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    _infoController.text = userInfo['info'];

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
    _infoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("个性签名"),
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
                  minLines: 1,
                  maxLines: 10,
                  controller: _infoController,
                  hintText: '请输入个性签名',
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(100),
                  ],
                  focusedColor: const Color.fromARGB(255, 60, 183, 21),
                  unfocusedColor: Colors.grey,
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
                Positioned(
                  right: 0,
                  bottom: 1,
                  child: Text(
                    "${_infoController.text.characters.length}/100字",
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
        ],
      ),
    );
  }

  void _actUser() {
    var params = {
      'info': _infoController.text,
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
