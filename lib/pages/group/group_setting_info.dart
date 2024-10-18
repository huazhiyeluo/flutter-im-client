import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/tips.dart';

class GroupSettingInfo extends StatefulWidget {
  const GroupSettingInfo({super.key});

  @override
  State<GroupSettingInfo> createState() => _GroupSettingInfoState();
}

class _GroupSettingInfoState extends State<GroupSettingInfo> {
  final UserInfoController userInfoController = Get.find();
  final GroupController groupController = Get.find();

  final UserController userController = Get.find();

  final TextEditingController _infoController = TextEditingController();

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
    _infoController.text = groupObj['info'];
    characterCount = _infoController.text.characters.length;
  }

  @override
  void dispose() {
    _infoController.dispose();
    super.dispose();
  }

  _doneAction() async {
    var params = {'groupId': talkObj['objId'], 'info': _infoController.text};
    GroupApi.actGroup(params, onSuccess: (res) async {
      Map data = {'groupId': talkObj['objId'], 'info': _infoController.text};
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
        title: const Text("群聊介绍"),
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
            controller: _infoController,
            minLines: 1,
            maxLines: null,
            inputFormatters: [
              LengthLimitingTextInputFormatter(500),
            ],
            decoration: const InputDecoration(
              hintText: '填写群介绍',
            ),
            onChanged: (val) {
              setState(() {
                characterCount = val.characters.length;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            "$characterCount/500字",
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
