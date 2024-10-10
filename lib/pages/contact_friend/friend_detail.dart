import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/common.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/data/api/getdata.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/controller/signaling.dart';
import 'package:qim/data/db/get.dart';

class FriendDetail extends StatefulWidget {
  const FriendDetail({super.key});

  @override
  State<FriendDetail> createState() => _FriendDetailState();
}

class _FriendDetailState extends State<FriendDetail> {
  final UserInfoController userInfoController = Get.find();
  final ContactFriendController contactFriendController = Get.find();

  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
  }

  List<Widget> _getAction() {
    List<Widget> list = [];
    final contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
    if (contactFriendObj.isNotEmpty) {
      list.add(IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/friend-detail-setting',
            arguments: talkObj,
          );
        },
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _getAction(),
      ),
      body: const FriendDetailPage(),
    );
  }
}

class FriendDetailPage extends StatefulWidget {
  const FriendDetailPage({super.key});

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {
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
    initOneUser(talkObj['objId']);
  }

  List<Widget> _getTitle() {
    List<Widget> data = [];
    if (contactFriendObj.isNotEmpty && contactFriendObj['remark'] != '') {
      data.add(Text(
        '${contactFriendObj['remark']}',
        style: const TextStyle(
          fontSize: 24,
        ),
      ));
      data.add(Text('昵称: ${userObj['nickname']}'));
    } else {
      data.add(Text(
        '${userObj['nickname']}',
        style: const TextStyle(
          fontSize: 24,
        ),
      ));
    }
    data.add(Text('QID: ${userObj['uid']}'));
    return data;
  }

  //邀请
  void _invite() async {
    Map talkCommonObj = {};
    talkCommonObj['objId'] = talkObj['objId'];
    talkCommonObj['icon'] = userObj['avatar'];
    talkCommonObj['name'] = userObj['nickname'];
    talkCommonObj['num'] = 1;
    signalingController.invite(talkCommonObj);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (talkObj.isEmpty) {
        return const Center(child: Text(""));
      }
      userObj = userController.getOneUser(talkObj['objId']);
      if (userObj.isEmpty) {
        return const Center(child: Text("1111"));
      }
      contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
      return ListView(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CachedNetworkImage(
                imageUrl: userObj['avatar'],
                width: 60.0,
                height: 60.0,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _getTitle(),
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text("朋友圈"),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text("更多信息"),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/friend-detail-more',
                arguments: talkObj,
              );
            },
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: const Divider(
              height: 10,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/talk',
                arguments: talkObj,
              );
            },
            label: const Text(
              "发消息",
              style: TextStyle(fontSize: 20),
            ),
            icon: const Icon(Icons.chat),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: const Divider(),
          ),
          talkObj['objId'] != uid
              ? TextButton.icon(
                  onPressed: () {
                    _invite();
                  },
                  label: const Text(
                    "视频通话",
                    style: TextStyle(fontSize: 20),
                  ),
                  icon: const Icon(Icons.phone),
                )
              : Container(),
          contactFriendObj.isEmpty && talkObj['objId'] != uid
              ? Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: const Divider(),
                )
              : Container(),
          contactFriendObj.isEmpty && talkObj['objId'] != uid
              ? TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/add-contact-friend-do',
                      arguments: userObj,
                    );
                  },
                  label: const Text(
                    "添加好友",
                    style: TextStyle(fontSize: 20),
                  ),
                  icon: const Icon(Icons.person_add_alt),
                )
              : Container(),
        ],
      );
    });
  }
}
