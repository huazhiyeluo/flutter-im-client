import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/config/configs.dart';

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
      Configs.iceServers,
    ],
    'sdpSemantics': 'unified-plan'
  };

  final Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'width': {'max': 480}, // 设置最大宽度
      'height': {'max': 640}, // 设置最大高度
      'frameRate': {'max': 15}, // 设置最大帧率
      'facingMode': 'user', // 前置摄像头
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

  //创建流
  Future<MediaStream> createStream() async {
    await logPrint("createStream");
    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    onLocalStream?.call(stream);
    return stream;
  }

  //创建session
  Future<Session> createSession(Session? session, int fromId, int toId) async {
    await logPrint("createSession");
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

    pc.onIceCandidate = (RTCIceCandidate candidate) {
      createIceCandidate(candidate, fromId, toId);
    };
    pc.onIceConnectionState = (RTCIceConnectionState state) {};

    newSession.pc = pc;
    return newSession;
  }

  //创建offer
  Future<void> createOffer(Session session) async {
    await logPrint("createOffer");
    try {
      RTCSessionDescription s = await session.pc!.createOffer(offerOptions);
      await session.pc!.setLocalDescription(_fixSdp(s));
      Map<String, dynamic> offerMap = {
        'sdp': s.sdp,
        'type': s.type,
      };
      onSendMsg?.call(session.fromId, session.toId, AppWebsocket.msgTypeAck, AppWebsocket.msgMediaPhoneOffer, json.encode(offerMap));
    } catch (e) {
      await logPrint("createOffer: error ,$e");
    }
  }

  //创建answer
  Future<void> createAnswer(Session session) async {
    await logPrint("createAnswer");
    try {
      RTCSessionDescription s = await session.pc!.createAnswer();
      await session.pc!.setLocalDescription(_fixSdp(s));
      Map<String, dynamic> answerMap = {
        'sdp': s.sdp,
        'type': s.type,
      };
      onSendMsg?.call(session.fromId, session.toId, AppWebsocket.msgTypeAck, AppWebsocket.msgMediaPhoneAnswer, json.encode(answerMap));
    } catch (e) {
      await logPrint("createAnswer: error ,$e");
    }
  }

  //创建IceCandidate
  Future<void> createIceCandidate(RTCIceCandidate candidate, int fromId, int toId) async {
    await Future.delayed(const Duration(seconds: 1), () {
      Map<String, dynamic> candidateMap = {
        'sdpMLineIndex': candidate.sdpMLineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      };
      onSendMsg?.call(fromId, toId, AppWebsocket.msgTypeAck, AppWebsocket.msgMediaPhoneIce, json.encode(candidateMap));
    });
  }

  //关闭所有的留
  Future<void> cleanSessions() async {
    await logPrint("cleanSessions");
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
    await logPrint("closeSession");
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
    await logPrint("invite");
    Session session = await createSession(null, fromId, toId);
    _sessions[fromId] = session;

    await createOffer(session);
    onCallStateChange?.call(session, CallState.callStateNew);
    onCallStateChange?.call(session, CallState.callStateInvite);
  }

  //接通通话
  Future<void> accept(int fromId, int toId) async {
    await logPrint("accept");
    var session = _sessions[fromId];
    if (session == null) {
      return;
    }
    await createAnswer(session);
  }

  //拒接通话
  Future<void> reject(int fromId, int toId) async {
    await logPrint("reject");
    var session = _sessions[fromId];
    if (session == null) {
      return;
    }
    bye(fromId, toId);
  }

  //结束通话
  Future<void> bye(int fromId, int toId) async {
    await logPrint("bye");
    onSendMsg?.call(fromId, toId, AppWebsocket.msgTypeAck, AppWebsocket.msgMediaPhoneQuit, "");
    var session = _sessions[fromId];
    if (session != null) {
      closeSession(session);
    }
  }

  void onReceive(msg) {
    if ([4].contains(msg['msgType'])) {
      //收到offer代表有人邀请你通话
      if (msg['msgMedia'] == AppWebsocket.msgMediaPhoneOffer) {
        _handleOffer(msg);
      }
      //收到answer代表对方接通 （接通后发送answer）
      if (msg['msgMedia'] == AppWebsocket.msgMediaPhoneAnswer) {
        _handleAnswer(msg);
      }

      //收到IceCandidate （发送IceCandidate）
      if (msg['msgMedia'] == AppWebsocket.msgMediaPhoneIce) {
        _handleIceCandidate(msg);
      }

      //挂断
      if (msg['msgMedia'] == AppWebsocket.msgMediaPhoneQuit) {
        Session? session = _sessions.remove(msg['toId']);
        if (session != null) {
          onCallStateChange?.call(session, CallState.callStateBye);
          closeSession(session);
        }
      }
    }
  }

  //1-1、_handleOffer
  void _handleOffer(Map<dynamic, dynamic> msg) async {
    await logPrint("_handleOffer");
    try {
      Session? session = _sessions[msg['toId']];
      Session newSession = await createSession(session, msg['toId'], msg['fromId']);
      _sessions[msg['toId']] = newSession;

      Map offerMap = json.decode(msg['content']['data']);
      RTCSessionDescription offer = RTCSessionDescription(offerMap['sdp'], offerMap['type']);

      await newSession.pc?.setRemoteDescription(offer);

      if (newSession.remoteCandidates.isNotEmpty) {
        for (var candidate in newSession.remoteCandidates) {
          await newSession.pc?.addCandidate(candidate);
        }
        newSession.remoteCandidates.clear();
      }
      onCallStateChange?.call(newSession, CallState.callStateNew);
      onCallStateChange?.call(newSession, CallState.callStateRinging);
    } catch (e) {
      await logPrint("_handleOffer: error ,$e");
    }
  }

  //1-2 _handleAnswer
  void _handleAnswer(Map<dynamic, dynamic> msg) async {
    await logPrint("_handleAnswer");
    try {
      Session? session = _sessions[msg['toId']];
      Map answerMap = json.decode(msg['content']['data']);
      RTCSessionDescription answer = RTCSessionDescription(answerMap['sdp'], answerMap['type']);

      await session?.pc?.setRemoteDescription(answer);

      onCallStateChange?.call(session!, CallState.callStateConnected);
    } catch (e) {
      await logPrint("_handleAnswer: error ,$e");
    }
  }

  //1-3、_handleIceCandidate
  void _handleIceCandidate(Map<dynamic, dynamic> msg) async {
    await logPrint("_handleIceCandidate");
    try {
      Session? session = _sessions[msg['toId']];

      Map candidateMap = json.decode(msg['content']['data']);
      RTCIceCandidate candidate = RTCIceCandidate(candidateMap['candidate'], candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);

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
      await logPrint("_handleIceCandidate: error ,$e");
    }
  }
}
