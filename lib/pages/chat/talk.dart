import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/common.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/websocket.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/date.dart';
import 'package:qim/utils/permission.dart';
import 'package:qim/utils/savedata.dart';
import 'package:qim/utils/tips.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:qim/widget/chat_message.dart';
import 'package:qim/widget/custom_button.dart';
import 'package:qim/widget/custom_chat_text_field.dart';

class Talk extends StatefulWidget {
  const Talk({super.key});

  @override
  State<Talk> createState() => _TalkState();
}

class _TalkState extends State<Talk> {
  final TalkobjController talkobjController = Get.find();
  Map talkObj = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    talkObj = talkobjController.talkObj;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to previous route
          },
        ),
        title: Row(
          children: [
            Obx(
              () => CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(talkObj['icon'] ?? ''),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Text(
                talkObj['remark'] != '' ? talkObj['remark'] : talkObj['name'],
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 更多选项的操作
              if (talkObj['type'] == 1) {
                Navigator.pushNamed(
                  context,
                  '/user',
                );
              } else if (talkObj['type'] == 2) {
                Navigator.pushNamed(
                  context,
                  '/group',
                );
              }
            },
          ),
        ],
        backgroundColor: Colors.grey[100],
      ),
      body: const TalkPage(),
    );
  }
}

class TalkPage extends StatefulWidget {
  const TalkPage({super.key});

