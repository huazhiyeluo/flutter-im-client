import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'dart:convert';

class WebSocketClient {
  final String _url;
  IOWebSocketChannel? _channel; // Use 'late' modifier to defer initialization
  Timer? _heartBeatTimer;
  bool _isConnected = false;
  final List<String> _messageQueue = [];

  Function(String)? onMessageReceived;

  WebSocketClient(this._url);

  void connect() {
    _channel = IOWebSocketChannel.connect(Uri.parse(_url));
    _isConnected = true;

    _channel?.stream.listen((msg) {
      print("Received $msg");
      onMessageReceived?.call(msg);
    }, onDone: () {
      print('Disconnected');
      _isConnected = false;
      _reconnect();
    }, onError: (error) {
      print('Error: $error');
      _isConnected = false;
      _reconnect();
    });

    _flushMessageQueue();
  }

  //消息队列
  void _flushMessageQueue() {
    if (_isConnected) {
      while (_messageQueue.isNotEmpty) {
        String msg = _messageQueue.removeAt(0);
        print("Received $msg");
        _channel?.sink.add(msg);
      }
    }
  }

  //重连接
  void _reconnect() {
    if (!_isConnected) {
      Future.delayed(const Duration(seconds: 5), () {
        // ignore: avoid_print
        print('Attempting to reconnect to WebSocket');
        connect();
      });
    }
  }

  void sendMessage(String message) {
    if (_isConnected) {
      _channel?.sink.add(message);
    } else {
      _messageQueue.add(message);
      _reconnect();
    }
  }

  //关闭连接
  void disconnect() {
    print("disconnect");
    _heartBeatTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  //心跳
  void startHeartbeat(int uid) {
    _heartBeatTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      if (_isConnected) {
        Map msg = {
          'FromId': uid,
          'Content': {"Data": "心跳", "Url": "", "Name": ""},
          'MsgMedia': 0,
          'MsgType': 0
        };
        sendMessage(json.encode(msg));
      }
    });
  }
}
