import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/websocket.dart';

class WebSocketController extends GetxController {
  final MessageController messageController = Get.put(MessageController());
  late WebSocketClient channel;
  RxMap message = {}.obs; // 使用 Rx 类型来实现响应式数据

  void onConnect(int uid) {
    channel = WebSocketClient('wss://im.guiaihai.com/chat?uid=$uid');
  }

  void onReceive() {
    channel.receiveMessage((message) async {
      Map msg = json.decode(message);
      handleReceivedMessage(msg);
    });
  }

  void sendMessage(Map msg) {
    channel.sendMessage(jsonEncode(msg));
    if ([4].contains(msg['msgType'])) {
      print("sendMessage");
      print(msg);
    }
  }

  Future<void> handleReceivedMessage(Map msg) async {
    if ([1, 2].contains(msg['msgType'])) {
      Map objUser = (await DBHelper.getOne('users', [
        ['uid', '=', msg['fromId']]
      ]))!;
      msg['avatar'] = objUser['avatar'];
      messageController.addMessage(msg);
    }

    message.value = msg; // 更新 message 的值
  }

  void heart(int uid) {
    const Duration interval = Duration(seconds: 10);
    Timer.periodic(interval, (Timer t) {
      Map msg = {
        'FromId': uid,
        'Content': {"Data": "心跳", "Url": "", "Name": ""},
        'MsgMedia': 0,
        'MsgType': 0
      };
      sendMessage(msg);
    });
  }
}
