import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/friend_group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/controller/websocket.dart';
import 'package:qim/common/utils/date.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_search_field.dart';

class GroupUserInvite extends StatefulWidget {
  const GroupUserInvite({super.key});

  @override
  State<GroupUserInvite> createState() => _GroupUserInviteState();
}

class _GroupUserInviteState extends State<GroupUserInvite> {
  final UserInfoController userInfoController = Get.find();
  final UserController userController = Get.find();
  final FriendGroupController friendGroupController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final GroupController groupController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  final WebSocketController webSocketController = Get.find();

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _inputController = TextEditingController();

  late Offset _tapPosition;

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  double picWidth = 45;
  double screenWidth = 0;
  double leftWidth = 0;
  double rightWidth = 0;

  List contactGroups = [];

  List _userArrs = [];
  List<Map> _userSelectArrs = [];
  Map<int, bool> _status = <int, bool>{};
  Set<int> processedFromIds = {};

  @override
  void initState() {
    super.initState();
    talkObj = Get.arguments ?? {};
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });
    _formatData();
  }

  @override
  void dispose() {
    super.dispose();
    _inputController.dispose();
  }

  // 自动滚动到最右边的方法
  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _formatData() {
    contactGroups = contactGroupController.allContactGroups[talkObj['objId']] ?? RxList<Map>.from([]);

    _userArrs.clear();
    _userArrs = List.from(friendGroupController.allFriendGroups);
    for (var friendGroupObj in _userArrs) {
      _status[friendGroupObj['friendGroupId']] = false;
      friendGroupObj['children'] = [];
      friendGroupObj['controller'] = ExpansionTileController();
      for (var contactFriendObj in contactFriendController.allContactFriends) {
        if (contactFriendObj['friendGroupId'] == friendGroupObj['friendGroupId']) {
          if (friendGroupObj['children'] == null) {
            friendGroupObj['children'] = [];
          }
          Map userObj = userController.getOneUser(contactFriendObj['toId']);
          contactFriendObj['name'] = userObj['nickname'];
          contactFriendObj['icon'] = userObj['avatar'];
          contactFriendObj['info'] = userObj['info'];
          contactFriendObj['isSelect'] = false;
          contactFriendObj['isHidden'] = false;
          friendGroupObj['children'].add(contactFriendObj);
        }
      }
    }
    setState(() {
      _userArrs = _userArrs;
      _status = _status;
    });
  }

  void selectGroup(int key) {
    bool tempStatus = !_status[key]!;
    for (var item in _userArrs) {
      if (item['friendGroupId'] == key) {
        _status[key] = tempStatus;
        for (var it in item['children']) {
          if (isInGroup(it['toId'])) {
            continue;
          }
          it['isSelect'] = tempStatus;
          _getSelect(it, tempStatus);
        }
      }
    }
    setState(() {
      _userArrs = _userArrs;
      _status = _status;
    });
  }

  void setSelected(int key, int toId) {
    if (isInGroup(toId)) {
      return;
    }

    bool tempStatus = false;
    for (var item in _userArrs) {
      if (item['friendGroupId'] == key) {
        for (var it in item['children']) {
          if (it['toId'] == toId) {
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
      _userArrs = _userArrs;
      _status = _status;
    });
  }

  void _getSelect(Map item, bool flag) {
    if (isInGroup(item['toId'])) {
      return;
    }

    if (flag) {
      _userSelectArrs.add(item);
    } else {
      final existingIndex = _userSelectArrs.indexWhere((c) => c['toId'] == item['toId']);
      if (existingIndex != -1) {
        _userSelectArrs.removeAt(existingIndex);
      }
    }
    setState(() {
      _userSelectArrs = _userSelectArrs;
    });
  }

  void _showGroupMenu(BuildContext context) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: Colors.grey,
      position: RelativeRect.fromRect(
        _tapPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem<String>(
          height: 25,
          value: 'group_manage',
          child: Text(
            '分组管理',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      elevation: 8.0,
    );
    if (selected == 'group_manage') {
      _selectGroup();
    }
  }

  void _selectGroup() async {
    await Navigator.pushNamed(
      context,
      '/friend-group',
    );
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

  bool isInGroup(int fromId) {
    final existingIndex = contactGroups.indexWhere((c) => c['fromId'] == fromId);
    if (existingIndex != -1) {
      return true;
    }
    return false;
  }

  List<Widget> _getContentAll() {
    List<Widget> lists = [];
    for (var item in _userArrs) {
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
            child: Text("${item['name']} (${item['children'].length}人)"),
            onTapDown: (TapDownDetails details) {
              _tapPosition = details.globalPosition;
            },
            onTapUp: (TapUpDetails details) {
              setState(() {
                if (item['controller'].isExpanded) {
                  item['controller'].collapse(); // 收起
                } else {
                  item['controller'].expand(); // 展开
                }
              });
            },
            onLongPressStart: (LongPressStartDetails details) {
              _showGroupMenu(context);
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
                setSelected(item['friendGroupId'], item['toId']);
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
                        onChanged: isInGroup(item['toId'])
                            ? null
                            : (bool? value) {
                                setSelected(item['friendGroupId'], item['toId']);
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
    List<int> toIds = [];
    for (var map in _userSelectArrs) {
      toIds.add(map['toId']);

      Map groupObj = groupController.getOneGroup(talkObj['objId']);

      Map data = {};
      data['group'] = groupObj;
      Map msg = {
        'id': genGUID(),
        'fromId': uid,
        'toId': map['toId'],
        'content': {"data": json.encode(data), "url": "", "name": ""},
        'msgMedia': 21,
        'msgType': 1,
        'createTime': getTime()
      };
      joinData(uid, msg);
    }
    var params = {'fromId': uid, 'toIds': toIds, 'groupId': talkObj['objId']};
    ContactFriendApi.inviteContactFriend(params, onSuccess: (res) async {
      Navigator.pop(context);
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
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
        title: const Text("邀请新成员"),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("取消"),
        ),
        actions: [
          TextButton(
            onPressed: _doneAction,
            child: Text("邀请(${_userSelectArrs.length})人"),
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
                      controller: _inputController,
                      hintText: '搜索',
                      expands: false,
                      maxHeight: 40,
                      minHeight: 40,
                      onSubmitted: (val) {
                        _formatData();
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
