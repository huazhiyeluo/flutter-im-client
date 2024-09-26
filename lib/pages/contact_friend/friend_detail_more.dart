import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/contact_friend.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/controller/userinfo.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/controller/signaling.dart';
import 'package:qim/utils/functions.dart';

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
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    if (Get.arguments != null) {
      talkObj = Get.arguments;
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
      logPrint(userObj);
      contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
      return ListView(
        children: [
          ListTile(
            title: const Text("个性签名"),
            trailing: Text(userObj['info']),
            onTap: () {},
          ),
          ListTile(
            title: const Text("加入好友时间"),
            trailing: Text("${contactFriendObj['joinTime']}"),
            onTap: () {},
          ),
        ],
      );
    });
  }
}
