import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:qim/controller/websocket.dart';

class Session {
  Session({required this.fromId, required this.toId});
  int fromId;
  int toId;
  RTCPeerConnection? pc;
  List<RTCIceCandidate> remoteCandidates = [];
}

enum SignalingState {
  connectionOpen,
  connectionClosed,
  connectionError,
}

enum CallState {
  callStateNew,
  callStateRinging,
  callStateInvite,
  callStateConnected,
  callStateBye,
}

class Signaling {
  Signaling();

  final Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'turn:139.196.98.139:3478?transport=tcp', 'credential': 'liaoabc', 'nickname': 'liao'},
    ],
    'sdpSemantics': 'unified-plan'
  };

  final Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'mandatory': {
        'maxWidth': '480', // 设置最大值
        'maxHeight': '640', // 设置最小值
        'maxFrameRate': '15', // 设置最大值
      },
      'facingMode': 'user',
      'optional': [],
    }
  };

  final Map<String, dynamic> pcConstraints = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': false},
    ]
  };

  final Map<String, dynamic> offerOptions = {
    'offerToReceiveAudio': true,
    'offerToReceiveVideo': true,
  };

  final Map<int, Session> _sessions = {};
  MediaStream? _localStream;
  late WebSocketController webSocketController;

  Function(SignalingState state)? onSignalingStateChange;
  Function(Session session, CallState state)? onCallStateChange;
  Function(MediaStream stream)? onLocalStream;
  Function(MediaStream stream)? onRemoteStream;

  Function(int fromId, int toId, int msgType, int msgMedia, String data)? onSendMsg;

  // 修复数据
  RTCSessionDescription _fixSdp(RTCSessionDescription s) {
    var sdp = s.sdp;
    s.sdp = sdp!.replaceAll('profile-level-id=640c1f', 'profile-level-id=42e032');
    return s;
  }

  //连接监控
  Future<void> connect(WebSocketController webSocketController) async {
    onReceive(webSocketController);
  }

  //创建session
  Future<Session> createSession(Session? session, int fromId, int toId) async {
    Session newSession = session ?? Session(fromId: fromId, toId: toId);
    _localStream = await createStream();

    RTCPeerConnection pc = await createPeerConnection(configuration, pcConstraints);
    pc.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        onRemoteStream?.call(event.streams[0]);
      }
    };
    _localStream!.getTracks().forEach((MediaStreamTrack track) async {
      await pc.addTrack(track, _localStream!);
    });

    pc.onIceCandidate = (RTCIceCandidate candidate) async {
      await Future.delayed(const Duration(seconds: 1), () {
        Map<String, dynamic> candidateMap = {
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        };
        onSendMsg?.call(fromId, toId, 4, 3, json.encode(candidateMap));
      });
    };

    pc.onIceConnectionState = (RTCIceConnectionState state) {};

    newSession.pc = pc;
    return newSession;
  }

  //创建流
  Future<MediaStream> createStream() async {
    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    onLocalStream?.call(stream);
    return stream;
  }

  //创建offer
  Future<void> createOffer(Session session) async {
    try {
      RTCSessionDescription s = await session.pc!.createOffer(offerOptions);
      await session.pc!.setLocalDescription(_fixSdp(s));
      Map<String, dynamic> offerMap = {
        'sdp': s.sdp,
        'type': s.type,
      };
      onSendMsg?.call(session.fromId, session.toId, 4, 4, json.encode(offerMap));
    } catch (e) {}
  }

  //创建answer
  Future<void> createAnswer(Session session) async {
    try {
      RTCSessionDescription s = await session.pc!.createAnswer();
      await session.pc!.setLocalDescription(_fixSdp(s));
      Map<String, dynamic> answerMap = {
        'sdp': s.sdp,
        'type': s.type,
      };
      onSendMsg?.call(session.fromId, session.toId, 4, 5, json.encode(answerMap));
    } catch (e) {}
  }

  //关闭所有的留
  Future<void> cleanSessions() async {
    if (_localStream != null) {
      _localStream!.getTracks().forEach((MediaStreamTrack track) async {
        await track.stop();
      });
      await _localStream!.dispose();
      _localStream = null;
    }
    _sessions.forEach((key, session) async {
      await session.pc?.close();
    });
    _sessions.clear();
  }

  Future<void> closeSession(Session session) async {
    if (_localStream != null) {
      _localStream?.getTracks().forEach((MediaStreamTrack track) async {
        await track.stop();
      });
      await _localStream?.dispose();
      _localStream = null;
    }
    await session.pc?.close();
  }

  void switchCamera() async {
    if (_localStream!.getVideoTracks().isNotEmpty) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void turnCamera(bool numted) async {
    if (_localStream!.getVideoTracks().isNotEmpty) {
      _localStream!.getVideoTracks()[0].enabled = numted;
    }
  }

  //关闭
  void close() async {
    await cleanSessions();
  }

  //邀请通话
  void invite(int fromId, int toId) async {
    Session session = await createSession(null, fromId, toId);
    _sessions[fromId] = session;

    await createOffer(session);
    onCallStateChange?.call(session, CallState.callStateNew);
    onCallStateChange?.call(session, CallState.callStateInvite);
  }

  //接通通话
  Future<void> accept(int fromId, int toId) async {
    var session = _sessions[fromId];
    if (session == null) {
      return;
    }
    await createAnswer(session);
  }

  //拒接通话
  void reject(int fromId, int toId) {
    var session = _sessions[fromId];
    if (session == null) {
      return;
    }
    bye(fromId, toId);
  }

  //结束通话
  void bye(int fromId, int toId) {
    onSendMsg?.call(fromId, toId, 4, 1, "");
    var session = _sessions[fromId];
    if (session != null) {
      closeSession(session);
    }
  }

  void onReceive(WebSocketController webSocketController) {
    webSocketController.message.listen((msg) async {
      if ([4].contains(msg['msgType'])) {
        if (msg['msgMedia'] == 1) {
          Session? session = _sessions.remove(msg['toId']);
          if (session != null) {
            onCallStateChange?.call(session, CallState.callStateBye);
            closeSession(session);
          }
        }
        if (msg['msgMedia'] == 3) {
          _handleIceCandidate(msg);
        }
        //收到offer代表有人邀请你通话
        if (msg['msgMedia'] == 4) {
          _handleOffer(msg);
        }

        //收到answer代表对方接通 （接通后发送answer）
        if (msg['msgMedia'] == 5) {
          _handleAnswer(msg);
        }
      }
    });
  }

  //1-1、_handleIceCandidate
  void _handleIceCandidate(Map<dynamic, dynamic> msg) async {
    try {
      Session? session = _sessions[msg['toId']];

      Map candidateMap = json.decode(msg['content']['data']);
      RTCIceCandidate candidate =
          RTCIceCandidate(candidateMap['candidate'], candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);

      if (session != null) {
        if (session.pc != null) {
          await session.pc?.addCandidate(candidate);
        } else {
          session.remoteCandidates.add(candidate);
        }
      } else {
        _sessions[msg['toId']] = Session(fromId: msg['toId'], toId: msg['fromId']);
        _sessions[msg['toId']]?.remoteCandidates.add(candidate);
      }
    } catch (e) {}
  }

  //1-2、_handleOffer
  void _handleOffer(Map<dynamic, dynamic> msg) async {
    try {
      Session? session = _sessions[msg['toId']];
      Session newSession = await createSession(session, msg['toId'], msg['fromId']);
      _sessions[msg['toId']] = newSession;

      Map offerMap = json.decode(msg['content']['data']);
      RTCSessionDescription offer = RTCSessionDescription(offerMap['sdp'], offerMap['type']);

      await newSession.pc?.setRemoteDescription(offer);

      if (newSession.remoteCandidates.isNotEmpty) {
        newSession.remoteCandidates.forEach((candidate) async {
          await newSession.pc?.addCandidate(candidate);
        });
        newSession.remoteCandidates.clear();
      }
      onCallStateChange?.call(newSession, CallState.callStateNew);
      onCallStateChange?.call(newSession, CallState.callStateRinging);
    } catch (e) {}
  }

  //1-3 _handleAnswer
  void _handleAnswer(Map<dynamic, dynamic> msg) async {
    try {
      Session? session = _sessions[msg['toId']];
      Map answerMap = json.decode(msg['content']['data']);
      RTCSessionDescription answer = RTCSessionDescription(answerMap['sdp'], answerMap['type']);

      await session?.pc?.setRemoteDescription(answer);

      onCallStateChange?.call(session!, CallState.callStateConnected);
    } catch (e) {}
  }
}
