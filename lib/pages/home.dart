import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/websocket.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/savedata.dart';
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
    super.initState();
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    WidgetsBinding.instance.addObserver(this); // 注册监听器
    webSocketController = Get.put(WebSocketController('wss://im.guiaihai.com/chat', userInfo['uid']));
    initOnReceive();
  }

  @override
  void dispose() {
    print("webSocketController-dispose");
    WidgetsBinding.instance.removeObserver(this); // 移除监听器
    webSocketController.onClose();
    // TODO: implement dispose
    super.dispose();
  }

  void initOnReceive() {
    // 初始化 WebSocket 监听
    webSocketController.message.listen((msg) async {
      if ([1, 2].contains(msg['msgType'])) {
        saveMessage(msg);
      }
      if (!([4].contains(msg['msgType']) && [3, 4, 5].contains(msg['msgMedia']))) {
        processReceivedMessage(userInfo['uid'], msg, chatController);
      }

      // if ([4].contains(msg['msgType'])) {
      //   Map objUser = (await DBHelper.getOne('users', [
      //     ['uid', '=', msg['fromId']]
      //   ]))!;
      //   Map talkobj = {
      //     "objId": msg['fromId'],
      //     "type": 1,
      //     "name": objUser['username'],
      //     "icon": objUser['avatar'],
      //     "info": objUser['info'],
      //     "remark": objUser['remark'],
      //   };
      //   talkobjController.setTalkObj(talkobj);
      //   if (msg['msgMedia'] == 0) {
      //     //收到语音通话 - 请求
      //     Get.toNamed('/talk', arguments: {
      //       "type": 2,
      //     });
      //   }
      // }
    });
  }

  final List<Function> _pagesBar = [chatBar, contactBar, settingBar];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [const Chat(), const Contact(), const Setting()];

    return Scaffold(
      appBar: _pagesBar[_currentIndex](),
      bottomNavigationBar: BottomNavigationBar(
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
          const BottomNavigationBarItem(label: '联系人', icon: Icon(Icons.person)),
          const BottomNavigationBarItem(label: '个人中心', icon: Icon(Icons.settings)),
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