import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/tips.dart';

class UserSettingRemark extends StatefulWidget {
  const UserSettingRemark({super.key});

  @override
  State<UserSettingRemark> createState() => _UserSettingRemarkState();
}

class _UserSettingRemarkState extends State<UserSettingRemark> {
  final TalkobjController talkobjController = Get.find();
  final UserController userController = Get.find();

  final TextEditingController remarkCtr = TextEditingController();
  final TextEditingController phoneCtr = TextEditingController();
  final TextEditingController descCtr = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map userObj = {};

  @override
  void initState() {
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    if (Get.arguments != null) {
      talkObj = Get.arguments;
      userObj = userController.getOneUser(talkObj['objId'])!;
      remarkCtr.text = userObj['remark'];
    }
    super.initState();
  }

  _doneAction() async {
    var params = {
      'fromId': uid,
      'toId': talkObj['objId'],
      'remark': remarkCtr.text,
    };
    ContactApi.actContactFriend(params, onSuccess: (res) async {
      userController.upsetUser({"uid": talkObj['objId'], "remark": remarkCtr.text});
      Navigator.pop(context);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("修改备注"),
        backgroundColor: Colors.grey[100],
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
          Row(
            children: [
              const SizedBox(
                width: 50,
                child: Text("备注名"),
              ),
              Expanded(
                child: TextField(
                  controller: remarkCtr,
                  decoration: const InputDecoration(
                    hintText: '填写备注名',
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 50,
                child: Text("电话"),
              ),
              Expanded(
                child: TextField(
                  controller: phoneCtr,
                  decoration: const InputDecoration(
                    hintText: '填写电话',
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              const SizedBox(
                width: 50,
                child: Text("描述"),
              ),
              Expanded(
                child: TextField(
                  controller: descCtr,
                  decoration: const InputDecoration(
                    hintText: '填写描述',
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
