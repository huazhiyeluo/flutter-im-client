import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/utils/date.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/common/widget/custom_search_field.dart';

class GroupUserDelete extends StatefulWidget {
  const GroupUserDelete({super.key});

  @override
  State<GroupUserDelete> createState() => _GroupUserDeleteState();
}

class _GroupUserDeleteState extends State<GroupUserDelete> {
  final UserInfoController userInfoController = Get.find();
  final UserController userController = Get.find();
  final ContactGroupController contactGroupController = Get.find();

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _inputController = TextEditingController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map contactGroupObj = {};

  double picWidth = 45;
  double screenWidth = 0;
  double leftWidth = 0;
  double rightWidth = 0;

  Map<String, List<Map>> _userArrs = <String, List<Map>>{};
  List<Map> _userSelectArrs = [];
  Map<String, bool> _status = <String, bool>{};
  Set<int> processedFromIds = {};

  @override
  void initState() {
    super.initState();
    talkObj = Get.arguments ?? {};
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    contactGroupObj = contactGroupController.getOneContactGroup(uid, talkObj['objId']);

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

  // 检查用户权限，判断是否有删除权限

  bool _checkPermission(int groupPower) {
    if (contactGroupObj['groupPower'] > groupPower) {
      return true;
    } else {
      return false;
    }
  }

  // 自动滚动到最右边的方法
  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _formatData() {
    int halfYear = getTime() - 180 * 24 * 3600;
    int oneYear = getTime() - 360 * 24 * 3600;
    final contactGroups = contactGroupController.allContactGroups[talkObj['objId']] ?? RxList<Map>.from([]);
    for (var item in contactGroups) {
      Map userObj = userController.getOneUser(item['fromId']);
      if (userObj['nickname'].contains(_inputController.text) || item['remark'].contains(_inputController.text) || item['fromId'].toString().contains(_inputController.text)) {
        item['isHidden'] = false;
      } else {
        item['isHidden'] = true;
      }
      if (processedFromIds.contains(item['fromId'])) {
        continue;
      }
      item['nickname'] = item['nickname'] == '' ? userObj['nickname'] : item['nickname'];
      item['avatar'] = userObj['avatar'];
      item['isSelect'] = false;
      item['isHidden'] = false;
      if (item['joinTime'] > halfYear) {
        if (!_userArrs.containsKey('半年内登录')) {
          _userArrs['半年内登录'] = [];
          _status['半年内登录'] = false;
        }
        _userArrs['半年内登录']?.add(item);
      } else if (item['joinTime'] > oneYear) {
        if (!_userArrs.containsKey('一年内登录')) {
          _userArrs['一年内登录'] = [];
          _status['一年内登录'] = false;
        }
        _userArrs['一年内登录']?.add(item);
      } else {
        if (!_userArrs.containsKey('更久')) {
          _userArrs['更久'] = [];
          _status['更久'] = false;
        }
        _userArrs['更久']?.add(item);
      }
      processedFromIds.add(item['fromId']);
    }
    // 确保数据按顺序排列
    _userArrs = {
      '半年内登录': _userArrs['半年内登录'] ?? [],
      '一年内登录': _userArrs['一年内登录'] ?? [],
      '更久': _userArrs['更久'] ?? [],
    };
    _userArrs.removeWhere((key, value) => value.isEmpty);

    setState(() {
      _userArrs = _userArrs;
      _status = _status;
    });
  }

  void selectGroup(String key) {
    if (_userArrs[key] == null) {
      return;
    }
    bool tempStatus = !_status[key]!;
    // 遍历 _userArrs[key] 确保非空
    for (var i = 0; i < _userArrs[key]!.length; i++) {
      if (_userArrs[key]![i]['fromId'] == uid) {
        continue;
      }
      if (!_checkPermission(_userArrs[key]![i]['groupPower'] as int)) {
        continue;
      }

      _userArrs[key]![i]['isSelect'] = tempStatus;
      _getSelect(_userArrs[key]![i], tempStatus);
      _status[key] = tempStatus;
    }

    setState(() {
      _userArrs = _userArrs;
      _status = _status;
    });
  }

  void setSelected(String key, int fromId) {
    if (fromId == uid) {
      return;
    }
    if (_userArrs[key] == null) {
      return;
    }
    bool tempStatus = false;
    for (var i = 0; i < _userArrs[key]!.length; i++) {
      if (_userArrs[key]![i]['fromId'] == fromId) {
        _userArrs[key]![i]['isSelect'] = !_userArrs[key]![i]['isSelect'];
        _getSelect(_userArrs[key]![i], _userArrs[key]![i]['isSelect']);
      }
      if (_userArrs[key]![i]['isSelect']) {
        tempStatus = true;
      }
    }
    _status[key] = tempStatus;

    setState(() {
      _userArrs = _userArrs;
      _status = _status;
    });
  }

  void _getSelect(Map item, bool flag) {
    if (item['fromId'] == uid) {
      return;
    }

    if (flag) {
      _userSelectArrs.add(item);
    } else {
      final existingIndex = _userSelectArrs.indexWhere((c) => c['fromId'] == item['fromId']);
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
            // 聊天对象的头像
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(
              map['avatar'],
            ),
          ),
        ));
      }
    }
    return lists;
  }

  _doneAction() async {
    List<int> fromIds = [];
    for (var map in _userSelectArrs) {
      fromIds.add(map['fromId']);
    }
    var params = {'toId': talkObj['objId'], 'fromIds': fromIds};
    ContactGroupApi.delContactGroup(params, onSuccess: (res) async {
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
      if (_userSelectArrs.isNotEmpty) {
        leftWidth = leftWidth + 15;
      }
      if (leftWidth > screenWidth - 120 - 35) {
        leftWidth = screenWidth - 120 - 35;
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("选择成员"),
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
        actions: [
          TextButton(
            onPressed: _doneAction,
            child: Text("移除(${_userSelectArrs.length})人"),
          ),
        ],
      ),
      body: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(61),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: Row(
              children: [
                _userSelectArrs.isNotEmpty
                    ? const SizedBox(
                        width: 12,
                      )
                    : Container(),
                Container(
                  width: leftWidth,
                  height: 56,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(12, 7, 12, 5),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    children: _getSelectAll(),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 56,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(12, 7, 12, 5),
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
                )
              ],
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: _userArrs.entries.map((entry) {
            String gk = entry.key;
            List<Map> groupData = entry.value;

            List<Map> visibleData = groupData.where((item) => !item['isHidden']).toList();

            return Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                title: Text("$gk (${visibleData.length}人)"),
                controlAffinity: ListTileControlAffinity.leading,
                trailing: TextButton(
                  onPressed: () {
                    selectGroup(gk);
                  },
                  child: _status[gk] == false ? const Text("选择") : const Text("取消选择"),
                ),
                children: visibleData.map((item) {
                  return InkWell(
                    onTap: () {
                      setSelected(gk, item['fromId']);
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
                              onChanged: _checkPermission(item['groupPower'])
                                  ? (bool? value) {
                                      setSelected(gk, item['fromId']);
                                    }
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: CachedNetworkImageProvider(
                              item['avatar'],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text("${item['nickname']}"),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
