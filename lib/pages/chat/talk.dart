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
import 'package:qim/utils/tips.dart';
import 'package:qim/widget/chat_message.dart';
import 'package:qim/widget/custom_chat_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

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
      {'url': 'stun:stun.l.google.com:19302'},
    ]
  };

  final _localRenderer = webrtc.RTCVideoRenderer();
  final _remoteRenderer = webrtc.RTCVideoRenderer();
  late webrtc.MediaStream _localStream;
  late webrtc.MediaStream _remoteStream;
  late webrtc.RTCPeerConnection _localConnection;
  late webrtc.RTCPeerConnection _remoteConnection;
  bool _isContact = false;

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
    onReceive();
    ttype = Get.arguments != null ? Get.arguments['type'] : 0;
    if (ttype == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dialogUI(2);
      });
    }
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    inputController.dispose();
    _localRenderer.dispose();
    _localStream.dispose();
    _localConnection.dispose();

    _remoteRenderer.dispose();
    _remoteStream.dispose();
    _remoteConnection.dispose();
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
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: Colors.white,
                  child: webrtc.RTCVideoView(_localRenderer, mirror: true),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.red,
                  child: webrtc.RTCVideoView(_remoteRenderer, mirror: true),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
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
                            const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
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
                  isShowSend == 0
                      ? SizedBox(
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
                        )
                      : SizedBox(
                          width: 31,
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            iconSize: 35,
                            padding: const EdgeInsets.all(2),
                            onPressed: () {
                              _sendText();
                            },
                          ),
                        ),
                ],
              );
            },
          ),
        ),
        isShowEmoji == 1
            ? Container(
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
              )
            : Container(),
        isShowPlus == 1
            ? Container(
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
              )
            : Container(),
      ],
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
  Future<void> _dialogUI(int ttype) async {
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
    return Center();
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

  void onReceive() {
    webSocketController.message.listen((msg) async {
      if ([4].contains(msg['msgType'])) {
        if (msg['msgMedia'] == 0) {}
        if (msg['msgMedia'] == 1) {
          //收到语音通话 - 挂断
          Navigator.of(context).pop(); // 关闭对话框
        }
        if (msg['msgMedia'] == 2) {
          _doPhone();
        }
        if (msg['msgMedia'] == 3) {}
        if (msg['msgMedia'] == 4) {}
        if (msg['msgMedia'] == 5) {}
      }
    });
  }

  _initRenderer() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      print("_initRendere");
    } catch (e) {
      print("_initRenderer:$e");
    }
  }

  _onIceCandidate(webrtc.RTCIceCandidate candidate) {
    _remoteConnection.addCandidate(candidate);
    print("LIAO:_onRemoteIceConnectionState: $candidate");
  }

  _onIceConnectionState(webrtc.RTCIceConnectionState state) {
    print("LIAO:_onRemoteIceConnectionState: $state");
  }

  _onRemoteIceCandidate(webrtc.RTCIceCandidate candidate) {
    _localConnection.addCandidate(candidate);
    print("LIAO:_onRemoteIceConnectionState: $candidate");
  }

  _onRemoteIceConnectionState(webrtc.RTCIceConnectionState state) {
    print("LIAO:_onRemoteIceConnectionState: $state");
  }

  _onTrack(webrtc.RTCTrackEvent event) {
    if (event.track.kind == 'video') {
      _remoteRenderer.srcObject = event.streams[0];
    }
  }

  _open() async {
    if (_isContact) return;
    try {
      print("_open");
      _localStream = await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
      setState(() {
        _localRenderer.srcObject = _localStream;
      });

      _localConnection = await webrtc.createPeerConnection(configuration, pcConstraints);
      _localConnection.onIceCandidate = _onIceCandidate;
      _localConnection.onIceConnectionState = _onIceConnectionState;

      _localStream.getTracks().forEach((track) {
        _localConnection.addTrack(track, _localStream);
      });
      _localStream.getAudioTracks()[0].enableSpeakerphone(false);

      _remoteConnection = await webrtc.createPeerConnection(configuration, pcConstraints);
      _remoteConnection.onIceCandidate = _onRemoteIceCandidate;
      _remoteConnection.onIceConnectionState = _onRemoteIceConnectionState;
      _remoteConnection.onTrack = _onTrack;

      webrtc.RTCSessionDescription offer = await _localConnection.createOffer(sdpConstraints);
      _localConnection.setLocalDescription(offer);
      _remoteConnection.setRemoteDescription(offer);

      webrtc.RTCSessionDescription answer = await _remoteConnection.createAnswer(sdpConstraints);
      _remoteConnection.setLocalDescription(answer);
      _localConnection.setRemoteDescription(answer);
    } catch (e) {
      print('Error: $e');
    }
    if (!mounted) return;
    setState(() {
      _isContact = true;
    });
  }

  _close() async {
    try {
      await _localStream.dispose();
      _localRenderer.srcObject = null;
      await _localConnection.dispose();

      await _remoteStream.dispose();
      _remoteRenderer.srcObject = null;
      await _remoteConnection.dispose();
    } catch (e) {
      print('Error: $e');
    }
    if (!mounted) return;
    setState(() {
      _isContact = false;
    });
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
    _close();
    Navigator.of(context).pop(); // 关闭对话框
  }

  _doPhone() async {
    Navigator.of(context).pop();
    await _initRenderer();
    // await _dialogUI(3);
    setState(() {
      ttype = 3;
    });
    _open();
  }
}
