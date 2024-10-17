import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/tips.dart';

class GroupSettingName extends StatefulWidget {
  const GroupSettingName({super.key});

  @override
  State<GroupSettingName> createState() => _GroupSettingNameState();
}

class _GroupSettingNameState extends State<GroupSettingName> {
  final UserInfoController userInfoController = Get.find();
  final GroupController groupController = Get.find();

  final UserController userController = Get.find();

  final TextEditingController _nameController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map groupObj = {};

  int characterCount = 0;

  @override
  void initState() {
    super.initState();
    talkObj = Get.arguments ?? {};
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    groupObj = groupController.getOneGroup(talkObj['objId']);
    _nameController.text = groupObj['name'];
    characterCount = _nameController.text.characters.length;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  _doneAction() async {
    var params = {'groupId': talkObj['objId'], 'name': _nameController.text};
    GroupApi.actGroup(params, onSuccess: (res) async {
      Map data = {'groupId': talkObj['objId'], 'name': _nameController.text};
      groupController.upsetGroup(data);
      saveDbGroup(data);
      Navigator.pop(context);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("群聊名称"),
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
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: '填写群名称',
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
