import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/controller/friend_group.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/del.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/dialog_confirm.dart';

class FriendGroup extends StatefulWidget {
  const FriendGroup({super.key});

  @override
  State<FriendGroup> createState() => _FriendGroupState();
}

class _FriendGroupState extends State<FriendGroup> {
  final UserInfoController userInfoController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final FriendGroupController friendGroupController = Get.find();

  final TextEditingController _nameController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};

  @override
  void initState() {
    super.initState();
    talkObj = Get.arguments ?? {};
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  void _editGroup({int friendGroupId = 0, String name = ""}) {
    String title = "添加分组";
    if (friendGroupId != 0) {
      title = "编辑分组";
    }
    _nameController.text = name;
    showCustomDialog(
      title: title,
      context: context,
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(hintText: "分组名"),
      ),
      onConfirm: () async {
        var params = {'friendGroupId': friendGroupId, 'ownerUid': uid, 'name': _nameController.text};
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

  Future _operateList(int friendGroupId) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(10.0),
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text(
                    "删除该分组后，组内联系人将移至默认分组。",
                    textAlign: TextAlign.center,
                  ),
                  visualDensity: VisualDensity(vertical: -4),
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    "删除分组",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                  onTap: () {
                    _doneDeleteGroup(friendGroupId);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    "取消",
                    textAlign: TextAlign.center,
                  ),
                  visualDensity: const VisualDensity(vertical: -4),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
              ],
            ),
          );
        });
  }

  void _doneDeleteGroup(int friendGroupId) {
    var params = {'friendGroupId': friendGroupId};
    ContactFriendApi.delContactFriendGroup(params, onSuccess: (res) async {
      delDbFriendGroup(friendGroupId);
      friendGroupController.delFriendGroup(friendGroupId);
      updateDbContactFriendByFriendGroupId(friendGroupId, {"friendGroupId": res['data']['friendGroupId']});
      contactFriendController.upsetContactFriendByFriendGroupId(friendGroupId, {"friendGroupId": res['data']['friendGroupId']});
      Navigator.pop(context);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  void _sortGroup() {
    List<Map> datas = [];
    friendGroupController.allFriendGroups.asMap().forEach((key, value) {
      datas.add({"friendGroupId": value['friendGroupId'], "sort": key});
    });
    var params = {'data': datas};
    ContactFriendApi.sortContactFriendGroup(params, onSuccess: (res) async {}, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("分组管理"),
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
                child: ReorderableListView(
                  buildDefaultDragHandles: true,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex--;
                      }
                      final item = friendGroupController.allFriendGroups.removeAt(oldIndex);
                      friendGroupController.allFriendGroups.insert(newIndex, item);
                      _sortGroup();
                    });
                  },
                  children: List.generate(friendGroupController.allFriendGroups.length, (index) {
                    var temp = friendGroupController.allFriendGroups[index];
                    return ListTile(
                      key: ValueKey(temp['friendGroupId']),
                      title: GestureDetector(
                        child: Text(temp["name"]),
                        onLongPress: () {},
                      ),
                      trailing: temp['isDeleteStatus'] != null && temp['isDeleteStatus']
                          ? TextButton(
                              onPressed: () {
                                _operateList(temp['friendGroupId']);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.zero, // 去掉 padding
                                minimumSize: const Size(40, 25), // 控制最小宽高
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 减小点击区域
                              ),
                              child: const Text(
                                "删除",
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 7, 0),
                              child: Icon(Icons.menu),
                            ),
                      leading: IconButton(
                        padding: EdgeInsets.zero, // 设置为零填充
                        iconSize: 25,
                        visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        onPressed: () {
                          setState(() {
                            if (temp['isDeleteStatus'] == null) {
                              temp['isDeleteStatus'] = false;
                            }
                            temp['isDeleteStatus'] = !temp['isDeleteStatus'];
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      ),
                      onTap: () {
                        _editGroup(friendGroupId: temp['friendGroupId'], name: temp["name"]);
                      },
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
