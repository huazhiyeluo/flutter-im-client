import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/tips.dart';

class GroupChatSettingNickname extends StatefulWidget {
  const GroupChatSettingNickname({super.key});

  @override
  State<GroupChatSettingNickname> createState() => _GroupChatSettingNicknameState();
}

class _GroupChatSettingNicknameState extends State<GroupChatSettingNickname> {
  final UserInfoController userInfoController = Get.find();
  final ContactGroupController contactGroupController = Get.find();

  final UserController userController = Get.find();

  final TextEditingController nicknameCtr = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map contactGroupObj = {};

  int characterCount = 0;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    contactGroupObj = contactGroupController.getOneContactGroup(uid, talkObj['objId']);
    nicknameCtr.text = contactGroupObj['nickname'];
    characterCount = nicknameCtr.text.characters.length;
  }

  @override
  void dispose() {
    nicknameCtr.dispose();
    super.dispose();
  }

  _doneAction() async {
    var params = {'fromId': uid, 'toId': talkObj['objId'], 'nickname': nicknameCtr.text};
    ContactGroupApi.actContactGroup(params, onSuccess: (res) async {
      Map data = {'fromId': uid, 'toId': talkObj['objId'], 'nickname': nicknameCtr.text};
      contactGroupController.upsetContactGroup(data);
      saveDbContactGroup(data);
      Navigator.pop(context);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("编辑群昵称"),
        actions: [
          TextButton(
            onPressed: _doneAction,
            child: const Text("完成"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          TextField(
            controller: nicknameCtr,
            decoration: const InputDecoration(
              hintText: '填写群昵称',
            ),
            onChanged: (val) {
              setState(() {
                characterCount = val.characters.length;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            "$characterCount/50字",
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
