import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/tips.dart';

class FriendDetailSettingRemark extends StatefulWidget {
  const FriendDetailSettingRemark({super.key});

  @override
  State<FriendDetailSettingRemark> createState() => _FriendDetailSettingRemarkState();
}

class _FriendDetailSettingRemarkState extends State<FriendDetailSettingRemark> {
  final UserInfoController userInfoController = Get.find();
  final ChatController chatController = Get.find();
  final ContactFriendController contactFriendController = Get.find();

  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map contactFriendObj = {};

  @override
  void initState() {
    super.initState();
    talkObj = Get.arguments ?? {};
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
    _remarkController.text = contactFriendObj['remark'];
    _descController.text = contactFriendObj['desc'];
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _doneAction() async {
    var params = {'fromId': uid, 'toId': talkObj['objId'], 'remark': _remarkController.text, "desc": _descController.text};
    ContactFriendApi.actContactFriend(params, onSuccess: (res) async {
      Map data = {"fromId": uid, "toId": talkObj['objId'], "remark": _remarkController.text, "desc": _descController.text};
      contactFriendController.upsetContactFriend(data);
      saveDbContactFriend(data);

      Map chat = chatController.getOneChat(talkObj['objId'], 1);
      if (chat.isNotEmpty) {
        Map chatData = {};
        chatData['objId'] = talkObj['objId'];
        chatData['type'] = 1;
        chatData['remark'] = _remarkController.text;
        chatData['desc'] = _descController.text;
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
                child: Stack(
                  children: [
                    TextField(
                      controller: _remarkController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: const InputDecoration(
                        hintText: '填写备注名',
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Text(
                        "${_remarkController.text.characters.length}/15字",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
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
                child: Stack(
                  children: [
                    TextField(
                      controller: _descController,
                      textAlignVertical: TextAlignVertical.center,
                      minLines: 1,
                      maxLines: 10,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(500),
                      ],
                      decoration: const InputDecoration(
                        hintText: '填写描述',
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Text(
                        "${_descController.text.characters.length}/500字",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
