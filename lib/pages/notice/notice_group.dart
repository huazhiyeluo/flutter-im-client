import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/apply.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/apply.dart';
import 'package:qim/dbdata/deldbdata.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';

class NoticeGroup extends StatefulWidget {
  const NoticeGroup({super.key});

  @override
  State<NoticeGroup> createState() => _NoticeGroupState();
}

class _NoticeGroupState extends State<NoticeGroup> {
  final ApplyController applyController = Get.find();

  void _clearApply() {
    applyController.clearApply(2);
    delDbApply(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("群通知"),
        backgroundColor: Colors.grey[100],
        actions: [
          TextButton(
            onPressed: () {
              _clearApply();
            },
            child: const Text("清空"),
          ),
        ],
      ),
      body: const NoticeGroupPage(),
    );
  }
}

class NoticeGroupPage extends StatefulWidget {
  const NoticeGroupPage({super.key});

  @override
  State<NoticeGroupPage> createState() => _NoticeGroupPageState();
}

class _NoticeGroupPageState extends State<NoticeGroupPage> {
  final ApplyController applyController = Get.find();
  int uid = 0;
  Map userInfo = {};

  List _applys = [];

  @override
  void initState() {
    ever(applyController.allGroupChats, (_) => _formatData());
    _formatData();

    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchData() async {
    await _getApplyList();
  }

  void _formatData() {
    if (!mounted) return;
    setState(() {
      _applys = applyController.allGroupChats;
    });
  }

  Widget _getStatusWidget(bool isFrom, int status, int id) {
    if (isFrom) {
      if (status == 0) {
        return const Text("等待验证");
      }
      if (status == 1) {
        return const Text("已被同意");
      }
      if (status == 2) {
        return const Text("已被拒绝");
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
                Radius.circular(10),
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
                Radius.circular(10),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                title: Text(_applys[index]['toName']),
                subtitle: isFrom
                    ? Text("请求加入群，附言：${_applys[index]['reason']}")
                    : Text("${_applys[index]['fromName']} 请求加入群，附言：${_applys[index]['reason']}"),
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

  Future<void> _getApplyList() async {
    if (applyController.allFriendChats.isEmpty) {
      List applys = await DBHelper.getData('apply', [
        ['type', '=', 2]
      ]);
      for (var item in applys) {
        Map<String, dynamic> temp = Map.from(item);
        applyController.upsetApply(temp);
      }
    }
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
