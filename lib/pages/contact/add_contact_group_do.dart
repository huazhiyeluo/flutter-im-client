import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';
import 'package:qim/common/widget/custom_text_field.dart';

class AddContactGroupDo extends StatefulWidget {
  const AddContactGroupDo({super.key});

  @override
  State<AddContactGroupDo> createState() => _AddContactGroupDoState();
}

class _AddContactGroupDoState extends State<AddContactGroupDo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("申请加群"),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("取消"),
        ),
      ),
      body: const AddContactGroupDoPage(),
    );
  }
}

class AddContactGroupDoPage extends StatefulWidget {
  const AddContactGroupDoPage({super.key});

  @override
  State<AddContactGroupDoPage> createState() => _AddContactGroupDoPageState();
}

class _AddContactGroupDoPageState extends State<AddContactGroupDoPage> {
  final TextEditingController _inputReasonController = TextEditingController();
  final TextEditingController _inputRemarkController = TextEditingController();
  final TextEditingController _inputInfoController = TextEditingController();

  final UserInfoController userInfoController = Get.find();

  Map groupObj = {};
  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    if (Get.arguments != null) {
      groupObj = Get.arguments;
    }
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    _inputReasonController.text = "我是${userInfo['nickname']}";
    super.initState();
  }

  _joinGroup() {
    var params = {
      'fromId': uid,
      'toId': groupObj['groupId'],
      'reason': _inputReasonController.text,
      'remark': _inputRemarkController.text,
      'info': _inputInfoController.text,
    };
    ContactGroupApi.joinContactGroup(params, onSuccess: (res) {
      setState(() {});
      Navigator.pop(context);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(groupObj['name']),
          subtitle: Text(
            groupObj['info'],
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(groupObj['icon'] ?? ''),
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
                minHeight: 80,
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
                "设置群备注",
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
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "入群后在群聊中发送进群介绍(选填)",
                style: TextStyle(height: 2),
              ),
              CustomTextField(
                controller: _inputInfoController,
                hintText: '',
                expands: true,
                maxHeight: 160,
                minHeight: 40,
                maxLines: 4,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    _joinGroup();
                  },
                  text: "发送",
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
