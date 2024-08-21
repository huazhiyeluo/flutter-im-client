import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact_group.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/contact_group.dart';
import 'package:qim/controller/group.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/controller/userinfo.dart';
import 'package:qim/dbdata/savedbdata.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';
import 'package:qim/widget/dialog_confirm.dart';

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
        backgroundColor: Colors.grey[100],
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
  final TalkobjController talkobjController = Get.find();
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

  @override
  void initState() {
    talkObj = talkobjController.talkObj;
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    groupObj = groupController.getOneGroup(talkObj['objId'])!;
    contactGroupObj = contactGroupController.getOneContactGroup(uid, talkObj['objId'])!;

    _fetchData();
    super.initState();
  }

  void _fetchData() async {
    await getGroupInfo(talkObj['objId']);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final contactGroups = contactGroupController.allContactGroups[talkObj['objId']] ?? RxList<Map>.from([]);
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
            onTap: () {},
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
              itemCount: contactGroups.length > 15 ? 15 : contactGroups.length,
              itemBuilder: (BuildContext context, int index) {
                Map userObj = userController.getOneUser(contactGroups[index]['fromId'])!;
                return Container(
                  height: 90,
                  alignment: Alignment.center,
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
                      ), // 添加一个间距
                      Text(
                        contactGroups[index]['remark'] != "" ? contactGroups[index]['remark'] : userObj['nickname'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
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
            onTap: () {},
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            title: const Text("群号"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${groupObj['groupId']}'),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {},
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const Divider(),
          ),
          ListTile(
            title: const Text("群公告"),
            subtitle: Text(groupObj['info'] ?? ''),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: () {},
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
            onTap: () {},
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
            onTap: () {},
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
                  text: uid == groupObj['ownerUid'] ? "解散群聊" : "退出群聊",
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
          ['fromId', '=', uid]
        ]);
        await DBHelper.deleteData('message', [
          ['msgType', '=', talkObj['type']],
          ['toId', '=', uid],
          ['fromId', '=', talkObj['objId']]
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
          Map? chat = chatController.getOneChat(talkObj['objId'], 2);
          if (chat != null) {
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
            (route) => false,
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
