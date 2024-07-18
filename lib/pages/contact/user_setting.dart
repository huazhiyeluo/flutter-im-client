import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/widget/custom_button.dart';

class UserSetting extends StatefulWidget {
  const UserSetting({super.key});

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
        backgroundColor: Colors.grey[100],
      ),
      body: const UserSettingPage(),
    );
  }
}

class UserSettingPage extends StatefulWidget {
  const UserSettingPage({super.key});

  @override
  State<UserSettingPage> createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  final TalkobjController talkobjController = Get.find();
  final UserController userController = Get.find();

  Map talkObj = {};
  Map userObj = {};

  @override
  void initState() {
    if (Get.arguments != null) {
      talkObj = Get.arguments;
      userObj = userController.getOneUser(talkObj['objId'])!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('备注'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(userObj['remark'] != "" ? userObj['remark'] : '未设置'),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/user-setting-remark',
              arguments: talkObj,
            );
          },
        ),
        ListTile(
          title: const Text('分组'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(userObj['friendGroupId'] != 0 ? userObj['remark'] : '默认分组'),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {},
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
  }
}
