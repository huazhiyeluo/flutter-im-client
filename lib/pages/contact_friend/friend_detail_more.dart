import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/common/utils/functions.dart';
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
    talkObj = Get.arguments ?? {};
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    _initData();
  }

  void _initData() async {
    await initOneUser(talkObj['objId']);
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
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
            child: Row(
              children: [
                const SizedBox(
                  width: 120,
                  child: Text(
                    "个性签名",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95 - 150,
                  child: Text(
                    userObj['info'],
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          contactFriendObj.isNotEmpty && contactFriendObj['joinTime'] > 0 ? const Divider() : Container(),
          contactFriendObj.isNotEmpty && contactFriendObj['joinTime'] > 0
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text(
                          "加好友时间",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.95 - 150,
                        child: Text(
                          formatDate(contactFriendObj['joinTime']),
                          style: const TextStyle(fontSize: 14),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      );
    });
  }
}
