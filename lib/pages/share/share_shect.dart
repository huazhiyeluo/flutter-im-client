import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/friend_group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/controller/websocket.dart';
import 'package:qim/common/widget/custom_search_field.dart';

class ShareSelect extends StatefulWidget {
  const ShareSelect({super.key});

  @override
  State<ShareSelect> createState() => _ShareSelectState();
}

class _ShareSelectState extends State<ShareSelect> {
  final TextEditingController inputController = TextEditingController();
  final UserInfoController userInfoController = Get.find();
  final UserController userController = Get.find();
  final FriendGroupController friendGroupController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final GroupController groupController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  final ScrollController _scrollController = ScrollController();
  final WebSocketController webSocketController = Get.find();

  int uid = 0;
  Map userInfo = {};

  double picWidth = 45;
  double screenWidth = 0;
  double leftWidth = 0;
  double rightWidth = 0;

  List _cateArrs = [];
  List<Map> _userSelectArrs = [];
  Map<int, bool> _status = <int, bool>{};
  Set<int> processedFromIds = {};

  @override
  void initState() {
    super.initState();

    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });
    _formatData();
  }

  // 自动滚动到最右边的方法
  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _search() {
    for (var v in _cateArrs) {
      for (var val in v["children"]) {
        if (val['name'].contains(inputController.text) ||
            val['remark'].contains(inputController.text) ||
            val['objId'].toString().contains(inputController.text)) {
          val['isHidden'] = false;
        } else {
          val['isHidden'] = true;
        }
      }
    }
    setState(() {
      _cateArrs = _cateArrs;
    });
  }

  void _formatData() {
    _cateArrs.clear();
    _cateArrs = List.from(friendGroupController.allFriendGroups);
    for (var friendGroupObj in _cateArrs) {
      _status[friendGroupObj['friendGroupId']] = false;
      friendGroupObj['children'] = [];
      friendGroupObj['controller'] = ExpansionTileController();
      for (var contactFriendObj in contactFriendController.allContactFriends) {
        if (contactFriendObj['friendGroupId'] == friendGroupObj['friendGroupId']) {
          if (friendGroupObj['children'] == null) {
            friendGroupObj['children'] = [];
          }
          Map userObj = userController.getOneUser(contactFriendObj['toId']);
          contactFriendObj['type'] = 1;
          contactFriendObj['objId'] = contactFriendObj['toId'];
          contactFriendObj['name'] = userObj['nickname'];
          contactFriendObj['remark'] = contactFriendObj['remark'];
          contactFriendObj['icon'] = userObj['avatar'];
          contactFriendObj['info'] = userObj['info'];
          contactFriendObj['isSelect'] = false;
          contactFriendObj['isHidden'] = false;
          friendGroupObj['children'].add(contactFriendObj);
        }
      }
    }

    var groupArrs = {
      "name": "群聊",
      "friendGroupId": 0,
      "ownerUid": 34,
      "isDefault": 1,
      "sort": 0,
      "controller": ExpansionTileController(),
      "children": []
    };
    _status[0] = false;
    for (var groupObj in groupController.allGroups) {
      Map temp = {};

      temp['friendGroupId'] = 0;
      temp['type'] = 2;
      temp['objId'] = groupObj['groupId'];
      temp['name'] = groupObj['name'];
      temp['remark'] = groupObj['name'];
      temp['icon'] = groupObj['icon'];
      temp['info'] = groupObj['info'];
      temp['isSelect'] = false;
      temp['isHidden'] = false;
      (groupArrs['children'] as List).add(temp);
    }

    _cateArrs.insert(0, groupArrs);

    setState(() {
      _cateArrs = _cateArrs;
      _status = _status;
    });
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  void selectGroup(int key) {
    bool tempStatus = !_status[key]!;
    for (var item in _cateArrs) {
      if (item['friendGroupId'] == key) {
        _status[key] = tempStatus;
        for (var it in item['children']) {
          if (!it['isHidden']) {
            it['isSelect'] = tempStatus;
            _getSelect(it, tempStatus);
          }
        }
      }
    }
    setState(() {
      _cateArrs = _cateArrs;
      _status = _status;
    });
  }

  void setSelected(int key, int objId, int type) {
    bool tempStatus = false;
    for (var item in _cateArrs) {
      if (item['friendGroupId'] == key) {
        for (var it in item['children']) {
          if (it['objId'] == objId && it['type'] == type) {
            it['isSelect'] = !it['isSelect'];
            _getSelect(it, it['isSelect']);

            if (it['isSelect']) {
              tempStatus = true;
            }
          }
        }
      }
    }
    _status[key] = tempStatus;

    setState(() {
      _cateArrs = _cateArrs;
      _status = _status;
    });
  }

  void _getSelect(Map item, bool flag) {
    if (flag) {
      _userSelectArrs.add(item);
    } else {
      final existingIndex = _userSelectArrs.indexWhere((c) => c['objId'] == item['objId'] && c['type'] == item['type']);
      if (existingIndex != -1) {
        _userSelectArrs.removeAt(existingIndex);
      }
    }
    setState(() {
      _userSelectArrs = _userSelectArrs;
    });
  }

  List<Widget> _getSelectAll() {
    List<Widget> lists = [];
    for (var map in _userSelectArrs) {
      if (map['isSelect']) {
        lists.add(Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(
              map['icon'],
            ),
          ),
        ));
      }
    }
    return lists;
  }

  List<Widget> _getContentAll() {
    List<Widget> lists = [];
    for (var item in _cateArrs) {
      List visibleData = item['children'].where((it) => !it['isHidden']).toList();

      Widget temp = Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          controller: item['controller'],
          title: GestureDetector(
            child: Text("${item['name']} (${visibleData.length}${item['friendGroupId'] == 0 ? '个' : '人'})"),
            onTapDown: (TapDownDetails details) {},
            onTapUp: (TapUpDetails details) {
              setState(() {
                if (item['controller'].isExpanded) {
                  item['controller'].collapse(); // 收起
                } else {
                  item['controller'].expand(); // 展开
                }
              });
            },
          ),
          onExpansionChanged: (value) => {},
          controlAffinity: ListTileControlAffinity.leading,
          trailing: TextButton(
            onPressed: () {
              selectGroup(item['friendGroupId']);
            },
            child: _status[item['friendGroupId']] == false ? const Text("选择") : const Text("取消选择"),
          ),
          children: visibleData.map((item) {
            return InkWell(
              onTap: () {
                setSelected(item['friendGroupId'], item['objId'], item['type']);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        value: item['isSelect'],
                        onChanged: (bool? value) {
                          setSelected(item['friendGroupId'], item['objId'], item['type']);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(
                        item['icon'],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(item['name']),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
      lists.add(temp);
    }
    return lists;
  }

  _doneAction() async {
    Navigator.pop(context, {'_userSelectArrs': _userSelectArrs});
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      screenWidth = MediaQuery.of(context).size.width;
      leftWidth = _userSelectArrs.length * picWidth + 1;
      if (leftWidth > screenWidth - 120 - 35) {
        leftWidth = screenWidth - 120 - 35;
      }
      rightWidth = screenWidth - 35 - leftWidth;
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("选择联系人"),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("取消"),
        ),
        actions: [
          TextButton(
            onPressed: _doneAction,
            child: Text("完成(${_userSelectArrs.length})"),
          ),
        ],
      ),
      body: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                // 左侧的横向滚动区域，占据整行的最大 5/6
                SizedBox(
                  width: leftWidth,
                  child: SizedBox(
                    height: 40, // 设置高度以保证滚动区域可见
                    child: ListView(
                      scrollDirection: Axis.horizontal, // 横向滚动
                      controller: _scrollController,
                      children: _getSelectAll(),
                    ),
                  ),
                ),
                // 右侧的搜索框，占据整行的最小 1/6
                SizedBox(
                  width: rightWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CustomSearchField(
                      controller: inputController,
                      hintText: '搜索',
                      expands: false,
                      maxHeight: 40,
                      minHeight: 40,
                      onSubmitted: (val) {
                        _search();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: _getContentAll(),
        ),
      ),
    );
  }
}
