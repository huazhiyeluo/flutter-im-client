import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/api/apply.dart';
import 'package:qim/data/controller/apply.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/del.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_button.dart';

class NoticeFriendDetail extends StatefulWidget {
  const NoticeFriendDetail({super.key});

  @override
  State<NoticeFriendDetail> createState() => _NoticeFriendDetailState();
}

class _NoticeFriendDetailState extends State<NoticeFriendDetail> {
  final ApplyController applyController = Get.find();

  void _clearApply() {
    applyController.clearApply(1);
    delDbApply(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("好友通知"),
        actions: [
          TextButton(
            onPressed: () {
              _clearApply();
            },
            child: const Text(
              "清空",
              style: TextStyle(
                color: AppColors.textButtonColor,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: const NoticeFriendDetailPage(),
    );
  }
}

class NoticeFriendDetailPage extends StatefulWidget {
  const NoticeFriendDetailPage({super.key});

  @override
  State<NoticeFriendDetailPage> createState() => _NoticeFriendDetailPageState();
}

class _NoticeFriendDetailPageState extends State<NoticeFriendDetailPage> {
  final ApplyController applyController = Get.find();
  final UserInfoController userInfoController = Get.find();

  int uid = 0;
  Map userInfo = {};

  List _applys = [];

  @override
  void initState() {
    ever(applyController.allFriendApplys, (_) => _formatData());
    _formatData();

    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _formatData() {
    if (!mounted) return;
    setState(() {
      _applys = applyController.allFriendApplys;
    });
  }

  Widget _getStatusWidget(bool isFrom, int status, int id) {
    if (isFrom) {
      if (status == 0) {
        return const Text(
          "等待验证",
          style: TextStyle(fontSize: 14),
        );
      }
      if (status == 1) {
        return const Text(
          "已被同意",
          style: TextStyle(fontSize: 14),
        );
      }
      if (status == 2) {
        return const Text(
          "已被拒绝",
          style: TextStyle(fontSize: 14),
        );
      }
    } else {
      if (status == 0) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              onPressed: () {
                _operateApply(id, 1);
              },
              text: "同意",
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(0),
              textStyle: const TextStyle(fontSize: 14),
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
            ),
            const SizedBox(width: 8), // Add some spacing between the buttons
            CustomButton(
              onPressed: () {
                _operateApply(id, 2);
              },
              text: "拒绝",
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(0),
              textStyle: const TextStyle(fontSize: 14),
              borderRadius: const BorderRadius.all(
                Radius.circular(5),
              ),
            ),
          ],
        );
      }
      if (status == 1) {
        return const Text(
          "已同意",
          style: TextStyle(fontSize: 14),
        );
      }
      if (status == 2) {
        return const Text(
          "已拒绝",
          style: TextStyle(fontSize: 14),
        );
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _applys.length,
            itemBuilder: (BuildContext context, int index) {
              bool isFrom = uid == _applys[index]['fromId'];
              return ListTile(
                title: Text(isFrom ? _applys[index]['toName'] : _applys[index]['fromName']),
                subtitle: Text(_applys[index]['reason']),
                leading: CircleAvatar(
                  // 聊天对象的头像
                  radius: 20,
                  backgroundImage: NetworkImage(isFrom ? _applys[index]['toIcon'] : _applys[index]['fromIcon']),
                ),
                trailing: _getStatusWidget(isFrom, _applys[index]['status'], _applys[index]['id']),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _operateApply(int id, int status) async {
    var params = {
      'id': id,
      'status': status,
    };
    ApplyApi.operateApply(params, onSuccess: (res) {}, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
