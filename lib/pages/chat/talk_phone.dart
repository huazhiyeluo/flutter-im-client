import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/utils/cache.dart';

class TalkPhone extends StatefulWidget {
  const TalkPhone({super.key});

  @override
  State<TalkPhone> createState() => _TalkPhoneState();
}

class _TalkPhoneState extends State<TalkPhone> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(125, 0, 0, 125),
      body: TalkPhonePage(),
    );
  }
}

class TalkPhonePage extends StatefulWidget {
  const TalkPhonePage({super.key});

  @override
  State<TalkPhonePage> createState() => _TalkPhonePageState();
}

class _TalkPhonePageState extends State<TalkPhonePage> {
  final TalkobjController talkobjController = Get.find();

  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};

  late webrtc.RTCPeerConnection _peerConnection;
  late webrtc.MediaStream _localStream;

  @override
  void initState() {
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    talkObj = talkobjController.talkObj;
    _fetchData();
    _initWebRTC();
    super.initState();
  }

  void _fetchData() async {}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('Local Video'),
          _localRenderer.isInitialized ? webrtc.RTCVideoView(_localRenderer) : Container(), // 显示本地视频流
          SizedBox(height: 20),
          Text('Remote Video'),
          _remoteRenderer.isInitialized ? webrtc.RTCVideoView(_remoteRenderer) : Container(), // 显示远程视频流
        ],
      ),
    );
  }

  Future<void> _initWebRTC() async {
    _localStream = await _createStream();
    _peerConnection = await _createConnection();
  }

  Future<webrtc.MediaStream> _createStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': true,
    };
    final localStream = await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);

    localStream.getTracks().forEach((track) {});

    return localStream;
  }

  Future<webrtc.RTCPeerConnection> _createConnection() async {
    Map<String, dynamic> configuration = {
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ],
    };
    Map<String, dynamic> constraints = {
      'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
      'optional': [],
    };

    final peerConnection = await webrtc.createPeerConnection(configuration, constraints);

    peerConnection.onIceCandidate = (event) {
      if (event.candidate != null) {
        Map msg = {
          'content': {'data': jsonEncode(event.candidate)},
          'fromId': uid,
          'toId': talkObj['objId'],
          'msgMedia': 3,
          'msgType': 4
        };
        Get.arguments['channel'].sendMessage(jsonEncode(msg));
      }
    };

    peerConnection.onTrack = (event) {};

    return peerConnection;
  }
}
