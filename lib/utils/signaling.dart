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
      {'urls': 'stun:stun.l.google.com:19302'}
    ],
    'sdpSemantics': 'unified-plan'
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
    print("LIAO _createSession");
    Session newSession = session ?? Session(fromId: fromId, toId: toId);
    _localStream = await createStream();

    RTCPeerConnection pc = await createPeerConnection(configuration, pcConstraints);
    pc.onTrack = (RTCTrackEvent event) {
      print("LIAO onTrack: ${event.track.kind}");
      if (event.track.kind == 'video') {
        onRemoteStream?.call(event.streams[0]);
      }
    };
    _localStream!.getTracks().forEach((MediaStreamTrack track) async {
      await pc.addTrack(track, _localStream!);
    });

    pc.onIceCandidate = (RTCIceCandidate candidate) async {
      print("LIAO onIceCandidate $fromId: ${candidate.toString()}");
      await Future.delayed(const Duration(seconds: 1), () {
        Map<String, dynamic> candidateMap = {
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        };
        onSendMsg?.call(fromId, toId, 4, 3, json.encode(candidateMap));
      });
    };

    pc.onIceConnectionState = (RTCIceConnectionState state) {
      print("LIAO ICE Connection State: $state");
    };

    newSession.pc = pc;
    return newSession;
  }

  //创建流
  Future<MediaStream> createStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '720', // Provide your own width, height and frame rate here
          'minHeight': '1080',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };
    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    onLocalStream?.call(stream);
    return stream;
  }

  //创建offer
  Future<void> createOffer(Session session) async {
    print("createOffer1");
    try {
      RTCSessionDescription s = await session.pc!.createOffer(offerOptions);
      await session.pc!.setLocalDescription(_fixSdp(s));
      Map<String, dynamic> offerMap = {
        'sdp': s.sdp,
        'type': s.type,
      };
      onSendMsg?.call(session.fromId, session.toId, 4, 4, json.encode(offerMap));
      print("createOffer2");
    } catch (e) {
      print(e.toString());
    }
  }

  //创建answer
  Future<void> createAnswer(Session session) async {
    print("createAnswer1");
    try {
      RTCSessionDescription s = await session.pc!.createAnswer();
      await session.pc!.setLocalDescription(_fixSdp(s));
      Map<String, dynamic> answerMap = {
        'sdp': s.sdp,
        'type': s.type,
      };
      onSendMsg?.call(session.fromId, session.toId, 4, 5, json.encode(answerMap));
      print("createAnswer2");
    } catch (e) {
      print(e.toString());
    }
  }

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
    _localStream?.getTracks().forEach((MediaStreamTrack track) async {
      await track.stop();
    });
    await _localStream?.dispose();
    _localStream = null;

    await session.pc?.close();
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
  Future<void> accept(int fromId) async {
    print("accept1 $fromId");
    var session = _sessions[fromId];
    if (session == null) {
      return;
    }
    print("accept2");
    await createAnswer(session);
  }

  //拒接通话
  void reject(int fromId) {
    var session = _sessions[fromId];
    if (session == null) {
      return;
    }
    bye(fromId);
  }

  //结束通话
  void bye(int fromId) {
    var session = _sessions[fromId];
    if (session != null) {
      onSendMsg?.call(session.fromId, session.toId, 4, 1, "");
      closeSession(session);
    }
  }

  void onReceive(WebSocketController webSocketController) {
    print("LIAO onReceive");
    webSocketController.message.listen((msg) async {
      print("LIAO onReceive $msg");
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
    print("LIAO _handleIceCandidate");
    try {
      Session? session = _sessions[msg['toId']];

      Map candidateMap = json.decode(msg['content']['data']);
      RTCIceCandidate candidate =
          RTCIceCandidate(candidateMap['candidate'], candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);

      print("Received ICE Candidate: ${candidate.toString()}");

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
    } catch (e) {
      print("LIAO _handleIceCandidate Error: $e");
    }
  }

  //1-2、_handleOffer
  void _handleOffer(Map<dynamic, dynamic> msg) async {
    print("LIAO _handleOffer");
    print("LIAO _handleOffer ${msg['toId']}");
    try {
      Session? session = _sessions[msg['toId']];
      Session newSession = await createSession(session, msg['toId'], msg['fromId']);
      _sessions[msg['toId']] = newSession;

      Map offerMap = json.decode(msg['content']['data']);
      RTCSessionDescription offer = RTCSessionDescription(offerMap['sdp'], offerMap['type']);
      print("Received SDP Offer: $offer");

      await newSession.pc?.setRemoteDescription(offer);

      if (newSession.remoteCandidates.isNotEmpty) {
        newSession.remoteCandidates.forEach((candidate) async {
          await newSession.pc?.addCandidate(candidate);
        });
        newSession.remoteCandidates.clear();
      }
      onCallStateChange?.call(newSession, CallState.callStateNew);
      onCallStateChange?.call(newSession, CallState.callStateRinging);
    } catch (e) {
      print("LIAO _handleOffer Error:1 $e");
    }
  }

  //1-3 _handleAnswer
  void _handleAnswer(Map<dynamic, dynamic> msg) async {
    print("LIAO _handleAnswer");
    try {
      Session? session = _sessions[msg['toId']];
      Map answerMap = json.decode(msg['content']['data']);
      RTCSessionDescription answer = RTCSessionDescription(answerMap['sdp'], answerMap['type']);
      print("Received SDP Answer: $answer");

      await session?.pc?.setRemoteDescription(answer);

      onCallStateChange?.call(session!, CallState.callStateConnected);
    } catch (e) {
      print("LIAO _handleAnswer Error: $e");
    }
  }
}
