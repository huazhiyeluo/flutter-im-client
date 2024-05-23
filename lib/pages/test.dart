import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final _localVideo = webrtc.RTCVideoRenderer();
  late webrtc.MediaStream _localStream;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _localVideo.dispose();
    _localStream.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _localVideo.initialize();
    _open();
  }

  Future<void> _open() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {'width': 200, 'height': 200},
    };
    try {
      _localStream = await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localVideo.srcObject = _localStream;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: webrtc.RTCVideoView(_localVideo),
      ),
    );
  }
}
