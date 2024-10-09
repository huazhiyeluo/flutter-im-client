import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/tips.dart';

class FriendDetailSettingRemark extends StatefulWidget {
  const FriendDetailSettingRemark({super.key});

  @override
  State<FriendDetailSettingRemark> createState() => _FriendDetailSettingRemarkState();
}

class _FriendDetailSettingRemarkState extends State<FriendDetailSettingRemark> {
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final ChatController chatController = Get.find();

  final UserController userController = Get.find();
  final ContactFriendController contactFriendController = Get.find();

  final TextEditingController remarkCtr = TextEditingController();
  final TextEditingController descCtr = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map contactFriendObj = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    if (Get.arguments != null) {
      talkObj = Get.arguments;

      contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
      remarkCtr.text = contactFriendObj['remark'];
      descCtr.text = contactFriendObj['desc'];
    }
  }

  @override
  void dispose() {
    remarkCtr.dispose();
    descCtr.dispose();
    super.dispose();
  }

  _doneAction() async {
    var params = {'fromId': uid, 'toId': talkObj['objId'], 'remark': remarkCtr.text, "desc": descCtr.text};
    ContactFriendApi.actContactFriend(params, onSuccess: (res) async {
      Map data = {"fromId": uid, "toId": talkObj['objId'], "remark": remarkCtr.text, "desc": descCtr.text};
      contactFriendController.upsetContactFriend(data);
      saveDbContactFriend(data);

      Map chat = chatController.getOneChat(talkObj['objId'], 1);
      if (chat.isNotEmpty) {
        Map chatData = {};
        chatData['objId'] = talkObj['objId'];
        chatData['type'] = 1;
        chatData['remark'] = remarkCtr.text;
        chatData['desc'] = descCtr.text;
        chatController.upsetChat(chatData);
        saveDbChat(chatData);
      }

      if (!mounted) return;
      setState(() {
        contactFriendObj = res['data'];
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
                  minLines: 1,
                  maxLines: null,
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
