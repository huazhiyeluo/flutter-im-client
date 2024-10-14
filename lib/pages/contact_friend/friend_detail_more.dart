import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/controller/signaling.dart';
import 'package:qim/common/utils/date.dart';

class FriendDetailMore extends StatefulWidget {
  const FriendDetailMore({super.key});

  @override
  State<FriendDetailMore> createState() => _FriendDetailMoreState();
}

class _FriendDetailMoreState extends State<FriendDetailMore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("更多信息"),
      ),
      body: const FriendDetailMorePage(),
    );
  }
}

class FriendDetailMorePage extends StatefulWidget {
  const FriendDetailMorePage({super.key});

  @override
  State<FriendDetailMorePage> createState() => _FriendDetailMorePageState();
}

class _FriendDetailMorePageState extends State<FriendDetailMorePage> {
  final SignalingController signalingController = Get.find();
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();

  final UserController userController = Get.find();
  final ContactFriendController contactFriendController = Get.find();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map userObj = {};
  Map contactFriendObj = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    initOneUser(talkObj['objId']);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (talkObj.isEmpty) {
        return const Center(child: Text("1"));
      }
      userObj = userController.getOneUser(talkObj['objId']);
      if (userObj.isEmpty) {
        return const Center(child: Text("2"));
      }
      logPrint(userObj);
      contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
      return ListView(
        children: [
          ListTile(
            leading: const Text(
              "个性签名",
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              userObj['info'],
              style: const TextStyle(fontSize: 14),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
            onTap: () {},
          ),
          contactFriendObj.isNotEmpty && contactFriendObj['joinTime'] > 0
              ? ListTile(
                  leading: const Text(
                    "加好友时间",
                    style: TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    formatDate(contactFriendObj['joinTime']),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.end,
                  ),
                  onTap: () {},
                )
              : Container(),
        ],
      );
    });
  }
}
