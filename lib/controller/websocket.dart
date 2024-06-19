import 'dart:convert';
import 'package:get/get.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/websocket.dart';

class WebSocketController extends GetxController {
  final MessageController messageController = Get.put(MessageController());

  late WebSocketClient _webSocketClient;
  RxMap message = {}.obs; // 定义为 RxMap<String, dynamic>
  final String serverUrl;
  final int uid;

  WebSocketController(this.serverUrl, this.uid);

  @override
  void onInit() {
    super.onInit();
    String url = "$serverUrl?uid=$uid";
    _webSocketClient = WebSocketClient(url);
    _webSocketClient.onMessageReceived = ((str) async {
      Map msg = json.decode(str);
      print("ReceivedMessage $msg");
      if ([1, 2, 4].contains(msg['msgType'])) {
        Map objUser = (await DBHelper.getOne('users', [
          ['uid', '=', msg['fromId']]
        ]))!;
        msg['avatar'] = objUser['avatar'];
        messageController.addMessage(msg);
      }
      message.value = msg;
    });
    _webSocketClient.connect();
    _webSocketClient.startHeartbeat(uid);
  }

  void sendMessage(Map msg) {
    _webSocketClient.sendMessage(json.encode(msg));
  }

  @override
  void onClose() {
    _webSocketClient.disconnect();
    super.onClose();
  }
}
