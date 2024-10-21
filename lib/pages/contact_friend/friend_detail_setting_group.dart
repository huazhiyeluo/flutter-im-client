import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/controller/friend_group.dart';
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
  final UserInfoController userInfoController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final FriendGroupController friendGroupController = Get.find();
  final TextEditingController _nameController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map contactFriendObj = {};

  bool isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    talkObj = Get.arguments ?? {};

    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    if (talkObj.isNotEmpty) {
      contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  void _selectGroup(int friendGroupId) async {
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
      _nameController.text = name;
    }
    showCustomDialog(
      title: title,
      context: context,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Stack(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: "分组名"),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                ],
                onChanged: (val) {
                  // 每次输入变化时都调用 setState 来更新字数显示
                  setState(() {});
                },
              ),
              Positioned(
                right: 0,
                bottom: 1,
                child: Text(
                  "${_nameController.text.characters.length}/15字",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      onConfirm: () async {
        isButtonEnabled ? _doneAction(friendGroupId) : null;
      },
      onConfirmText: "确定",
      onCancel: () {
        // 处理取消逻辑
      },
      onCancelText: "取消",
    );
  }

  void _doneAction(int friendGroupId) {
    if (!isButtonEnabled) return;
    setState(() {
      isButtonEnabled = false;
    });

    if (_nameController.text.trim() == "") {
      TipHelper.instance.showToast("请输入名称");
      setState(() {
        isButtonEnabled = true;
      });
      return;
    }
    var params = {'friendGroupId': friendGroupId, 'ownerUid': uid, 'name': _nameController.text};
    ContactFriendApi.editContactFriendGroup(params, onSuccess: (res) async {
      friendGroupController.upsetFriendGroup(res['data']);
      saveDbFriendGroup(res['data']);
      isButtonEnabled = true;
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
      isButtonEnabled = true;
    });
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
                            _selectGroup(temp['friendGroupId']);
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
