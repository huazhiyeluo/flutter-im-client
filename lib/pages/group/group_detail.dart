import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/utils/date.dart';
import 'package:qim/common/widget/custom_button.dart';

class GroupDetail extends StatefulWidget {
  const GroupDetail({super.key});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  Map talkObj = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
  }

  Future _operateList() {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(10.0),
            height: 120,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                title: const Text(
                  "举报",
                  textAlign: TextAlign.center,
                ),
                visualDensity: const VisualDensity(vertical: -4),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  "取消",
                  textAlign: TextAlign.center,
                ),
                visualDensity: const VisualDensity(vertical: -4),
                onTap: () {},
              ),
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _operateList();
            },
          ),
        ],
      ),
      body: const GroupDetailPage(),
    );
  }
}

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
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
    _initData();
  }

  void _initData() async {
    await initOneGroup(talkObj['objId']);
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
    return Obx(() {
      if (talkObj.isEmpty) {
        return const Center(child: Text(""));
      }
      groupObj = groupController.getOneGroup(talkObj['objId']);
      if (groupObj.isEmpty) {
        return const Center(child: Text(""));
      }
      return Column(
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
            trailing: IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () {
                Navigator.pushNamed(context, '/group-info', arguments: talkObj);
              },
            ),
            onTap: () {},
          ),
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(groupObj['info']),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.query_builder,
                      size: 18,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "建群时间: ${formatDate(groupObj['createTime'], customFormat: 'yyyy-MM-dd')}",
                      textAlign: TextAlign.left,
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: const Divider(
              height: 10,
            ),
          ),
          Expanded(child: Container()),
          Row(
            children: [
              const SizedBox(width: 25),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Map msgObj = {
                      'content': {
                        "data": json.encode({"group": groupObj})
                      },
                      'msgMedia': 23
                    };
                    Navigator.pushNamed(
                      context,
                      '/share',
                      arguments: {"ttype": 1, "msgObj": msgObj},
                    );
                  },
                  text: "分享群聊",
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              const SizedBox(width: 10), // 按钮之间的间距
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/talk',
                      arguments: talkObj,
                    );
                  },
                  text: "发消息",
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 25),
            ],
          ),
          const SizedBox(height: 30),
        ],
      );
    });
  }
}
