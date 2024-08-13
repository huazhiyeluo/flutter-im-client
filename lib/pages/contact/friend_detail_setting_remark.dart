import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact_friend.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/friend.dart';
import 'package:qim/dbdata/savedbdata.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/tips.dart';

class FriendDetailSettingRemark extends StatefulWidget {
  const FriendDetailSettingRemark({super.key});

  @override
  State<FriendDetailSettingRemark> createState() => _FriendDetailSettingRemarkState();
}

class _FriendDetailSettingRemarkState extends State<FriendDetailSettingRemark> {
  final TalkobjController talkobjController = Get.find();
  final FriendController friendController = Get.find();

  final TextEditingController remarkCtr = TextEditingController();
  final TextEditingController descCtr = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map friendObj = {};

  @override
  void initState() {
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    if (Get.arguments != null) {
      talkObj = Get.arguments;
      friendObj = friendController.getOneFriend(talkObj['objId'])!;
      remarkCtr.text = friendObj['remark'];
      descCtr.text = friendObj['desc'];
    }
    super.initState();
  }

  _doneAction() async {
    var params = {'fromId': uid, 'toId': talkObj['objId'], 'remark': remarkCtr.text, "desc": descCtr.text};
    ContactFriendApi.actContactFriend(params, onSuccess: (res) async {
      Map data = {"uid": talkObj['objId'], "remark": remarkCtr.text, "desc": descCtr.text};
      friendController.upsetFriend(data);
      saveDbFriend(data);
      setState(() {
        friendObj = res['data'];
      });
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
                child: Text("描述"),
              ),
              Expanded(
                child: TextField(
                  controller: descCtr,
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 5,
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
