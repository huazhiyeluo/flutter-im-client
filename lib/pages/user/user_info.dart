import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  Map talkObj = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const UserInfoPage(),
      backgroundColor: Colors.grey[200],
    );
  }
}

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();

  final UserController userController = Get.find();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map userObj = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
  }

  List<Widget> _getTitle() {
    List<Widget> data = [];
    data.add(Text(
      '${userObj['nickname']}',
      style: const TextStyle(
        fontSize: 24,
      ),
    ));
    data.add(Text('UID: ${userObj['uid']}'));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Obx(() {
      if (talkObj.isEmpty) {
        return const Center(child: Text(""));
      }
      userObj = userController.getOneUser(talkObj['objId']);
      Map result = {};
      result['type'] = 1;
      result['content'] = {"uid": talkObj['objId']};

      return Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(60.0),
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
                ),
                const SizedBox(
                  height: 10,
                ),
                QrImageView(
                  data: jsonEncode(result),
                  version: QrVersions.auto,
                  size: screenSize.width * 0.75,
                  backgroundColor: Colors.white, // 设置二维码背景色
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          Expanded(child: Container()),
          const Text("扫一扫二维码，加好友"),
          const SizedBox(
            height: 20,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.download,
                    size: 40,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("保存"),
                ],
              ),
              Column(
                children: [
                  Icon(
                    Icons.share,
                    size: 40,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("分享"),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      );
    });
  }
}
