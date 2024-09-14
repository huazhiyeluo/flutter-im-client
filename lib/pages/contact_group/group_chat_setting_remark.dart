import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact_group.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/contact_group.dart';
import 'package:qim/controller/group.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/controller/userinfo.dart';
import 'package:qim/dbdata/savedbdata.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';

class GroupChatSettingRemark extends StatefulWidget {
  const GroupChatSettingRemark({super.key});

  @override
  State<GroupChatSettingRemark> createState() => _GroupChatSettingRemarkState();
}

class _GroupChatSettingRemarkState extends State<GroupChatSettingRemark> {
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  final GroupController groupController = Get.find();

  final UserController userController = Get.find();
  final ChatController chatController = Get.find();

  final TextEditingController remarkCtr = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map contactGroupObj = {};
  Map groupObj = {};

  int characterCount = 0;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    groupObj = groupController.getOneGroup(talkObj['objId']);
    contactGroupObj = contactGroupController.getOneContactGroup(uid, talkObj['objId']);
    remarkCtr.text = contactGroupObj['remark'];
    characterCount = remarkCtr.text.characters.length;
  }

  @override
  void dispose() {
    remarkCtr.dispose();
    super.dispose();
  }

  _doneAction() async {
    var params = {'fromId': uid, 'toId': talkObj['objId'], 'remark': remarkCtr.text};
    ContactGroupApi.actContactGroup(params, onSuccess: (res) async {
      Map data = {'fromId': uid, 'toId': talkObj['objId'], 'remark': remarkCtr.text};
      contactGroupController.upsetContactGroup(data);
      saveDbContactGroup(data);

      Map chat = chatController.getOneChat(talkObj['objId'], 2);
      if (chat.isNotEmpty) {
        Map chatData = {};
        chatData['objId'] = talkObj['objId'];
        chatData['type'] = 2;
        chatData['remark'] = remarkCtr.text;
        chatController.upsetChat(chatData);
        saveDbChat(chatData);
      }

      Navigator.pop(context);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const SizedBox(height: 20),
          const Text(
            "群聊备注",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "备注后的群聊名称仅自己可见",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40.0),
                child: CachedNetworkImage(
                  imageUrl: groupObj['icon'],
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: remarkCtr,
                  decoration: const InputDecoration(
                    hintText: '填写群聊备注',
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    setState(() {
                      characterCount = val.characters.length;
                    });
                  },
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "群名称: ${groupObj['name']}",
                textAlign: TextAlign.end,
              ),
              TextButton(
                onPressed: () {
                  remarkCtr.text = groupObj['name'];
                },
                child: const Text(
                  "填入",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          CustomButton(
            onPressed: () {
              _doneAction();
            },
            text: "完成",
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}
