import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/controller/friend_group.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/dialog_confirm.dart';

class FriendDetailSettingGroup extends StatefulWidget {
  const FriendDetailSettingGroup({super.key});

  @override
  State<FriendDetailSettingGroup> createState() => _FriendDetailSettingGroupState();
}

class _FriendDetailSettingGroupState extends State<FriendDetailSettingGroup> {
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final FriendGroupController friendGroupController = Get.find();
  final TextEditingController nameCtr = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map contactFriendObj = {};

  @override
  void initState() {
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    if (Get.arguments != null) {
      talkObj = Get.arguments;
      contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _doneAction(int friendGroupId) async {
    if (friendGroupId == contactFriendObj['friendGroupId']) {
      TipHelper.instance.showToast("已经在该分组中");
    }
    Navigator.pop(context, {'friendGroupId': friendGroupId});
  }

  void _editGroup({int friendGroupId = 0, String name = ""}) {
    String title = "添加分组";
    if (friendGroupId != 0) {
      title = "编辑分组";
    }
    if (name != "") {
      nameCtr.text = name;
    }
    showCustomDialog(
      title: title,
      context: context,
      content: TextField(
        controller: nameCtr,
        decoration: const InputDecoration(hintText: "分组名"),
      ),
      onConfirm: () async {
        var params = {'friendGroupId': friendGroupId, 'ownerUid': uid, 'name': nameCtr.text};
        ContactFriendApi.editContactFriendGroup(params, onSuccess: (res) async {
          friendGroupController.upsetFriendGroup(res['data']);
          saveDbFriendGroup(res['data']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("移至分组"),
      ),
      body: Obx(
        () {
          return Column(
            children: [
              ListTile(
                title: const Text("添加分组"),
                leading: const Icon(
                  Icons.add_box_outlined,
                  size: 30,
                ),
                onTap: () {
                  _editGroup();
                },
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: friendGroupController.allFriendGroups.length,
                  itemBuilder: (BuildContext context, int index) {
                    var temp = friendGroupController.allFriendGroups[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(temp["name"]),
                          trailing: contactFriendObj['friendGroupId'] == temp['friendGroupId']
                              ? const Icon(
                                  Icons.done,
                                  color: Colors.blue,
                                )
                              : null,
                          onTap: () {
                            _doneAction(temp['friendGroupId']);
                          },
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
