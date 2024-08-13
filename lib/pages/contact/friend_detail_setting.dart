import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/friend_group.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/friend.dart';
import 'package:qim/widget/custom_button.dart';

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
        backgroundColor: Colors.grey[100],
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
  final FriendController friendController = Get.find();
  final FriendGroupController friendGroupController = Get.find();

  Map talkObj = {};
  Map friendObj = {};
  Map friendGroupObj = {};

  @override
  void initState() {
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      friendObj = friendController.getOneFriend(talkObj['objId'])!;
      friendGroupObj = friendGroupController.getOneFriendGroup(friendObj['friendGroupId'])!;
      return ListView(
        children: [
          ListTile(
            title: const Text('备注'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  friendObj['remark'] != "" ? friendObj['remark'] : '未设置',
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
            onTap: () {
              Navigator.pushNamed(
                context,
                '/friend-detail-setting-group',
                arguments: talkObj,
              );
            },
          ),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: CustomButton(
                  onPressed: () {},
                  text: "删除好友",
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
              '被骚扰了？举报该用户',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      );
    });
  }
}
