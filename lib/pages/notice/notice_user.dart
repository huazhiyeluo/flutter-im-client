import 'package:flutter/material.dart';
import 'package:qim/api/apply.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';

class NoticeUser extends StatefulWidget {
  const NoticeUser({super.key});

  @override
  State<NoticeUser> createState() => _NoticeUserState();
}

class _NoticeUserState extends State<NoticeUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("新朋友"),
        backgroundColor: Colors.grey[100],
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("添加"),
          ),
        ],
      ),
      body: const NoticeUserPage(),
    );
  }
}

class NoticeUserPage extends StatefulWidget {
  const NoticeUserPage({super.key});

  @override
  State<NoticeUserPage> createState() => _NoticeUserPageState();
}

class _NoticeUserPageState extends State<NoticeUserPage> {
  final TextEditingController inputController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  List _applys = [];

  @override
  void initState() {
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    _fetchData();
    super.initState();
  }

  void _fetchData() async {
    await _getApplyList();
  }

  Widget _getStatusWidget(bool isFrom, int status) {
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
              onPressed: () {},
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
              onPressed: () {},
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
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _applys.length > 5 ? 5 : _applys.length,
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
                trailing: _getStatusWidget(isFrom, _applys[index]['status']),
              );
            },
          ),
        ),
        ListTile(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("查看更多"),
              Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/notice-user-detail',
            );
          },
        ),
        Expanded(
          child: Container(),
        )
      ],
    );
  }

  Future<void> _getApplyList() async {
    var params = {
      'uid': uid,
      'type': 1,
    };
    ApplyApi.getApplyList(params, onSuccess: (res) {
      setState(() {
        _applys = res['data'];
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
