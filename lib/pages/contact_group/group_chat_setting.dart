import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/message.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/db.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';
import 'package:qim/common/widget/dialog_confirm.dart';

class GroupChatSetting extends StatefulWidget {
  const GroupChatSetting({super.key});

  @override
  State<GroupChatSetting> createState() => _GroupChatSettingState();
}

class _GroupChatSettingState extends State<GroupChatSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("群聊设置"),
      ),
      body: const GroupChatSettingPage(),
    );
  }
}

class GroupChatSettingPage extends StatefulWidget {
  const GroupChatSettingPage({super.key});

  @override
  State<GroupChatSettingPage> createState() => _GroupChatSettingPageState();
}

class _GroupChatSettingPageState extends State<GroupChatSettingPage> {
  final UserInfoController userInfoController = Get.find();
  final ChatController chatController = Get.find();
  final MessageController messageController = Get.find();
  final GroupController groupController = Get.find();
  final UserController userController = Get.find();
  final ContactGroupController contactGroupController = Get.find();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map groupObj = {};
  Map contactGroupObj = {};

  int optShow = 1;

  List contactGroups = [];

  @override
  void initState() {
    super.initState();
    talkObj = Get.arguments ?? {};
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    contactGroupObj = contactGroupController.getOneContactGroup(uid, talkObj['objId']);
    if ([GroupPowers.admin, GroupPowers.owner].contains(contactGroupObj['groupPower'])) {
      optShow = 2;
    }
    _initData();
  }

  void _initData() async {
    await getGroupInfo(talkObj['objId']);
    await initOneGroup(talkObj['objId']);
  }

