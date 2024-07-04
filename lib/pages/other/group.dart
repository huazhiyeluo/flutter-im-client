import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_button.dart';

class Group extends StatefulWidget {
  const Group({super.key});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("群聊设置"),
        backgroundColor: Colors.grey[100],
      ),
      body: const GroupPage(),
    );
  }
}

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final TalkobjController talkobjController = Get.find();

  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};

  List _groupUsers = [];
  Map _groupInfo = {
    "groupId": 0,
    "ownerUid": 0,
    "name": "",
    "icon": "https://im.guiaihai.com/static/images/6d6c0e2553734c6c43b54405c9bbf90f.jpg",
    "info": "",
    "num": 0,
    "exp": 0,
    "createTime": 0,
    "groupPower": 0,
    "level": 0,
    "remark": "",
    "nickname": "",
    "isTop": 0,
    "isHidden": 0,
    "isQuiet": 0,
    "joinTime": 0
  };

  @override
  void initState() {
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    talkObj = talkobjController.talkObj;
    _fetchData();
    super.initState();
  }

  void _fetchData() async {
    await _getGroupInfo();
    await _getGroupUser();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(_groupInfo['name'] ?? ''),
          subtitle: Text(_groupInfo['info'] ?? ''),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(_groupInfo['icon'] ?? ''),
          ),
          trailing: const Icon(
            Icons.chevron_right,
          ),
          onTap: () {},
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          title: const Text('群聊成员'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('查看${_groupUsers.length}名群成员'),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(context, '/group-user', arguments: _groupUsers);
          },
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // 禁止滚动
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // 设置每行显示的列数
              crossAxisSpacing: 10.0, // 列之间的间距
              mainAxisSpacing: 10.0, // 行之间的间距
              childAspectRatio: 1.0, // 宽高比
            ),
            itemCount: _groupUsers.length > 15 ? 15 : _groupUsers.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 90, // 固定高度，使得内容可以完全显示
                alignment: Alignment.center,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(_groupUsers[index]['avatar']),
                    ),
                    const SizedBox(
                      height: 1,
                    ), // 添加一个间距
                    Text(
                      _groupUsers[index]['username'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ListTile(
          title: const Text('群聊名称'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_groupInfo['name'] ?? ''),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {},
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          title: const Text("群号"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${_groupInfo['groupId']}'),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {},
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          title: const Text("群公告"),
          subtitle: Text(_groupInfo['info'] ?? ''),
          trailing: const Icon(
            Icons.chevron_right,
          ),
          onTap: () {},
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          title: const Text("我在本群昵称"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_groupInfo['nickname'] == null || _groupInfo['nickname'] == "" ? '未设置' : _groupInfo['nickname']),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {},
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          title: const Text("群聊备注"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_groupInfo['remark'] == null || _groupInfo['remark'] == "" ? '未设置' : _groupInfo['remark']),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {},
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          title: const Text("查找聊天记录"),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('图片、视频、文件'),
              Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {},
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          title: const Text("设为置顶"),
          trailing: Switch(
            value: _groupInfo['isTop'] == 1 ? true : false,
            onChanged: (bool value) {},
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          title: const Text("隐藏会话"),
          trailing: Switch(
            value: _groupInfo['isHidden'] == 1 ? true : false,
            onChanged: (bool value) {},
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          title: const Text("消息免打扰"),
          trailing: Switch(
            value: _groupInfo['isQuiet'] == 1 ? true : false,
            onChanged: (bool value) {},
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          title: Text("删除聊天记录"),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: CustomButton(
                onPressed: () {},
                text: "退出群聊",
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
            '被骚扰了？举报该群',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _getGroupUser() async {
    var params = {
      'groupId': talkObj['objId'],
    };
    ContactApi.getGroupUser(params, onSuccess: (res) {
      setState(() {
        _groupUsers = res['data'];
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  Future<void> _getGroupInfo() async {
    var params = {
      'fromId': uid,
      'toId': talkObj['objId'],
    };
    ContactApi.getGroupOne(params, onSuccess: (res) {
      setState(() {
        _groupInfo = res['data'];
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
