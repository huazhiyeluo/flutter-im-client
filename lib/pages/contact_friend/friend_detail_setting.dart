import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/controller/friend_group.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';
import 'package:qim/common/widget/dialog_confirm.dart';

class FriendDetailSetting extends StatefulWidget {
  const FriendDetailSetting({super.key});

  @override
  State<FriendDetailSetting> createState() => _FriendDetailSettingState();
}

class _FriendDetailSettingState extends State<FriendDetailSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
      ),
      body: const FriendDetailSettingPage(),
    );
  }
}

class FriendDetailSettingPage extends StatefulWidget {
  const FriendDetailSettingPage({super.key});

  @override
  State<FriendDetailSettingPage> createState() => _FriendDetailSettingPageState();
}

class _FriendDetailSettingPageState extends State<FriendDetailSettingPage> {
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();

  final UserController userController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final FriendGroupController friendGroupController = Get.find();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map userObj = {};
  Map contactFriendObj = {};
  Map friendGroupObj = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    _initData();
  }

  void _initData() async {
    await initOneUser(talkObj['objId']);
  }

  void _delContact() {
    showCustomDialog(
      context: context,
      content: const Text(
        '确定要删除该好友吗？删除后将清理聊天记录。',
        style: TextStyle(fontSize: 18),
      ),
      onConfirm: () async {
        var params = {
          'fromId': uid,
          'toId': talkObj['objId'],
        };
        ContactFriendApi.delContactFriend(params, onSuccess: (res) {
          talkobjController.setTalkObj({});
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            ModalRoute.withName('/'),
          );
        }, onError: (res) {
          TipHelper.instance.showToast(res['msg']);
        });
      },
      onConfirmText: "确定",
      onCancel: () {
        // 处理取消逻辑
      },
      onCancelText: "取消",
    );
  }

  void _selectGroup() async {
    final result = await Navigator.pushNamed(
      context,
      '/friend-detail-setting-group',
      arguments: talkObj,
    );
    if (result != null && result is Map) {
      var params = {'fromId': uid, 'toId': talkObj['objId'], 'friendGroupId': result['friendGroupId']};
      ContactFriendApi.actContactFriend(params, onSuccess: (res) async {
        Map data = {"fromId": uid, "toId": talkObj['objId'], "friendGroupId": result['friendGroupId']};
        contactFriendController.upsetContactFriend(data);
        saveDbContactFriend(data);
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (talkObj.isEmpty) {
        return const Center(child: Text(""));
      }
      userObj = userController.getOneUser(talkObj['objId']);
      if (userObj.isEmpty) {
        return const Center(child: Text(""));
      }

      contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
      if (contactFriendObj.isEmpty) {
        return const Center(child: Text(""));
      }
      friendGroupObj = friendGroupController.getOneFriendGroup(contactFriendObj['friendGroupId']);
      if (friendGroupObj.isEmpty) {
        return const Center(child: Text(""));
      }
      return ListView(
        children: [
          ListTile(
            title: const Text('备注'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  contactFriendObj['remark'] != "" ? contactFriendObj['remark'] : '未设置',
                  style: const TextStyle(fontSize: 15),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/friend-detail-setting-remark',
                arguments: talkObj,
              );
            },
          ),
          ListTile(
            title: const Text('分组'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  friendGroupObj['name'],
                  style: const TextStyle(fontSize: 15),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: _selectGroup,
          ),
          Container(
            height: 10,
            color: Colors.grey[200],
          ),
          ListTile(
            title: const Text('推荐给朋友'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Map msgObj = {
                'content': {
                  "data": json.encode({"user": userObj})
                },
                'msgMedia': 22
              };
              Navigator.pushNamed(
                context,
                '/share',
                arguments: {"ttype": 1, "msgObj": msgObj},
              );
            },
          ),
          Container(
            height: 10,
            color: Colors.grey[200],
          ),
          talkObj['objId'] != uid
              ? Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          _delContact();
                        },
                        text: "删除好友",
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                )
              : Container(),
          talkObj['objId'] != uid
              ? TextButton(
                  onPressed: () {},
                  child: const Text(
                    '被骚扰了？举报该用户',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              : Container(),
        ],
      );
    });
  }
}
