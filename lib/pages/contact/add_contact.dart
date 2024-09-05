import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/group.dart';
import 'package:qim/api/user.dart';
import 'package:qim/controller/contact_friend.dart';
import 'package:qim/controller/group.dart';
import 'package:qim/controller/userinfo.dart';
import 'package:qim/utils/functions.dart';
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/custom_search_field.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactDetailState();
}

class _AddContactDetailState extends State<AddContact> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map talkObj = {};

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          color: Colors.grey[200],
          child: TabBar(
            tabAlignment: TabAlignment.center,
            controller: _tabController,
            tabs: [
              Container(
                width: 80,
                height: 35,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // 未选中标签的边框颜色
                    width: 1.0,
                  ),
                ),
                child: const Center(child: Text("找人")),
              ),
              Container(
                width: 80,
                height: 35,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // 未选中标签的边框颜色
                    width: 1.0,
                  ),
                ),
                child: const Center(child: Text("找群")),
              ),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            dividerHeight: 1,
            indicator: BoxDecoration(
              color: Colors.black, // 选中标签的背景色
              border: Border.all(
                color: Colors.black, // 选中标签的边框颜色
                width: 1,
              ),
            ),
            indicatorWeight: 0,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
          ),
        ),
        centerTitle: true,
      ),
      body: AddContactDetailPage(
        tabController: _tabController,
      ),
    );
  }
}

class AddContactDetailPage extends StatefulWidget {
  final TabController tabController;
  const AddContactDetailPage({super.key, required this.tabController});

  @override
  State<AddContactDetailPage> createState() => _AddContactDetailPageState();
}

class _AddContactDetailPageState extends State<AddContactDetailPage> {
  final ScrollController _scrollUserController = ScrollController();
  final ScrollController _scrollGroupController = ScrollController();
  final TextEditingController _inputUserController = TextEditingController();
  final TextEditingController _inputGroupController = TextEditingController();
  final UserInfoController userInfoController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final GroupController groupController = Get.find();

  bool _isUserLoading = false;
  bool _hasUserMore = true;
  int _pageUser = 1;
  int _userTotal = 0;

  bool _isGroupLoading = false;
  bool _hasGroupMore = true;
  int _pageGroup = 1;
  int _groupTotal = 0;

  List _userArr = [];
  List _groupArr = [];

  List _myFriendArr = [];
  List _myGroupArr = [];

  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];

    _myFriendArr = contactFriendController.allContactFriends;
    _myGroupArr = groupController.allGroups;

    _scrollUserController.addListener(() {
      if (_scrollUserController.position.pixels == _scrollUserController.position.maxScrollExtent) {
        if (!_isUserLoading && _hasUserMore) {
          _searchUser();
        }
      }
    });
    _scrollGroupController.addListener(() {
      if (_scrollGroupController.position.pixels == _scrollGroupController.position.maxScrollExtent) {
        if (!_isGroupLoading && _hasGroupMore) {
          _searchGroup();
        }
      }
    });
  }

  _searchUser() {
    setState(() {
      _isUserLoading = true;
    });

    var params = {
      'keyword': _inputUserController.text,
      'pageSize': 15,
      'pageNum': _pageUser,
    };
    UserApi.searchUser(params, onSuccess: (res) {
      setState(() {
        _isUserLoading = false;
        _userTotal = res['data']['count'];
        List newData = res['data']['users'] ?? [];
        if (newData.isEmpty) {
          _hasUserMore = false;
        } else {
          _pageUser++;
          _userArr.addAll(res['data']['users']);
        }
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  bool _checkUser(int uid) {
    final existingFriendIndex = _myFriendArr.indexWhere((c) => c['uid'] == uid);
    return existingFriendIndex == -1;
  }

  _searchGroup() {
    setState(() {
      _isGroupLoading = true;
    });

    var params = {
      'keyword': _inputGroupController.text,
      'pageSize': 15,
      'pageNum': _pageGroup,
    };
    GroupApi.searchGroup(params, onSuccess: (res) {
      setState(() {
        _isGroupLoading = false;
        _groupTotal = res['data']['count'];
        List newData = res['data']['groups'] ?? [];
        if (newData.isEmpty) {
          _hasGroupMore = false;
        } else {
          _pageGroup++;
          _groupArr.addAll(res['data']['groups']);
        }
      });
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  bool _checkGroup(int groupId) {
    final existingGroupIndex = _myGroupArr.indexWhere((c) => c['groupId'] == groupId);
    logPrint(existingGroupIndex == -1);
    return existingGroupIndex == -1;
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(controller: widget.tabController, children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: CustomSearchField(
              controller: _inputUserController,
              hintText: 'QID/昵称',
              expands: false,
              maxHeight: 40,
              minHeight: 40,
              onSubmitted: (val) {
                _isUserLoading = false;
                _hasUserMore = true;
                _pageUser = 1;
                _userArr = [];
                _searchUser();
              },
            ),
          ),
          _inputUserController.text != ''
              ? Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
                  child: Text(
                    "共计$_userTotal条记录",
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 150, 222, 203),
                    ),
                  ),
                )
              : const Text(""),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              controller: _scrollUserController,
              itemCount: _userArr.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    SizedBox(
                      height: 55,
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: -15,
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(_userArr[index]['avatar']),
                        ),
                        title: Text(_userArr[index]['nickname']),
                        subtitle: Text(
                          _userArr[index]['info'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: _userArr[index]['uid'] == uid
                            ? const Text("自己")
                            : _checkUser(_userArr[index]['uid'])
                                ? TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/add-contact-friend-do',
                                        arguments: _userArr[index],
                                      );
                                    },
                                    style: ButtonStyle(
                                      minimumSize: WidgetStateProperty.all<Size>(const Size(40, 25)),
                                      shape: WidgetStateProperty.all<OutlinedBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(1.0), // 设置按钮的圆角
                                          side: const BorderSide(color: Colors.grey), // 设置按钮的边框颜色和宽度
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      "添加",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                : const Text(""),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: CustomSearchField(
              controller: _inputGroupController,
              hintText: '群号/群名称',
              expands: false,
              maxHeight: 40,
              minHeight: 40,
              onSubmitted: (val) {
                _isGroupLoading = false;
                _hasGroupMore = true;
                _pageGroup = 1;
                _groupArr = [];
                _searchGroup();
              },
            ),
          ),
          _inputGroupController.text != ""
              ? Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
                  child: Text(
                    "共计$_groupTotal条记录",
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 150, 222, 203),
                    ),
                  ),
                )
              : const Text(""),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              controller: _scrollGroupController,
              itemCount: _groupArr.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    SizedBox(
                      height: 55,
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: -15,
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(_groupArr[index]['icon']),
                        ),
                        title: Text(_groupArr[index]['name']),
                        subtitle: Text(
                          _groupArr[index]['info'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: _checkGroup(_groupArr[index]['groupId'])
                            ? TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/add-contact-group-do',
                                    arguments: _groupArr[index],
                                  );
                                },
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all<Size>(const Size(40, 25)),
                                  shape: WidgetStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(1.0), // 设置按钮的圆角
                                      side: const BorderSide(color: Colors.grey), // 设置按钮的边框颜色和宽度
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  "加入",
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            : const Text(""),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      )
    ]);
  }
}
