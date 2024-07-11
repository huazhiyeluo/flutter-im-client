import 'dart:io';

import 'package:get/get.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/utils/device_info.dart';
import 'package:qim/utils/functions.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';

class WebSocketController extends GetxController with WidgetsBindingObserver {
  final MessageController messageController = Get.put(MessageController());
  final String serverUrl;
  final int uid;

  IOWebSocketChannel? _channel;
  Timer? _heartBeatTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  final List<String> _messageQueue = [];
  bool _shouldReconnect = true;

  // 响应式变量
  RxMap message = {}.obs;

  WebSocketController(this.uid, this.serverUrl);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    connect(); // 在控制器初始化时连接 WebSocket
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect(); // 断开 WebSocket 连接并释放资源
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      logPrint("didChangeAppLifecycleState-paused");
      _shouldReconnect = false;
      disconnect();
    } else if (state == AppLifecycleState.resumed) {
      logPrint("didChangeAppLifecycleState-resumed");
      _shouldReconnect = true;
      connect();
    }
  }

  Future<void> connect() async {
    logPrint("WebSocketController connect");
    DeviceInfo deviceInfo = await DeviceInfo.getDeviceInfo();

    String url = "$serverUrl?uid=$uid";
    Map<String, dynamic> headers = {HttpHeaders.cookieHeader: 'sessionKey=${deviceInfo.deviceId};'};
    _channel = IOWebSocketChannel.connect(Uri.parse(url), headers: headers);
    _isConnected = true;

    _channel?.stream.listen((str) async {
      logPrint("WebSocketController receivedMessage: $str");
      Map msg = json.decode(str);
      message.value = msg;
      // 在这里处理接收到的消息逻辑
    }, onDone: () {
      _isConnected = false;
      if (_shouldReconnect) {
        _reconnect();
      }
    }, onError: (error) {
      _isConnected = false;
      if (_shouldReconnect) {
        _reconnect();
      }
    });
    startHeartbeat(uid);
    _flushMessageQueue();
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
    if (!_isConnected && _shouldReconnect) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
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
      if (_shouldReconnect) {
        _reconnect();
      }
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _heartBeatTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _messageQueue.clear();
    logPrint("WebSocketController disconnect");
  }

  void startHeartbeat(int uid) {
    _heartBeatTimer?.cancel();
    _heartBeatTimer = Timer.periodic(const Duration(seconds: 20), (Timer t) {
      if (_isConnected) {
        Map msg = {
          'FromId': uid,
          'Content': {"Data": "心跳", "Url": "", "Name": ""},
          'MsgMedia': 0,
          'MsgType': 0
        };
        _sendMessage(json.encode(msg));
      } else if (_shouldReconnect) {
        _reconnect();
      }
    });
  }

  @override
  void onClose() {
    disconnect(); // 在控制器关闭时断开 WebSocket
    super.onClose();
  }
}
