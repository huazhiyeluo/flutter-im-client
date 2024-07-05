import 'package:get/get.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/functions.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'dart:convert';

class WebSocketController extends GetxController {
  final MessageController messageController = Get.put(MessageController());
  final String serverUrl;
  final int uid;

  IOWebSocketChannel? _channel;
  Timer? _heartBeatTimer;
  bool _isConnected = false;
  final List<String> _messageQueue = [];

  // 响应式变量
  RxMap message = {}.obs;

  WebSocketController(this.uid, this.serverUrl);

  @override
  void onInit() {
    super.onInit();
    connect(); // 在控制器初始化时连接 WebSocket
  }

  void connect() {
    String url = "$serverUrl?uid=$uid";

    _channel = IOWebSocketChannel.connect(Uri.parse(url));
    _isConnected = true;

    _channel?.stream.listen((str) async {
      logPrint("WebSocketController revicedMessage: $str");
      Map msg = json.decode(str);
      if ([1, 2, 4].contains(msg['msgType'])) {
        Map objUser = (await DBHelper.getOne('users', [
          ['uid', '=', msg['fromId']]
        ]))!;
        msg['avatar'] = objUser['avatar'];
        messageController.addMessage(msg);
      }
      message.value = msg;
      // 在这里处理接收到的消息逻辑
    }, onDone: () {
      _isConnected = false;
      _reconnect();
    }, onError: (error) {
      _isConnected = false;
      _reconnect();
    });
    startHeartbeat(uid);
    _flushMessageQueue();
    logPrint("WebSocketController connect");
  }

  void _flushMessageQueue() {
    if (_isConnected) {
      while (_messageQueue.isNotEmpty) {
        String msg = _messageQueue.removeAt(0);
        _sendMessage(msg);
      }
    }
  }

  void _reconnect() {
    if (!_isConnected) {
      Future.delayed(const Duration(seconds: 5), () {
        connect();
      });
    }
  }

  void sendMessage(Map msg) {
    _sendMessage(json.encode(msg));
  }

  void _sendMessage(String msg) {
    if (_isConnected) {
      _channel?.sink.add(msg);
      logPrint("WebSocketController sendMessage: $msg");
    } else {
      _messageQueue.add(msg);
      _reconnect();
    }
  }

  void disconnect() {
    _heartBeatTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _messageQueue.clear();
    logPrint("WebSocketController disconnect");
  }

  void startHeartbeat(int uid) {
    _heartBeatTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      if (_isConnected) {
        Map msg = {
          'FromId': uid,
          'Content': {"Data": "心跳", "Url": "", "Name": ""},
          'MsgMedia': 0,
          'MsgType': 0
        };
        _sendMessage(json.encode(msg));
      }
    });
  }

  @override
  void onClose() {
    disconnect(); // 在控制器关闭时断开 WebSocket
    super.onClose();
  }
}