  List<Widget> _getManager() {
    List<Widget> temp = [];
    for (var contactGroup in contactGroups) {
      if (contactGroup['groupPower'] == GroupPowers.owner) {
        Map userObj = userController.getOneUser(contactGroup['fromId']);
        temp.add(
          CircleAvatar(
            radius: 10,
            backgroundImage: CachedNetworkImageProvider(
              userObj['avatar'],
            ),
          ),
        );
      }
      if (contactGroup['groupPower'] == GroupPowers.admin) {
        Map userObj = userController.getOneUser(contactGroup['fromId']);
        temp.add(
          CircleAvatar(
            radius: 10,
            backgroundImage: CachedNetworkImageProvider(
              userObj['avatar'],
            ),
          ),
        );
      }
    }
    temp.add(
      const Icon(Icons.chevron_right),
    );
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      groupObj = groupController.getOneGroup(talkObj['objId']);
      contactGroups = contactGroupController.allContactGroups[talkObj['objId']] ?? RxList<Map>.from([]);
      int count = contactGroups.length >= 15 - optShow ? 15 : contactGroups.length + optShow;

      if (contactGroups.isEmpty) {
        return const Center(child: Text(""));
      }
      return ListView(
        children: [
          ListTile(
            title: Text(groupObj['name'] ?? ''),
            subtitle: Text(
              groupObj['info'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(groupObj['icon'] ?? ''),
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/group-detail', arguments: talkObj);
            },
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            title: const Text('群聊成员'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('查看${contactGroups.length}名群成员'),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/group-user', arguments: talkObj);
            },
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              itemCount: count,
              itemBuilder: (BuildContext context, int index) {
                if (index >= count - optShow) {
                  if (index == count - optShow) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/group-user-invite',
                          arguments: talkObj,
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          const Text(
                            "邀请",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  } else if (index == count - optShow + 1) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/group-user-delete',
                          arguments: talkObj,
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 30,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          const Text(
                            "移除",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  Map userObj = userController.getOneUser(contactGroups[index]['fromId']);
                  return Container(
                    height: 90,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        Map talkObj = {
                          "objId": contactGroups[index]['fromId'],
                          "type": ObjectTypes.user,
                        };
                        Navigator.pushNamed(
                          context,
                          '/friend-detail',
                          arguments: talkObj,
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: CachedNetworkImageProvider(
                              userObj['avatar'],
                            ),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            contactGroups[index]['nickname'] != "" ? contactGroups[index]['nickname'] : userObj['nickname'],
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('群聊名称'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(groupObj['name'] ?? ''),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/group-setting-name',
                arguments: talkObj,
              );
            },
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            title: const Text("群号和二维码"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${groupObj['groupId']}'),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/group-info', arguments: talkObj);
            },
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            title: const Text("群介绍"),
            subtitle: Text(
              groupObj['info'] ?? '',
              textAlign: TextAlign.justify,
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/group-setting-info', arguments: talkObj);
            },
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            title: const Text("我在本群昵称"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(contactGroupObj['nickname'] == "" ? '未设置' : contactGroupObj['nickname']),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/group-chat-setting-nickname', arguments: talkObj);
            },
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            title: const Text("群聊备注"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(contactGroupObj['remark'] == "" ? '未设置' : contactGroupObj['remark']),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/group-chat-setting-remark', arguments: talkObj);
            },
          ),
          ListTile(
            title: Text(contactGroupObj['groupPower'] == 2 ? "设置管理员" : "查看管理员"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: _getManager(),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/group-manager', arguments: talkObj);
            },
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            title: const Text("查找聊天记录"),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('图片、视频、文件'),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {},
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            title: const Text("设为置顶"),
            trailing: Switch(
              value: contactGroupObj['isTop'] == 1 ? true : false,
              onChanged: (bool val) {
                int v = val == true ? 1 : 0;
                _actContact('isTop', v);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            title: const Text("隐藏会话"),
            trailing: Switch(
              value: contactGroupObj['isHidden'] == 1 ? true : false,
              onChanged: (bool val) {
                int v = val == true ? 1 : 0;
                _actContact('isHidden', v);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            title: const Text("消息免打扰"),
            trailing: Switch(
              value: contactGroupObj['isQuiet'] == 1 ? true : false,
              onChanged: (bool val) {
                int v = val == true ? 1 : 0;
                _actContact('isQuiet', v);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            title: const Text("删除聊天记录"),
            onTap: _delMessage,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    _delContact();
                  },
                  text: [2].contains(contactGroupObj['groupPower']) ? "解散群聊" : "退出群聊",
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              '被骚扰了？举报该群',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      );
    });
  }

  void _delMessage() {
    showCustomDialog(
      context: context,
      content: Text(
        '确定要删除在【${groupObj['name'] ?? ''}】里的聊天记录吗？',
        style: const TextStyle(fontSize: 18),
      ),
      onConfirm: () async {
        await DBHelper.deleteData('message', [
          ['msgType', '=', talkObj['type']],
          ['toId', '=', talkObj['objId']],
        ]);
        messageController.delMessage(talkObj['type'], uid, talkObj['objId']);
        TipHelper.instance.showToast("删除成功");
      },
      onConfirmText: "清空",
      onCancel: () {
        // 处理取消逻辑
      },
      onCancelText: "取消",
    );
  }

  void _actContact(String field, int value) {
    var params = {
      'fromId': uid,
      'toId': talkObj['objId'],
      field: value,
    };
    ContactGroupApi.actContactGroup(params, onSuccess: (res) {
      if (!mounted) return;
      setState(() {
        contactGroupObj[field] = res['data'][field];
        contactGroupController.upsetContactGroup(res['data']);
        saveDbContactGroup(res['data']);

        if (["isTop", "isHidden", "isQuiet"].contains(field)) {
          Map chat = chatController.getOneChat(talkObj['objId'], 2);
          if (chat.isNotEmpty) {
            Map chatData = {};
            chatData['objId'] = talkObj['objId'];
            chatData['type'] = 2;
            chatData[field] = res['data'][field];
            chatController.upsetChat(chatData);
            saveDbChat(chatData);
          }
        }
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  void _delContact() {
    showCustomDialog(
      context: context,
      content: const Text(
        '确定要退出该群吗？删除后将清理聊天记录。',
        style: TextStyle(fontSize: 18),
      ),
      onConfirm: () async {
        var params = {
          'fromId': uid,
          'toId': talkObj['objId'],
        };
        ContactGroupApi.quitContactGroup(params, onSuccess: (res) {
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
}
