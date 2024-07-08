import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/websocket.dart';
import 'package:qim/dbdata/getdbdata.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/functions.dart';
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
  final ChatController chatController = Get.put(ChatController());
  final TalkobjController talkobjController = Get.put(TalkobjController());
  int _currentIndex = 0;

  Map userInfo = {};

  @override
  void initState() {
    logPrint("home-initState");
    super.initState();
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    WidgetsBinding.instance.addObserver(this); // 注册监听器
    webSocketController = Get.put(WebSocketController(userInfo['uid'], 'ws://139.196.98.139:8081/chat'));
    initOnReceive();
  }

  @override
  void dispose() {
    logPrint("home-dispose");
    WidgetsBinding.instance.removeObserver(this); // 移除监听器
    webSocketController.onClose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        logPrint("didChangeAppLifecycleState-resumed");
        webSocketController.connect();
        break;
      case AppLifecycleState.paused:
        logPrint("didChangeAppLifecycleState-paused");
        webSocketController.disconnect();
        break;
      default:
        break;
    }
  }

  void initOnReceive() {
    // 初始化 WebSocket 监听
    webSocketController.message.listen((msg) async {
      // 1、私聊和群聊消息到数据库  2、加入chat列表|保存chat数据到  3、obj对象
      if ([1, 2].contains(msg['msgType']) || ([4].contains(msg['msgType']) && [1].contains(msg['msgMedia']))) {
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
          "type": msg['msgType'],
          "name": objUser['username'],
          "icon": objUser['avatar'],
          "info": objUser['info'],
          "remark": objUser['remark'],
        };
        talkobjController.setTalkObj(talkobj);
        //收到语音通话 - 请求
        Get.toNamed('/talk');
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
}
