import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/contact.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/contact_group.dart';
import 'package:qim/controller/group.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/controller/websocket.dart';
import 'package:qim/dbdata/getdbdata.dart';
import 'package:qim/dbdata/savedata.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/functions.dart';
import 'package:qim/utils/tips.dart';
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

class _HomeState extends State<Home> {
  late WebSocketController webSocketController;
  final ContactGroupController contactGroupController = Get.put(ContactGroupController());
  final UserController userController = Get.put(UserController());
  final GroupController groupController = Get.put(GroupController());
  final ChatController chatController = Get.put(ChatController());
  final TalkobjController talkobjController = Get.put(TalkobjController());
  int _currentIndex = 0;

  Map userInfo = {};
  int uid = 0;

  @override
  void initState() {
    logPrint("home-initState");
    super.initState();
    Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
    uid = userInfo == null ? "" : userInfo['uid'];
    webSocketController = Get.put(WebSocketController(uid, 'ws://139.196.98.139:8081/chat'));
    _initOnReceive();

    _getContactGroupList();
    _getFriendList();
    _getGroupList();
  }

  @override
  void dispose() {
    logPrint("home-dispose");
    webSocketController.onClose();
    super.dispose();
  }

  void _initOnReceive() {
    // 初始化 WebSocket 监听
    webSocketController.message.listen((msg) async {
      // 1、私聊和群聊消息到数据库  2、加入chat列表|保存chat数据到  3、obj对象
      if ([1, 2].contains(msg['msgType']) || ([4].contains(msg['msgType']) && [0].contains(msg['msgMedia']))) {
        joinData(userInfo['uid'], msg);
      }

      //设置当前聊天Obj
      if ([4].contains(msg['msgType']) && msg['msgMedia'] == 0) {
        Map<String, dynamic>? objUser = await getDbOneUser(msg['fromId']);
        if (objUser == null) {
          return;
        }

        Map talkobj = {
          "objId": msg['fromId'],
          "type": 1,
          "name": objUser['username'],
          "icon": objUser['avatar'],
          "info": objUser['info'],
          "remark": objUser['remark'],
        };
        talkobjController.setTalkObj(talkobj);
        //收到语音通话 - 请求
        Get.toNamed('/talk', parameters: {'ttype': "2"});
      }
    });
  }

  final List<Function> _pagesBar = [chatBar, contactBar, settingBar];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [const Chat(), const Contact(), const Person()];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _pagesBar[_currentIndex](),
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
          const BottomNavigationBarItem(label: '通讯录', icon: Icon(Icons.contacts)),
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

  void _getContactGroupList() async {
    var params = {"ownUid": uid};
    ContactApi.getFriendGroup(params, onSuccess: (res) {
      if (!mounted) return;
      List contactGroupArr = [];
      if (res['data'] != null) {
        contactGroupArr = res['data'];
      }
      Map defaultContactGroup = {"friendGroupId": 0, "name": "默认分组"};
      contactGroupController.upsetContactGroup(defaultContactGroup);
      saveDbContactGroup(defaultContactGroup);

      for (var item in contactGroupArr) {
        contactGroupController.upsetContactGroup(item);
        saveDbContactGroup(item);
      }
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  void _getFriendList() async {
    var params = {
      'fromId': uid,
    };
    ContactApi.getFriendList(params, onSuccess: (res) {
      if (!mounted) return;
      List friendArr = [];
      if (res['data'] != null) {
        friendArr = res['data'];
      }
      for (var item in friendArr) {
        userController.upsetUser(item);
        saveDbUser(item);
      }
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }

  void _getGroupList() async {
    var params = {
      'fromId': uid,
    };
    ContactApi.getGroupList(params, onSuccess: (res) {
      if (!mounted) return;
      List groupArr = [];
      if (res['data'] != null) {
        groupArr = res['data'];
      }
      for (var item in groupArr) {
        groupController.upsetGroup(item);
        saveDbGroup(item);
      }
    }, onError: (res) {
      TipHelper.instance.showToast(res['msg']);
    });
  }
}
