import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo({super.key});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
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
      body: const GroupInfoPage(),
      backgroundColor: Colors.grey[200],
    );
  }
}

class GroupInfoPage extends StatefulWidget {
  const GroupInfoPage({super.key});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final GroupController groupController = Get.find();

  final UserController userController = Get.find();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map groupObj = {};

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
      '${groupObj['name']}',
      style: const TextStyle(
        fontSize: 24,
      ),
    ));
    data.add(Text('群号: ${groupObj['groupId']}'));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Obx(() {
      if (talkObj.isEmpty) {
        return const Center(child: Text(""));
      }
      groupObj = groupController.getOneGroup(talkObj['objId']);
      Map result = {};
      result['type'] = 2;
      result['content'] = {"groupId": talkObj['objId']};

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
                      imageUrl: groupObj['icon'],
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
          const Text("扫一扫二维码，加入群聊"),
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