  @override
  State<TalkPage> createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  final WebSocketController webSocketController = Get.find();
  final MessageController messageController = Get.find();
  final TalkobjController talkobjController = Get.find();
  final TextEditingController inputController = TextEditingController();
  final ChatController chatController = Get.put(ChatController());

  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};
  int isShowEmoji = 0;
  int isShowSend = 0;
  int isShowPlus = 0;

  final List<String> emojis = [];
  final List<IconData> icons = [
    Icons.image,
    Icons.camera_alt,
    Icons.call,
    Icons.folder,
  ];

  //语音通话组件
  final Map<String, dynamic> mediaConstraints = {
    'audio': true,
    'video': {
      'mandatory': {
        'minWidth': '480',
        'minHeight': '320',
        'minFrameRate': '30',
      },
      'facingMode': 'user',
      'optional': [],
    }
  };

  final Map<String, dynamic> sdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> pcConstraints = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': false},
    ]
  };

  final Map<String, dynamic> configuration = {
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

  final _localRenderer = webrtc.RTCVideoRenderer();
  final _remoteRenderer = webrtc.RTCVideoRenderer();
  late webrtc.MediaStream _localStream;
  late webrtc.MediaStream _remoteStream;
  late webrtc.RTCPeerConnection _peerConnection;

  int ttype = 0;

  @override
  void initState() {
    super.initState();

    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    talkObj = talkobjController.talkObj;

    for (var i = 0; i <= 124; i++) {
      String temp = i < 10 ? '0$i' : '$i';
      emojis.add('lib/assets/emojis/$temp.gif');
    }
    ttype = Get.arguments != null ? Get.arguments['type'] : 0;
    if (ttype == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dialogUI(2);
      });
    }
    onReceive();
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    inputController.dispose();
    _localRenderer.dispose();
    _localStream.dispose();
    _remoteRenderer.dispose();
    _remoteStream.dispose();
    _peerConnection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: ChatMessage(),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10 - isShowEmoji * 10),
          color: const Color.fromARGB(255, 248, 248, 248),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: CustomChatTextField(
                        controller: inputController,
                        hintText: '输入消息...',
                        expands: true,
                        maxHeight: 200,
                        minHeight: 25,
                        onTap: () {
                          // 处理点击事件的逻辑
                        },
                        onChanged: (String text) {
                          int flag = 0;
                          if (text == '') {
                            flag = 0;
                          } else {
                            flag = 1;
                          }
                          setState(() {
                            isShowSend = flag;
                          });
                        }),
                  ),
                  SizedBox(
                    width: 31,
                    child: IconButton(
                      icon: const Icon(Icons.emoji_emotions),
                      iconSize: 35,
                      padding: const EdgeInsets.all(2),
                      onPressed: () {
                        setState(() {
                          isShowEmoji = 1 - isShowEmoji;
                          isShowPlus = 0;
                        });
                      },
                    ),
                  ),
                  isShowSend == 0 ? _showAdd() : _showSend(),
                ],
              );
            },
          ),
        ),
        isShowEmoji == 1 ? _buildEmoji() : Container(),
        isShowPlus == 1 ? _buildPlus() : Container(),
      ],
    );
  }

  //发送按钮
  Widget _showSend() {
    return SizedBox(
      width: 31,
      child: IconButton(
        icon: const Icon(Icons.send),
        iconSize: 35,
        padding: const EdgeInsets.all(2),
        onPressed: () {
          _sendText();
        },
      ),
    );
  }

  //发送添加按钮
  Widget _showAdd() {
    return SizedBox(
      width: 31,
      child: IconButton(
        icon: const Icon(Icons.add),
        iconSize: 35,
        padding: const EdgeInsets.all(2),
        onPressed: () {
          setState(() {
            isShowPlus = 1 - isShowPlus;
            isShowEmoji = 0;
          });
        },
      ),
    );
  }

  //点击加号出来的操作按钮
  Widget _buildPlus() {
    return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      color: const Color.fromARGB(255, 237, 237, 237),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10.0, // 列之间的间距
          mainAxisSpacing: 0.0, // 行之间的间距
          childAspectRatio: 1.2, // 宽高比
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              setState(() {
                _pick(index);
                isShowPlus = 1 - isShowPlus;
              });
            },
            child: Icon(icons[index], size: 56),
          );
        },
      ),
    );
  }

  //表情列表
  Widget _buildEmoji() {
    return Container(
      height: 350,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      color: const Color.fromARGB(255, 237, 237, 237),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 10.0, // 列之间的间距
          mainAxisSpacing: 0.0, // 行之间的间距
          childAspectRatio: 1.2, // 宽高比
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _sendEmoji(emojis[index]);
              setState(() {
                isShowEmoji = 1 - isShowEmoji;
              });
            },
            child: Image.asset(
              emojis[index],
              scale: 0.75,
            ),
          );
        },
      ),
    );
  }

  _dialogUI(int ttype) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: EdgeInsets.zero, // 设置内容填充为零
            child: Container(
              width: MediaQuery.of(context).size.width, // 使用屏幕宽度作为内容宽度
              height: MediaQuery.of(context).size.height, // 使用屏幕高度作为内容高度
              color: const Color.fromARGB(125, 0, 0, 125), // 设置背景颜色
              child: ttype == 1
                  ? _toUI()
                  : ttype == 2
                      ? _fromUI()
                      : _phoneUI(),
            ),
          );
        });
  }

  Widget _phoneUI() {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Center(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.yellow,
                  child: webrtc.RTCVideoView(_remoteRenderer, mirror: true),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: Colors.red,
                  child: webrtc.RTCVideoView(_localRenderer, mirror: true),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    const SizedBox(width: 30),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          _quitPhone();
                        },
                        text: "挂断",
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
              )
            ],
          ),
        );
      },
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
                child: CustomButton(
                  onPressed: () {
                    _quitPhone();
                  },
                  text: "挂断",
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
                child: CustomButton(
                  onPressed: () {
                    _quitPhone();
                  },
                  text: "挂断",
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    _doPhone();
                  },
                  text: "接听",
                  backgroundColor: Colors.green,
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

  void _sendText() async {
    // 发送按钮的操作
    Map msg = {
      'fromId': uid,
      'toId': talkObj['objId'],
      'content': {"data": inputController.text, "url": "", "name": ""},
      'msgMedia': 1,
      'msgType': talkObj['type']
    };
    _send(msg);

    inputController.text = "";
    setState(() {
      isShowSend = 1 - isShowSend;
    });
  }

  void _sendEmoji(String url) async {
    // 发送按钮的操作
    Map msg = {
      'fromId': uid,
      'toId': talkObj['objId'],
      'content': {"data": "", "url": url, "name": ""},
      'msgMedia': 6,
      'msgType': talkObj['type']
    };
    _send(msg);
  }

  void _sendFile(String url, int msgMedia) async {
    // 发送按钮的操作
    Map msg = {
      'fromId': uid,
      'toId': talkObj['objId'],
      'content': {"data": "", "url": url, "name": ""},
      'msgMedia': msgMedia,
      'msgType': talkObj['type']
    };
    _send(msg);
  }

  void _send(Map msg) async {
    webSocketController.sendMessage(msg);
    if (![1, 2].contains(msg['msgType'])) {
      return;
    }
    msg['createTime'] = getTime();
    msg['avatar'] = userInfo['avatar'];
    messageController.addMessage(msg);
    saveMessage(msg);
    processReceivedMessage(uid, msg, chatController);
  }

  //----------------------------------------------------------------文件处理----------------------------------------------------------------

  Future<void> _pick(int index) async {
    if (index == 0) {
      _pickFile(2);
    }
    if (index == 1) {
      _pickCamera();
    }
    if (index == 2) {
      _goPhone();
    }
    if (index == 3) {
      _pickFile(5);
    }
  }

  Future<void> _pickCamera() async {
    var isGrantedCamera = await PermissionUtil.requestCameraPermission();
    if (!isGrantedCamera) {
      TipHelper.instance.showToast("未允许相机权限");
      return;
    }
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      print('Picked image path: ${pickedFile.path}');
    } else {
      // User canceled the image picking
      print('No image selected.');
    }
  }

  Future<void> _pickFile(int msgMedia) async {
    var isGrantedStorage = await PermissionUtil.requestStoragePermission();
    if (!isGrantedStorage) {
      TipHelper.instance.showToast("未允许存储读写权限");
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      dio.MultipartFile file = await dio.MultipartFile.fromFile(pickedFile.path);
      CommonApi.upload({'file': file}, onSuccess: (res) {
        setState(() {
          _sendFile(res['data'], msgMedia);
        });
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    } else {
      print('No image selected.');
    }
  }

  // ----------------------------------------------------------------语音通话 ----------------------------------------------------------------

  void onReceive() {
    webSocketController.message.listen((msg) async {
      if ([4].contains(msg['msgType'])) {
        if (msg['msgMedia'] == 0) {
          setState(() {
            ttype = 2;
          });
          _dialogUI(2);
        }
        if (msg['msgMedia'] == 1) {
          //收到语音通话 - 挂断
          _close();
          Navigator.of(context).pop(); // 关闭弹窗
        }
        if (msg['msgMedia'] == 2) {
          Navigator.of(context).pop(); // 关闭弹窗
          _initRenderer();
          _createConnection();
          _createStream();
          setState(() {
            ttype = 3;
          });
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

  Future<void> _handleIceCandidate(String candidatestr) async {
    try {
      if (_peerConnection.signalingState != webrtc.RTCSignalingState) {
        Map candidateMap = json.decode(candidatestr);
        webrtc.RTCIceCandidate candidate =
            webrtc.RTCIceCandidate(candidateMap['candidate'], candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);
        await _peerConnection.addCandidate(candidate);
      } else {
        print("Error Remote description is null, unable to add ICE candidate");
      }
    } catch (e) {
      print("Error while adding ICE candidate: $e");
    }
  }

  Future<void> _handleOffer(String offerstr) async {
    try {
      Map offerMap = json.decode(offerstr);
      webrtc.RTCSessionDescription offer = webrtc.RTCSessionDescription(offerMap['sdp'], offerMap['type']);

      // 检查当前状态是否为 "stable"，确保不会在错误的状态下设置远程描述
      if (_peerConnection.signalingState == webrtc.RTCSignalingState.RTCSignalingStateStable) {
        await _peerConnection.setRemoteDescription(offer);
        await _sendAnswer();
      } else {
        print("Error: Called setRemoteDescription in wrong state: ${_peerConnection.signalingState}");
      }
    } catch (e) {
      print("Error while handling offer: $e");
    }
  }

  Future<void> _handleAnswer(String answerstr) async {
    Map answerMap = json.decode(answerstr);
    webrtc.RTCSessionDescription answer = webrtc.RTCSessionDescription(answerMap['sdp'], answerMap['type']);
    await _peerConnection.setRemoteDescription(answer);
  }

  Future<void> _sendAnswer() async {
    // 检查连接状态是否为 'have-remote-offer'
    if (_peerConnection.connectionState == webrtc.RTCIceConnectionState.RTCIceConnectionStateConnected) {
      webrtc.RTCSessionDescription answer = await _peerConnection.createAnswer();
      await _peerConnection.setLocalDescription(answer);

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
    } else {
      print("Error: Unable to send answer, connection state is not suitable.");
    }
  }

  _createConnection() async {
    print("_createConnection");
    try {
      _peerConnection = await webrtc.createPeerConnection(configuration, pcConstraints);
      _peerConnection.onIceCandidate = _onIceCandidate;
      _peerConnection.onIceConnectionState = _onIceConnectionState;
      _peerConnection.onTrack = _onTrack;
    } catch (e) {
      print("Error while creating stream: $e");
    }
  }

  _createStream() async {
    print("_createStream");
    try {
      _localStream = await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
      _localStream.getTracks().forEach((track) {
        _peerConnection.addTrack(track, _localStream);
      });

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
    } catch (e) {
      print("Error while creating stream: $e");
    }
    _dialogUI(3);
  }

  _initRenderer() async {
    try {
      await _localRenderer.initialize();
      print("_localRenderer");
    } catch (e) {
      print("_localRenderer:$e");
    }
    try {
      await _remoteRenderer.initialize();
      print("_remoteRenderer");
    } catch (e) {
      print("_remoteRenderer:$e");
    }
    setState(() {});
  }

  _onIceCandidate(webrtc.RTCIceCandidate candidate) {
    Map<String, dynamic> candidateMap = {
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    };
    Map msg = {
      'content': {'data': json.encode(candidateMap)},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 3,
      'msgType': 4
    };
    webSocketController.sendMessage(msg);
    _peerConnection.addCandidate(candidate);
    print("LIAO:_onRemoteIceConnectionState: $candidate");
  }

  _onIceConnectionState(webrtc.RTCIceConnectionState state) {
    print("LIAO:_onRemoteIceConnectionState: $state");
  }

  _onTrack(webrtc.RTCTrackEvent event) {
    print("LIAO:_onTrack: ${event.track.kind}");
    if (event.track.kind == 'video') {
      _remoteRenderer.srcObject = event.streams[0];
    }
  }

  _close() async {
    try {
      await _localStream.dispose();
      _localRenderer.srcObject = null;
      await _peerConnection.dispose();

      await _remoteStream.dispose();
      _remoteRenderer.srcObject = null;
    } catch (e) {
      print('Error: $e');
    }
  }

  _goPhone() {
    _send({
      'content': {'data': ""},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 0,
      'msgType': 4
    });
    _dialogUI(1);
  }

  _quitPhone() {
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
    _close();
    Navigator.of(context).pop(); // 关闭弹窗
  }

  _doPhone() async {
    print("_doPhone");
    Navigator.of(context).pop(); // 关闭弹窗
    _initRenderer();
    _createConnection();
    _createStream();
    Map msg = {
      'content': {'data': ""},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 2,
      'msgType': 4
    };
    webSocketController.sendMessage(msg);
    setState(() {
      ttype = 3;
    });
  }
}
