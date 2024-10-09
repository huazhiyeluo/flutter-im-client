import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:qim/data/controller/websocket.dart';
import 'package:qim/data/db/get.dart';
import 'package:qim/pages/chat/talk/phone_from.dart';
import 'package:qim/pages/chat/talk/phone_ing.dart';
import 'package:qim/pages/chat/talk/phone_to.dart';
import 'package:qim/common/utils/common.dart';
import 'package:qim/common/utils/date.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/common/utils/signaling.dart';

class SignalingController extends GetxController {
  final int fromId;
  final BuildContext context;
  final WebSocketController webSocketController;

  // 构造函数
  SignalingController({
    required this.fromId,
    required this.context,
    required this.webSocketController,
  });

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  Signaling? _signaling;
  Session? _session;

  late Map talkCommonObj;
  int toId = 0;

  // 关闭连接
  @override
  void onClose() {
    _signaling?.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.onClose();
  }

  // 初始化渲染器
  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<bool?> _dialogUI(int ttype) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: const Color.fromARGB(125, 0, 0, 125),
            child: ttype == 1
                ? _phoneTo(context)
                : ttype == 2
                    ? _phoneFrom(context)
                    : _phoneIng(context),
          ),
        ),
        fullscreenDialog: true, // 设置为全屏对话框
      ),
    );
  }

  Widget _phoneIng(BuildContext context) {
    return PhoneIng(
      remoteRenderer: _remoteRenderer,
      localRenderer: _localRenderer,
      onPhoneQuit: (int num) {
        Navigator.of(context).pop(false);
        _cancel(num);
      },
      switchCamera: () {
        _switchCamera();
      },
      turnCamera: (bool numted) {
        _turnCamera(numted);
      },
    );
  }

  Widget _phoneTo(BuildContext context) {
    return PhoneTo(
      talkCommonObj: talkCommonObj,
      onPhoneCancel: () {
        Navigator.of(context).pop(false);
        _reject();
      },
    );
  }

  Widget _phoneFrom(BuildContext context) {
    return PhoneFrom(
      talkCommonObj: talkCommonObj,
      onPhoneQuit: () {
        Navigator.of(context).pop(false);
      },
      onPhoneAccept: () {
        Navigator.of(context).pop(true);
      },
    );
  }

  // 邀请通话
  void invite(Map talkObj) async {
    talkCommonObj = talkObj;
    toId = talkCommonObj["objId"];
    await initRenderers();
    await _connect();
    if (_signaling != null) {
      _signaling?.invite(fromId, toId);
    }
  }

  // 收到请求
  void handinvite(Map msg) async {
    await logPrint("handinvite: 1 ,$msg");
    if (msg['msgMedia'] == 1) {
      Map<String, dynamic>? objUser = await getDbOneUser(msg['fromId']);
      if (objUser == null) {
        return;
      }
      talkCommonObj = {
        "objId": msg['fromId'],
        "name": objUser['nickname'],
        "icon": objUser['avatar'],
      };
      toId = talkCommonObj["objId"];
      await initRenderers();
      await _connect();
    }
    _signaling?.onReceive(msg);
  }

  // 接通
  void _accept() async {
    if (_session != null) {
      await _signaling?.accept(fromId, toId);
    }
  }

  // 拒绝通话
  void _reject() {
    if (_session != null) {
      _signaling?.onSendMsg!(fromId, toId, 1, 13, "挂断电话");
      _signaling?.reject(fromId, toId);
    }
  }

  // 取消通话
  void _cancel(int num) {
    if (_session != null) {
      _signaling?.onSendMsg!(fromId, toId, 1, 12, "$num");
      _signaling?.bye(fromId, toId);
    }
  }

  // 翻转镜头
  void _switchCamera() {
    _signaling?.switchCamera();
  }

  // 关闭/开启镜头
  void _turnCamera(bool muted) {
    _signaling?.turnCamera(muted);
  }

  Future<void> _connect() async {
    await logPrint("handinvite: 4 ,_connect");
    _signaling ??= Signaling();
    _signaling?.onSignalingStateChange = (SignalingState state) {
      switch (state) {
        case SignalingState.connectionClosed:
        case SignalingState.connectionError:
        case SignalingState.connectionOpen:
          break;
      }
    };
    _signaling?.onCallStateChange = (Session session, CallState state) async {
      logPrint("$state");
      switch (state) {
        case CallState.callStateNew:
          _session = session;
          break;
        case CallState.callStateRinging:
          bool? accept = await _dialogUI(2);
          if (accept!) {
            _accept();
            await _dialogUI(3);
          } else {
            _reject();
          }
          break;
        case CallState.callStateBye:
          Navigator.of(context).pop(false);
          _localRenderer.srcObject = null;
          _remoteRenderer.srcObject = null;
          _session = null;
          _signaling?.close();
          break;
        case CallState.callStateInvite:
          await _dialogUI(1);
          break;
        case CallState.callStateConnected:
          Navigator.of(context).pop(false);
          await _dialogUI(3);
          break;
      }
    };

    _signaling?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
    });

    _signaling?.onRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
    });

    _signaling?.onSendMsg = ((int fromId, int toId, int msgType, int msgMedia, String data) {
      Map msg = {
        'content': {'data': data},
        'fromId': fromId,
        'toId': toId,
        'msgType': msgType,
        'msgMedia': msgMedia,
      };
      webSocketController.sendMessage(msg);
      if (msgType == 1) {
        msg['createTime'] = getTime();
        joinData(fromId, msg);
      }
    });
  }
}
