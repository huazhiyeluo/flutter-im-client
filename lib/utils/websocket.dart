import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'dart:convert';

class WebSocketClient {
  late IOWebSocketChannel _channel; // Use 'late' modifier to defer initialization

  final String _serverUrl;
  bool _isConnected = false;
  Function(String)? onMessageReceived;

  WebSocketClient(this._serverUrl);

  void connect() {
    _channel = IOWebSocketChannel.connect(_serverUrl);
    _isConnected = true;
    _channel.stream.listen((message) {
      print("onMessageReceived $message");
      onMessageReceived?.call(message);
    }, onDone: () {
      _handleDisconnection('Connection closed');
    }, onError: (error) {
      _handleDisconnection('WebSocket error: $error');
    });
  }

  void _handleDisconnection(String reason) {
    _isConnected = false;
    print(reason);
    _reconnect();
  }

  void sendMessage(Map message) {
    if (_isConnected) {
      try {
        print("LIAO sendMessage ${jsonEncode(message)}");
        _channel.sink.add(jsonEncode(message));
      } catch (e) {
        print('Failed to send message: $e');
        // Handle the error, attempt to reconnect
        _handleDisconnection('Failed to send message: $e');
      }
    } else {
      print('WebSocket is not connected, message not sent');
      // Handle the error, attempt to reconnect
      _handleDisconnection('WebSocket is not connected');
    }
  }

  void close() {
    _channel.sink.close();
    _isConnected = false;
  }

  void _reconnect() {
    if (!_isConnected) {
      Future.delayed(Duration(seconds: 5), () {
        print('Attempting to reconnect to WebSocket');
        connect();
      });
    }
  }

  void startHeartbeat(int uid) {
    const Duration interval = Duration(seconds: 10);
    Timer.periodic(interval, (Timer t) {
      if (_isConnected) {
        Map msg = {
          'FromId': uid,
          'Content': {"Data": "心跳", "Url": "", "Name": ""},
          'MsgMedia': 0,
          'MsgType': 0
        };
        sendMessage(msg);
      }
    });
  }
}
