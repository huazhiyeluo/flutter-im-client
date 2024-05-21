import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/websocket.dart';
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
  final ChatController chatController = Get.put(ChatController());
  final TalkobjController talkobjController = Get.find();
  final WebSocketController webSocketController = Get.find();

  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};

  late webrtc.RTCPeerConnection _peerConnection;
  final _localVideo = webrtc.RTCVideoRenderer();
  final _remoteVideo = webrtc.RTCVideoRenderer();
  late webrtc.MediaStream _localStream;
  int currentType = 0;

  @override
  void initState() {
    super.initState();
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    talkObj = talkobjController.talkObj;
    onReceive();
    initializeRenderers();
    currentType = Get.arguments['type'];
  }

  @override
  void dispose() {
    _localVideo.dispose();
    _remoteVideo.dispose();
    _peerConnection.dispose();
    _localStream.dispose();
    super.dispose();
  }

  Future<void> initializeRenderers() async {
    await _localVideo.initialize();
    await _remoteVideo.initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (currentType == 1) {
      return _toUI();
    } else if (currentType == 2) {
      return _fromUI();
    } else {
      return _phoneUI();
    }
  }

  Widget _phoneUI() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Local Video',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 200,
            child: webrtc.RTCVideoView(_localVideo),
          ),
          const SizedBox(height: 20),
          const Text(
            'Remote Video',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 200,
            child: webrtc.RTCVideoView(_remoteVideo),
          ),
        ],
      ),
    );
  }

  Widget _toUI() {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 80,
          ),
          CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(
              talkObj['icon'],
              scale: 1,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            talkObj['name'],
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "正在呼叫...",
            style: TextStyle(color: Colors.white),
          ),
          Expanded(
            child: Container(),
          ),
          Row(
            children: [
              const SizedBox(width: 30),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _quitPhone();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.red,
                    ), // 按钮背景色
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ), // 文字颜色
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ), // 内边距
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(fontSize: 18),
                    ), // 文字样式
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ), // 圆角边框
                  ),
                  child: const Text("挂断"),
                ),
              ),
              const SizedBox(width: 30),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _fromUI() {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 80,
          ),
          CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(
              talkObj['icon'],
              scale: 1,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            talkObj['name'],
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "正在呼叫...",
            style: TextStyle(color: Colors.white),
          ),
          Expanded(
            child: Container(),
          ),
          Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _quitPhone();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.red,
                    ), // 按钮背景色
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ), // 文字颜色
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ), // 内边距
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(fontSize: 18),
                    ), // 文字样式
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ), // 圆角边框
                  ),
                  child: const Text("挂断"),
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    _doPhone();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.green,
                    ), // 按钮背景色
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ), // 文字颜色
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ), // 内边距
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(fontSize: 18),
                    ), // 文字样式
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ), // 圆角边框
                  ),
                  child: const Text("接听"),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  //交互方法--------------------------------
  void onReceive() {
    webSocketController.message.listen((msg) async {
      if ([4].contains(msg['msgType'])) {
        print(msg);
        if (msg['msgMedia'] == 0) {}
        if (msg['msgMedia'] == 1) {
          //收到语音通话 - 挂断
          Get.toNamed('/talk', arguments: {});
        }
        if (msg['msgMedia'] == 2) {
          await _getData();
        }
        if (msg['msgMedia'] == 3) {
          _handleIceCandidate(msg['content']['data']);
        }
        if (msg['msgMedia'] == 4) {
          _handleOffer(msg['content']['data']);
        }
        if (msg['msgMedia'] == 5) {
          _handleAnswer(msg['content']['data']);
        }
      }
    });
  }

  Future<void> _getData() async {
    await _createConnection();
    await _createStream();
  }

  void _quitPhone() {
    Map msg = {
      'content': {'data': ""},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 1,
      'msgType': 4
    };
    webSocketController.sendMessage(msg);

    Map msgshow = {
      'content': {'data': "挂断电话"},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 13,
      'msgType': 1
    };
    webSocketController.sendMessage(msgshow);
    Get.toNamed('/talk');
  }

  Future<void> _doPhone() async {
    await _getData();
    Map msg = {
      'content': {'data': ""},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 2,
      'msgType': 4
    };
    webSocketController.sendMessage(msg);
    setState(() {
      currentType = 0;
    });
  }

  Future<void> _handleIceCandidate(String candidatestr) async {
    Map candidateMap = json.decode(candidatestr);
    webrtc.RTCIceCandidate candidate = webrtc.RTCIceCandidate(
        candidateMap['candidate'], // ICE 候选字符串
        candidateMap['sdpMid'], // SDP mid
        candidateMap['sdpMLineIndex'] // SDP mline index
        );
    _peerConnection.addCandidate(candidate);
  }

  Future<void> _handleOffer(String offerstr) async {
    Map offerMap = json.decode(offerstr);
    webrtc.RTCSessionDescription offer = webrtc.RTCSessionDescription(offerMap['sdp'], offerMap['type']);
    await _peerConnection.setRemoteDescription(offer);
    await _sendAnswer();
  }

  Future<void> _handleAnswer(String answerstr) async {
    Map answerMap = json.decode(answerstr);
    webrtc.RTCSessionDescription answer = webrtc.RTCSessionDescription(answerMap['sdp'], answerMap['type']);
    _peerConnection.setRemoteDescription(answer);
  }

  Future<void> _sendAnswer() async {
    webrtc.RTCSessionDescription answer = await _peerConnection.createAnswer();
    _peerConnection.setLocalDescription(answer);

    Map<String, dynamic> answerMap = {
      'sdp': answer.sdp,
      'type': answer.type,
    };

    Map msg = {
      'content': {'data': json.encode(answerMap)},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 5,
      'msgType': 4
    };
    webSocketController.sendMessage(msg);
  }

  //RTC--------------------------------

  Future<void> _createStream() async {
    print("_createStream");

    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': true,
    };
    _localStream = await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, _localStream);
    });
    _localVideo.srcObject = _localStream;

    // 创建 RTCOfferOptions 对象
    Map<String, dynamic> offerOptions = {
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    };

    // 创建 offer
    final offer = await _peerConnection.createOffer(offerOptions);

    // 设置本地描述
    await _peerConnection.setLocalDescription(offer);

    Map<String, dynamic> offerMap = {
      'sdp': offer.sdp,
      'type': offer.type,
    };
    Map msg = {
      'content': {'data': json.encode(offerMap)},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 4,
      'msgType': 4
    };

    webSocketController.sendMessage(msg);
  }

  Future<void> _createConnection() async {
    print("_createConnection");
    Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun01.sipphone.com'},
        {'urls': 'stun:stun.ekiga.net'},
        {'urls': 'stun:stun.fwdnet.net'},
        {'urls': 'stun:stun.ideasip.com'},
        {'urls': 'stun:stun.iptel.org'},
        {'urls': 'stun:stun.rixtelecom.se'},
        {'urls': 'stun:stun.schlund.de'},
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
        {'urls': 'stun:stun3.l.google.com:19302'},
        {'urls': 'stun:stun4.l.google.com:19302'},
        {'urls': 'stun:stunserver.org'},
        {'urls': 'stun:stun.softjoys.com'},
        {'urls': 'stun:stun.voiparound.com'},
        {'urls': 'stun:stun.voipbuster.com'},
        {'urls': 'stun:stun.voipstunt.com'},
        {'urls': 'stun:stun.voxgratia.org'},
        {'urls': 'stun:stun.xten.com'},
        {'urls': 'turn:numb.viagenie.ca', 'credential': 'muazkh', 'username': 'webrtc@live.com'},
        {
          'urls': 'turn:192.158.29.39:3478?transport=udp',
          'credential': 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
          'username': '28224511:1379330808'
        },
        {
          'urls': 'turn:192.158.29.39:3478?transport=tcp',
          'credential': 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
          'username': '28224511:1379330808'
        }
      ],
    };
    Map<String, dynamic> constraints = {
      'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
      'optional': [],
    };

    _peerConnection = await webrtc.createPeerConnection(configuration, constraints);

    _peerConnection.onIceCandidate = (event) {
      if (event.candidate != null) {
        Map candidateMap = {
          "candidate": event.candidate, // ICE 候选字符串
          "sdpMid": event.sdpMid, // SDP mid
          "sdpMLineIndex": event.sdpMLineIndex // SDP mline index
        };
        Map msg = {
          'content': {'data': json.encode(candidateMap)},
          'fromId': uid,
          'toId': talkObj['objId'],
          'msgMedia': 3,
          'msgType': 4
        };
        webSocketController.sendMessage(msg);
      }
    };

    _peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteVideo.srcObject = event.streams[0];
      }
    };
  }
}
