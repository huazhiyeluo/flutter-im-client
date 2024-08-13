import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/friend.dart';

class FriendDetail extends StatefulWidget {
  const FriendDetail({super.key});

  @override
  State<FriendDetail> createState() => _FriendDetailState();
}

class _FriendDetailState extends State<FriendDetail> {
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
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/friend-detail-setting',
                arguments: talkObj,
              );
            },
          ),
        ],
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
  final TalkobjController talkobjController = Get.find();
  final FriendController friendController = Get.find();

  Map talkObj = {};
  Map friendObj = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
  }

  List<Widget> _getTitle() {
    List<Widget> data = [];
    if (friendObj['remark'] != '') {
      data.add(Text(
        '${friendObj['remark']}',
        style: const TextStyle(
          fontSize: 24,
        ),
      ));
      data.add(Text('用户名: ${friendObj['username']}'));
    } else {
      data.add(Text(
        '${friendObj['username']}',
        style: const TextStyle(
          fontSize: 24,
        ),
      ));
    }

    data.add(Text('QID: ${friendObj['uid']}'));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      friendObj = friendController.getOneFriend(talkObj['objId'])!;
      return ListView(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(20.0), // 必须与 Container 的 borderRadius 相同
              child: Image.network(
                friendObj['avatar'], // 替换为你的图片URL
                width: 60.0,
                height: 60.0,
                fit: BoxFit.cover,
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
            onTap: () {},
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: const Divider(
              height: 10,
            ),
          ),
          TextButton.icon(
            onPressed: () {
              talkobjController.setTalkObj(talkObj);
              Navigator.pushNamed(
                context,
                '/talk',
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
          TextButton.icon(
            onPressed: () {
              talkobjController.setTalkObj(talkObj);
              Navigator.pushNamed(
                context,
                '/talk',
                arguments: {"actionType": 1},
              );
            },
            label: const Text(
              "音视频通话",
              style: TextStyle(fontSize: 20),
            ),
            icon: const Icon(Icons.phone),
          ),
        ],
      );
    });
  }
}
