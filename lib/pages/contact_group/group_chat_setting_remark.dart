import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';

class GroupChatSettingRemark extends StatefulWidget {
  const GroupChatSettingRemark({super.key});

  @override
  State<GroupChatSettingRemark> createState() => _GroupChatSettingRemarkState();
}

class _GroupChatSettingRemarkState extends State<GroupChatSettingRemark> {
  final UserInfoController userInfoController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  final GroupController groupController = Get.find();

  final UserController userController = Get.find();
  final ChatController chatController = Get.find();

  final TextEditingController _remarkController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map contactGroupObj = {};
  Map groupObj = {};

  int characterCount = 0;

  @override
  void initState() {
    super.initState();
    talkObj = Get.arguments ?? {};
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    groupObj = groupController.getOneGroup(talkObj['objId']);
    contactGroupObj = contactGroupController.getOneContactGroup(uid, talkObj['objId']);
    _remarkController.text = contactGroupObj['remark'];
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  _doneAction() async {
    var params = {'fromId': uid, 'toId': talkObj['objId'], 'remark': _remarkController.text};
    ContactGroupApi.actContactGroup(params, onSuccess: (res) async {
      Map data = {'fromId': uid, 'toId': talkObj['objId'], 'remark': _remarkController.text};
      contactGroupController.upsetContactGroup(data);
      saveDbContactGroup(data);

      Map chat = chatController.getOneChat(talkObj['objId'], 2);
      if (chat.isNotEmpty) {
        Map chatData = {};
        chatData['objId'] = talkObj['objId'];
        chatData['type'] = ObjectTypes.group;
        chatData['remark'] = _remarkController.text;
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
                child: Stack(
                  children: [
                    TextField(
                      controller: _remarkController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: const InputDecoration(
                        hintText: '填写群聊备注',
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                    Positioned(
                      right: 0,
                      bottom: 1,
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
                  _remarkController.text = groupObj['name'];
                  setState(() {});
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
