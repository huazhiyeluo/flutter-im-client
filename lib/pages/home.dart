import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/api/apis.dart';
import 'package:qim/data/controller/apply.dart';
import 'package:qim/data/cache/keys.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/friend_group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/controller/websocket.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/routes/route.dart';
import 'package:qim/common/utils/db.dart';
import 'package:qim/common/utils/play.dart';
import 'package:qim/common/utils/cache.dart';
import 'package:qim/common/utils/common.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/data/controller/signaling.dart';
import 'package:qim/common/utils/tips.dart';
import 'tabs/chat.dart';
import 'tabs/chat_bar.dart';
import 'tabs/contact.dart';
import 'tabs/contact_bar.dart';
import 'tabs/person.dart';
import 'tabs/person_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  late WebSocketController webSocketController;
  late SignalingController signalingController;
  final FriendGroupController friendGroupController = Get.put(FriendGroupController());
  final ContactFriendController contactFriendController = Get.put(ContactFriendController());
  final ContactGroupController contactGroupController = Get.put(ContactGroupController());

  final UserController userController = Get.put(UserController());
  final GroupController groupController = Get.put(GroupController());

  final ChatController chatController = Get.put(ChatController());
  final TalkobjController talkobjController = Get.put(TalkobjController());
  final ApplyController applyController = Get.put(ApplyController());
  final UserInfoController userInfoController = Get.put(UserInfoController());

  int _currentIndex = 0;
  late AudioPlayerManager _audioPlayerManager;

  Map userInfo = {};
  int uid = 0;

  @override
  void initState() {
    logPrint("home-initState");
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _audioPlayerManager = AudioPlayerManager();

    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'];
    userInfoController.setUserInfo(userInfo);

    _initializeData();
  }

  @override
  void dispose() {
    logPrint("home-dispose");
    webSocketController.onClose();
    Get.delete<WebSocketController>();
    Get.delete<SignalingController>();
    _audioPlayerManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (userInfoController.userInfo.isNotEmpty) {
      if (state == AppLifecycleState.paused) {
        logPrint("didChangeAppLifecycleState-paused");
        webSocketController.onClose();
      } else if (state == AppLifecycleState.resumed) {
        logPrint("didChangeAppLifecycleState-resumed");
        webSocketController.onInit();
      }
    }
  }

  void _initializeData() async {
    // 确保所有获取数据的方法按顺序执行
    await _getFriendGroupList();
    await _getContactFriendList();
    await _getContactGroupList();
    await _getChatList();
    await _getApplyList();

    // 初始化 WebSocketController 和 SignalingController
    webSocketController = Get.put(WebSocketController(uid, Apis.socketUrl));
    _initOnReceive();

    if (!mounted) return;
    signalingController =
        Get.put(SignalingController(fromId: uid, context: context, webSocketController: webSocketController));
  }

  Future<void> _initOnReceive() async {
    webSocketController.message.listen((msg) async {
      // 1、私聊和群聊消息到数据库  2、加入chat列表|保存chat数据到  3、obj对象
      if ([1, 2].contains(msg['msgType']) || ([4].contains(msg['msgType']) && [0].contains(msg['msgMedia']))) {
        joinData(uid, msg, audioPlayerManager: _audioPlayerManager);
      }
      if ([3].contains(msg['msgType'])) {
        if (msg['msgMedia'] == 10) {
          TipHelper.instance.showToast("你的账号在另外一台设备上登录，请检查");
          webSocketController.onClose();
          CacheHelper.remove(Keys.userInfo);
          userInfoController.setUserInfo({});
          String initialRouteData = await initialRoute();
          Get.offAllNamed(initialRouteData);
        }
        if (msg['msgMedia'] == 11) {
          Map item = {"fromId": msg['toId'], "toId": msg['fromId'], "isOnline": 1};
          contactFriendController.upsetContactFriend(item);
          saveDbContactFriend(item);
          await _audioPlayerManager.playSound("1.mp3");
        }
        if (msg['msgMedia'] == 12) {
          Map item = {"fromId": msg['toId'], "toId": msg['fromId'], "isOnline": 0};
          contactFriendController.upsetContactFriend(item);
          saveDbContactFriend(item);
        }
        if (msg['msgMedia'] == 13) {
          Map data = json.decode(msg['content']['data']);
          if (data['user'] != null) {
            userController.upsetUser(data['user']);
            saveDbUser(data['user']);
          }
        }
        if (msg['msgMedia'] == 14) {
          Map data = json.decode(msg['content']['data']);
          if (data['group'] != null) {
            groupController.upsetGroup(data['group']);
            saveDbGroup(data['group']);
          }
        }
        if ([21, 22, 23, 24].contains(msg['msgMedia'])) {
          loadFriendManage(uid, msg);
        }
        if ([30, 31, 32, 33, 34, 35].contains(msg['msgMedia'])) {
          loadGroupManage(uid, msg);
        }
      }
      //设置当前聊天Obj
      if ([4].contains(msg['msgType'])) {
        signalingController.handinvite(msg);
      }
    });
  }

  final List<Function> _pagesBar = [chatBar, contactBar, settingBar];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [const Chat(), const Contact(), const Person()];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _pagesBar[_currentIndex](),
      extendBody: false,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(237, 237, 237, 1),
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.yellow,
            label: '聊天',
            icon: Obx(() {
              int num = chatController.getTipsTotalNum();
              String numstr = "$num";
              if (num > 99) {
                numstr = '99+';
              }
              return Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    width: 60,
                    height: 30,
                    child: const Icon(Icons.chat),
                  ),
                  if (num > 0)
                    Positioned(
                      right: 0,
                      top: 2,
                      child: Container(
                        height: 16,
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        constraints: const BoxConstraints(
                          maxWidth: 24,
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          numstr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          BottomNavigationBarItem(
            label: '通讯录',
            icon: Obx(() {
              bool showRedPoint = applyController.showFriendRedPoint.value || applyController.showGroupRedPoint.value;
              return Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    width: 60,
                    height: 30,
                    child: const Icon(Icons.contacts),
                  ),
                  if (showRedPoint)
                    Positioned(
                      right: 5,
                      top: 2,
                      child: Container(
                        height: 12,
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          maxWidth: 12,
                          minWidth: 12,
                          minHeight: 12,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          const BottomNavigationBarItem(label: '我', icon: Icon(Icons.person)),
        ],
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
      ),
      body: pages[_currentIndex],
    );
  }

  Future<void> _getFriendGroupList() async {
    var params = {"ownerUid": uid};
    ContactFriendApi.getContactFriendGroup(params, onSuccess: (res) {
      if (!mounted) return;
      List friendGroupArr = [];
      if (res['data'] != null) {
        friendGroupArr = res['data'];
      }
      for (var item in friendGroupArr) {
        friendGroupController.upsetFriendGroup(item);
        saveDbFriendGroup(item);
      }
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  Future<void> _getContactFriendList() async {
    var params = {
      'fromId': uid,
    };
    ContactFriendApi.getContactFriendList(params, onSuccess: (res) {
      if (!mounted) return;
      List usersArr = [];
      if (res['data']['users'] != null) {
        usersArr = res['data']['users'];
      }
      for (var item in usersArr) {
        userController.upsetUser(item);
        saveDbUser(item);
      }
      List contactFriendsArr = [];
      if (res['data']['contactFriends'] != null) {
        contactFriendsArr = res['data']['contactFriends'];
      }
      for (var item in contactFriendsArr) {
        contactFriendController.upsetContactFriend(item);
        saveDbContactFriend(item);
      }
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  Future<void> _getContactGroupList() async {
    var params = {
      'fromId': uid,
    };
    ContactGroupApi.getContactGroupList(params, onSuccess: (res) {
      if (!mounted) return;
      List groupsArr = [];
      if (res['data']['groups'] != null) {
        groupsArr = res['data']['groups'];
      }
      for (var item in groupsArr) {
        groupController.upsetGroup(item);
        saveDbGroup(item);
      }

      List contactGroupsArr = [];
      if (res['data']['contactGroups'] != null) {
        contactGroupsArr = res['data']['contactGroups'];
      }
      for (var item in contactGroupsArr) {
        contactGroupController.upsetContactGroup(item);
        saveDbContactGroup(item);
      }
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  Future<void> _getChatList() async {
    if (chatController.allChats.isEmpty) {
      List chats = await DBHelper.getData('chat', []);

      for (var item in chats) {
        Map<String, dynamic> temp = Map.from(item);
        temp['content'] = jsonDecode(item['content']);
        chatController.upsetChat(temp);
      }
    }
  }

  Future<void> _getApplyList() async {
    if (applyController.allApplys.isEmpty) {
      List applys = await DBHelper.getData('apply', []);

      for (var item in applys) {
        Map<String, dynamic> temp = Map.from(item);
        applyController.upsetApply(temp);
      }
    }
  }
}
