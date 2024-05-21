import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'dart:async';

class WebSocketClient {
  late IOWebSocketChannel _channel; // Use 'late' modifier to defer initialization

  final String _serverUrl;
  bool _isConnected = false;

  WebSocketClient(this._serverUrl) {
    _channel = IOWebSocketChannel.connect(_serverUrl); // Initialize _channel in the constructor
    _isConnected = true;
  }

  void connect() {
    _channel = IOWebSocketChannel.connect(_serverUrl);
    _isConnected = true;
  }

  void receiveMessage(void Function(dynamic) onMessage) {
    _channel.stream.listen((message) {
      onMessage(message);
    });
  }

  void sendMessage(String message) {
    if (_isConnected) {
      _channel.sink.add(message);
    }
  }

  void close() {
    _channel.sink.close();
    _isConnected = false;
  }

  void reconnect() {
    if (!_isConnected) {
      connect();
    }
  }
}
