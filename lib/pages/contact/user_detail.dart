import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/user.dart';

class UserDetail extends StatefulWidget {
  const UserDetail({super.key});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
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
                '/user-setting',
                arguments: talkObj,
              );
            },
          ),
        ],
      ),
      body: const UserDetailPage(),
    );
  }
}

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final TalkobjController talkobjController = Get.find();
  final UserController userController = Get.find();

  Map talkObj = {};
  Map userObj = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
      userObj = userController.getOneUser(talkObj['objId']) ?? {};
    }
  }

  List<Widget> _getTitle() {
    List<Widget> data = [];
    if (userObj['remark'] != '') {
      data.add(Text(
        '${userObj['remark']}',
        style: const TextStyle(
          fontSize: 24,
        ),
      ));
      data.add(Text('用户名: ${userObj['username']}'));
    } else {
      data.add(Text(
        '${userObj['username']}',
        style: const TextStyle(
          fontSize: 24,
        ),
      ));
    }

    data.add(Text('UID: ${userObj['uid']}'));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(20.0), // 必须与 Container 的 borderRadius 相同
            child: Image.network(
              userObj['avatar'], // 替换为你的图片URL
              width: 60.0,
              height: 60.0,
              fit: BoxFit.cover,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getTitle(),
          ),
          trailing: const Icon(
            Icons.chevron_right,
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
  }
}
