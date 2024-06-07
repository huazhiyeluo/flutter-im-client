import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/utils/db.dart';

class WebSocketController extends GetxController {
  final MessageController messageController = Get.put(MessageController());
  WebSocket? channel;
  RxMap message = {}.obs;
  Timer? heartTimer;
  Timer? reconnectTimer;
  int reconnectAttempts = 0;
  final int maxReconnectAttempts = 5; // 最大重连次数
  final int reconnectDelay = 5; // 重连间隔时间（秒）
  bool _isListening = false;
  bool isConnected = false; // 连接状态标志

  Future<void> onConnect(int uid) async {
    print("onConnect");
    try {
      if (channel != null) {
        await channel?.close(); // 确保之前的连接已关闭
      }
      // 建立 WebSocket 连接
      channel = await WebSocket.connect('wss://im.guiaihai.com/chat?uid=$uid');
      isConnected = true; // 设置连接状态
      _isListening = false; // 重置监听标志
      onReceive();
      heart(uid); // 连接建立后启动心跳机制
      reconnectAttempts = 0; // 连接成功后重置重连次数
    } catch (e) {
      print("WebSocket connection error: $e");
      isConnected = false; // 设置连接状态
      scheduleReconnect(uid);
    }
  }

  void onReceive() {
    if (_isListening) {
      return; // 如果已经在监听消息，则直接返回
    }
    _isListening = true; // 设置标志为 true，表示已经在监听消息
    // 监听 WebSocket 消息
    channel?.listen((message) async {
      Map msg = json.decode(message);
      await handleReceivedMessage(msg);
    }, onDone: () {
      print("WebSocket connection closed");
      isConnected = false; // 设置连接状态
      scheduleReconnect(); // 连接关闭后尝试重连
    }, onError: (error) {
      print("WebSocket error: $error");
      isConnected = false; // 设置连接状态
      scheduleReconnect(); // 连接错误后尝试重连
    });
  }

  void sendMessage(Map msg) {
    // 确保 channel 已初始化
    if (channel != null) {
      channel?.add(jsonEncode(msg));
    } else {
      print("WebSocket channel is not initialized.");
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
    message.value = msg;
  }

  void heart(int uid) {
    // 如果心跳定时器已存在，则先取消
    heartTimer?.cancel();

    const Duration interval = Duration(seconds: 10);
    heartTimer = Timer.periodic(interval, (Timer t) {
      Map msg = {
        'FromId': uid,
        'Content': {"Data": "心跳", "Url": "", "Name": ""},
        'MsgMedia': 0,
        'MsgType': 0
      };
      print(msg);
      sendMessage(msg);
    });
  }

  void scheduleReconnect([int? uid]) {
    if (reconnectAttempts < maxReconnectAttempts) {
      reconnectAttempts++;
      print("Attempting to reconnect... (Attempt $reconnectAttempts)");
      reconnectTimer?.cancel();
      reconnectTimer = Timer(Duration(seconds: reconnectDelay), () {
        if (uid != null) {
          onConnect(uid);
        } else {
          // 在没有提供 uid 的情况下，可以使用之前存储的 uid 重新连接
        }
      });
    } else {
      print("Max reconnect attempts reached. Stopping reconnection attempts.");
    }
  }

  bool checkConnection() {
    return isConnected;
  }

  @override
  void onClose() {
    heartTimer?.cancel(); // 当控制器关闭时取消心跳定时器
    reconnectTimer?.cancel(); // 取消重连定时器
    channel?.close(); // 关闭 WebSocket 连接
    isConnected = false; // 设置连接状态
    super.onClose();
  }
}
