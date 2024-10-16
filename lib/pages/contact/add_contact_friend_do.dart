import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/controller/friend_group.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';
import 'package:qim/common/widget/custom_text_field.dart';

class AddContactFriendDo extends StatefulWidget {
  const AddContactFriendDo({super.key});

  @override
  State<AddContactFriendDo> createState() => _AddContactFriendDoState();
}

class _AddContactFriendDoState extends State<AddContactFriendDo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("添加好友"),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "取消",
            style: TextStyle(
              color: AppColors.textButtonColor,
              fontSize: 15,
            ),
          ),
        ),
      ),
      body: const AddContactFriendDoPage(),
    );
  }
}

class AddContactFriendDoPage extends StatefulWidget {
  const AddContactFriendDoPage({super.key});

  @override
  State<AddContactFriendDoPage> createState() => _AddContactFriendDoPageState();
}

class _AddContactFriendDoPageState extends State<AddContactFriendDoPage> {
  final FriendGroupController friendGroupController = Get.find();
  final UserInfoController userInfoController = Get.find();

  final TextEditingController _inputReasonController = TextEditingController();
  final TextEditingController _inputRemarkController = TextEditingController();

  Map userObj = {};
  int uid = 0;
  Map userInfo = {};
  Map friendGroupObj = {};

  @override
  void initState() {
    super.initState();
    userObj = Get.arguments ?? {};
    friendGroupObj = friendGroupController.getOneDefaultFriendGroup();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    _inputReasonController.text = "我是${userInfo['nickname']}";
  }

  @override
  void dispose() {
    _inputReasonController.dispose();
    _inputRemarkController.dispose();
    super.dispose();
  }

  void _joinFriend() {
    var params = {
      'fromId': uid,
      'toId': userObj['uid'],
      'reason': _inputReasonController.text,
      'remark': _inputRemarkController.text,
      'friendGroupId': friendGroupObj['friendGroupId'],
    };
    ContactFriendApi.addContactFriend(params, onSuccess: (res) {
      setState(() {});
      Navigator.pop(context);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  void _selectGroup() async {
    final result = await Navigator.pushNamed(
      context,
      '/friend-detail-setting-group',
    );
    if (result != null && result is Map) {
      setState(() {
        friendGroupObj = friendGroupController.getOneFriendGroup(result['friendGroupId']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(userObj['nickname']),
          subtitle: Text(
            userObj['info'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(userObj['avatar'] ?? ''),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "填写验证信息",
                style: TextStyle(height: 2.2),
              ),
              CustomTextField(
                controller: _inputReasonController,
                hintText: '',
                expands: true,
                maxHeight: 160,
                minHeight: 120,
                maxLines: 3,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "设置对方备注",
                style: TextStyle(height: 2),
              ),
              CustomTextField(
                controller: _inputRemarkController,
                hintText: '',
                expands: true,
                maxHeight: 160,
                minHeight: 40,
                maxLines: 1,
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          color: Colors.grey[200],
          child: ListTile(
            title: Text(
              friendGroupObj['name'],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectGroup,
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: CustomButton(
                onPressed: () {
                  _joinFriend();
                },
                text: "发送",
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
