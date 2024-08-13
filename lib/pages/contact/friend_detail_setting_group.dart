import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact_friend.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/friend_group.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/friend.dart';
import 'package:qim/dbdata/savedbdata.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/dialog_confirm.dart';

class FriendDetailSettingGroup extends StatefulWidget {
  const FriendDetailSettingGroup({super.key});

  @override
  State<FriendDetailSettingGroup> createState() => _FriendDetailSettingGroupState();
}

class _FriendDetailSettingGroupState extends State<FriendDetailSettingGroup> {
  final TalkobjController talkobjController = Get.find();
  final FriendController friendController = Get.find();
  final FriendGroupController friendGroupController = Get.find();
  final TextEditingController nameCtr = TextEditingController();

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
    }
    super.initState();
  }

  void _doneAction(int friendGroupId) async {
    if (friendGroupId == friendObj['friendObj']) {
      TipHelper.instance.showToast("已经在该分组中");
    } else {
      friendObj['friendObj'] = friendGroupId;
      var params = {'fromId': uid, 'toId': talkObj['objId'], 'friendGroupId': friendGroupId};
      ContactFriendApi.actContactFriend(params, onSuccess: (res) async {
        Map data = {"uid": talkObj['objId'], "friendGroupId": friendGroupId};
        friendController.upsetFriend(data);
        saveDbFriend(data);
        setState(() {
          friendObj = res['data'];
        });
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    }
    Navigator.pop(context);
  }

  void _addGroup() {
    showCustomDialog(
      title: "添加分组",
      context: context,
      content: TextField(
        controller: nameCtr,
        decoration: const InputDecoration(hintText: "分组名"),
      ),
      onConfirm: () async {
        var params = {'ownerUid': uid, 'name': nameCtr.text};
        ContactFriendApi.addContactFriendGroup(params, onSuccess: (res) async {
          if (res['code'] == 0) {
            friendGroupController.upsetFriendGroup(res['data']);
            saveDbFriendGroup(res['data']);
          }
        }, onError: (res) {
          TipHelper.instance.showToast(res['msg']);
        });
      },
      onConfirmText: "添加",
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
        backgroundColor: Colors.grey[100],
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
                  _addGroup();
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
                          trailing: friendObj['friendGroupId'] == temp['friendGroupId']
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
