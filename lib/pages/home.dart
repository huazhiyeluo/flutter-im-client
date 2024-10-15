import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/config/urls.dart';
import 'package:qim/data/api/contact_friend.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/controller/apply.dart';
import 'package:qim/data/cache/keys.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/friend_group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/share.dart';
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
  late AudioPlayerManager _audioPlayerManager;

  final UserController userController = Get.put(UserController());
  final FriendGroupController friendGroupController = Get.put(FriendGroupController());
  final ContactFriendController contactFriendController = Get.put(ContactFriendController());

  final GroupController groupController = Get.put(GroupController());
  final ContactGroupController contactGroupController = Get.put(ContactGroupController());

  final ApplyController applyController = Get.put(ApplyController());

  final ChatController chatController = Get.put(ChatController());
  final ShareController shareController = Get.put(ShareController());

  final TalkobjController talkobjController = Get.put(TalkobjController());
  final UserInfoController userInfoController = Get.put(UserInfoController());

  final List<Function> _pagesBar = [chatBar, contactBar, settingBar];
  final List<Widget> pages = [const Chat(), const Contact(), const Person()];

  int _currentIndex = 0;
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

    _initData();
    _initOtherData();
  }

  @override
  void dispose() {
    logPrint("home-dispose");
    super.dispose();
    webSocketController.onClose();
    Get.delete<UserController>();
    Get.delete<FriendGroupController>();
    Get.delete<ContactFriendController>();
    Get.delete<GroupController>();
    Get.delete<ContactGroupController>();
    Get.delete<ApplyController>();
    Get.delete<ChatController>();
    Get.delete<ShareController>();
    Get.delete<TalkobjController>();
    Get.delete<UserInfoController>();
    Get.delete<WebSocketController>();
    Get.delete<SignalingController>();
    _audioPlayerManager.dispose();
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

  void _initData() async {
    await Future.wait([
      _getFriendGroupList(),
      _getContactFriendList(),
      _getContactGroupList(),
      _getChatList(),
      _getApplyList(),
    ]);
  }

  void _initOtherData() {
    webSocketController = Get.put(WebSocketController(uid, Urls.socketUrl));
    signalingController = Get.put(SignalingController(fromId: uid, context: context, webSocketController: webSocketController));
    _initOnReceive();
  }

  Future<void> _initOnReceive() async {
    webSocketController.message.listen((msg) async {
      // 1、私聊和群聊消息到数据库  2、加入chat列表|保存chat数据到  3、obj对象
      if ([AppWebsocket.msgTypeSingle, AppWebsocket.msgTypeRoom].contains(msg['msgType'])) {
        joinData(uid, msg, audioPlayerManager: _audioPlayerManager);
      }
      if ([AppWebsocket.msgTypeNotice].contains(msg['msgType'])) {
        _handleMessage(msg);
      }
      //设置当前聊天Obj
      if ([AppWebsocket.msgTypeAck].contains(msg['msgType'])) {
        signalingController.handinvite(msg);
      }
    });
  }

  void _handleMessage(Map msg) {
    switch (msg['msgMedia']) {
      case AppWebsocket.msgMediaOfflinePack:
        _handleAccountLogin(msg);
        break;
      case AppWebsocket.msgMediaOnline:
      case AppWebsocket.msgMediaOffline:
        _handleOnlineStatus(msg);
        break;
      case AppWebsocket.msgMediaUserinfo:
        _handleUserUpdate(msg);
        break;
      case AppWebsocket.msgMediaGroupinfo:
        _handleGroupUpdate(msg);
        break;
      default:
        _handleFriendGroupManagement(msg);
        break;
    }
  }

  //1-1、退出账号
  Future<void> _handleAccountLogin(Map msg) async {
    TipHelper.instance.showToast("你的账号在另外一台设备上登录，请检查");
    webSocketController.onClose();
    CacheHelper.remove(Keys.userInfo);
    userInfoController.setUserInfo({});
    Get.offAllNamed(await initialRoute());
  }

  //1-2、上线下线
  void _handleOnlineStatus(Map msg) {
    Map item = {"fromId": msg['toId'], "toId": msg['fromId'], "isOnline": msg['msgMedia'] == AppWebsocket.msgMediaOnline ? 1 : 0};
    contactFriendController.upsetContactFriend(item);
    saveDbContactFriend(item);
    if (msg['msgMedia'] == AppWebsocket.msgMediaOnline) {
      _audioPlayerManager.playSound("1.mp3");
    }
  }

  //1-3、用户更新
  void _handleUserUpdate(Map msg) {
    Map data = json.decode(msg['content']['data']);
    if (data['user'] != null) {
      userController.upsetUser(data['user']);
      saveDbUser(data['user']);
    }
  }

  //1-4、群组更新
  void _handleGroupUpdate(Map msg) {
    Map data = json.decode(msg['content']['data']);
    if (data['group'] != null) {
      groupController.upsetGroup(data['group']);
      saveDbGroup(data['group']);
    }
  }

  //1-5、联系人|群组联系人
  void _handleFriendGroupManagement(Map msg) {
    if ([
      AppWebsocket.msgMediaFriendAdd,
      AppWebsocket.msgMediaFriendAgree,
      AppWebsocket.msgMediaFriendRefuse,
      AppWebsocket.msgMediaFriendDelete,
    ].contains(msg['msgMedia'])) {
      loadFriendManage(uid, msg);
    }
    if ([
      AppWebsocket.msgMediaGroupCreate,
      AppWebsocket.msgMediaGroupJoin,
      AppWebsocket.msgMediaGroupAgree,
      AppWebsocket.msgMediaGroupRefuse,
      AppWebsocket.msgMediaGroupDelete,
      AppWebsocket.msgMediaGroupDisband,
      AppWebsocket.msgMediaContactGroupUpdate,
    ].contains(msg['msgMedia'])) {
      loadGroupManage(uid, msg);
    }
  }

  Widget _getChatBarItem(int num) {
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
  }

  Widget _getContactsBarItem(bool showRedPoint) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _pagesBar[_currentIndex](),
      extendBody: false,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.yellow,
            label: '聊天',
            icon: Obx(() {
              int num = chatController.getTipsTotalNum();
              return _getChatBarItem(num);
            }),
          ),
          BottomNavigationBarItem(
            label: '通讯录',
            icon: Obx(() {
              bool showRedPoint = applyController.showFriendRedPoint.value || applyController.showGroupRedPoint.value;
              return _getContactsBarItem(showRedPoint);
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
