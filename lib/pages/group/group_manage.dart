import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';

class GroupManager extends StatefulWidget {
  const GroupManager({super.key});

  @override
  State<GroupManager> createState() => _GroupManagerState();
}

class _GroupManagerState extends State<GroupManager> with TickerProviderStateMixin {
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final ContactGroupController contactGroupController = Get.find();

  final UserController userController = Get.find();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map contactGroupObj = {};
  List contactGroups = [];
  bool isShowEdit = true;
  int num = 0;
  int total = 0;

  Map<int, SlidableController> slidableControllers = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    contactGroupObj = contactGroupController.getOneContactGroup(uid, talkObj['objId']);
  }

  void _clearSlidable() {

    slidableControllers.forEach((key, tempSlidable) {
      tempSlidable.close();
    });
  }

  @override
  void dispose() {
    _clearSlidable();
    super.dispose();
  }

  void _delGroupManager(int fromId) {
    var params = {'fromId': fromId, 'toId': talkObj['objId']};
    ContactGroupApi.delGroupManger(params, onSuccess: (res) async {
      contactGroupController.upsetContactGroup(res['data']);
      saveDbContactGroup(res['data']);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  Widget _getOwner() {
    late Widget temp;

    for (var contactGroup in contactGroups) {
      if (contactGroup['groupPower'] == 2) {
        Map userObj = userController.getOneUser(contactGroup['fromId']);
        temp = ListTile(
          title: Text(contactGroup['nickname'] != '' ? contactGroup['nickname'] : userObj['nickname']),
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(
              userObj['avatar'],
            ),
          ),
        );
      }
    }
    return temp;
  }

  List<Widget> _getManager() {
    List<Widget> temp = [];
    for (var contactGroup in contactGroups) {
      if (contactGroup['groupPower'] == 1) {
        Map userObj = userController.getOneUser(contactGroup['fromId']);

        if (!slidableControllers.containsKey(contactGroup['fromId'])) {
          slidableControllers[contactGroup['fromId']] = SlidableController(this);
        }

        temp.add(Slidable(
          key: ValueKey(contactGroup['fromId']),
          controller: slidableControllers[contactGroup['fromId']],
          useTextDirection: false,
          enabled: contactGroupObj['groupPower'] == 2,
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 1.2 / 4,
            children: [
              CustomSlidableAction(
                onPressed: (slidCtx) {
                  _delGroupManager(contactGroup['fromId']);
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 水平居中对齐
                  children: [
                    Text(
                      '取消管理员',
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              children: [
                !isShowEdit
                    ? const SizedBox(
                        width: 15,
                      )
                    : const SizedBox(
                        width: 15,
                      ),
                Visibility(
                  visible: !isShowEdit,
                  child: IconButton(
                    visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                    onPressed: () {
                      slidableControllers[contactGroup['fromId']]?.openEndActionPane();
                    },
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ),
                ),
                Visibility(
                  visible: !isShowEdit,
                  child: const SizedBox(
                    width: 10,
                  ),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(
                    userObj['avatar'],
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  contactGroup['nickname'] != '' ? contactGroup['nickname'] : userObj['nickname'],
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(contactGroupObj['groupPower'] == 2 ? "设置管理员" : "查看管理员"),
        actions: [
          contactGroupObj['groupPower'] == 2
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      isShowEdit = !isShowEdit;
                    });
                  },
                  child: Text(
                    isShowEdit ? "编辑" : "完成",
                    style: const TextStyle(color: Colors.black87),
                  ),
                )
              : Container(),
        ],
      ),
      body: Obx(() {
        contactGroups = contactGroupController.allContactGroups[talkObj['objId']] ?? RxList<Map>.from([]);
        if (contactGroups.length - 1 > 5) {
          total = 5;
        } else {
          total = contactGroups.length - 1;
        }
        num = 0;
        for (var contactGroup in contactGroups) {
          if (contactGroup['groupPower'] == 1) {
            num++;
          }
        }
        // 这里确保在获取 contactGroups 之后重新初始化控制器
        return ListView(
          padding: const EdgeInsets.all(10),
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
              child: const Text("群主"),
            ),
            Container(
              color: Colors.white,
              child: _getOwner(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
              child: Text("管理员($num/$total)"),
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ..._getManager(),
                  const Divider(),
                  total > num && contactGroupObj['groupPower'] == 2
                      ? Align(
                          alignment: Alignment.centerLeft, // 左对齐
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/group-manager-add', arguments: talkObj);
                            },
                            label: const Text(
                              "添加管理员",
                              style: TextStyle(color: Colors.black87),
                            ),
                            icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
