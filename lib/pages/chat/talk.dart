import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/api/common.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/websocket.dart';
import 'package:qim/utils/Signaling.dart';
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

  String remoteText = "remoteText";

  final List<String> emojis = [];
  final List<IconData> icons = [
    Icons.image,
    Icons.camera_alt,
    Icons.call,
    Icons.folder,
  ];

  final _localRenderer = webrtc.RTCVideoRenderer();
  final _remoteRenderer = webrtc.RTCVideoRenderer();
  Signaling? _signaling;
  Session? _session;

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
    initRenderers();
    _connect(context);
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    inputController.dispose();
    _signaling?.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
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

  Future<bool?> _dialogUI(int ttype) async {
    return showDialog(
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
              Positioned.fill(
                child: _remoteRenderer.srcObject != null
                    ? webrtc.RTCVideoView(
                        _remoteRenderer,
                        mirror: true,
                        objectFit: webrtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : Text('r $remoteText'),
              ),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 150,
                  height: 200,
                  child: _localRenderer.srcObject != null
                      ? webrtc.RTCVideoView(
                          _localRenderer,
                          mirror: true,
                          objectFit: webrtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : Text('Waiting for local video...'),
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
                          Navigator.of(context).pop(false);
                          _cancel();
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
                    Navigator.of(context).pop(false);
                    _cancel();
                  },
                  text: "取消",
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
                    Navigator.of(context).pop(false);
                  },
                  text: "挂断",
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
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
      _invite();
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

  //----------------------------------------------------------------通话----------------------------------------------------------------

  //邀请
  void _invite() async {
    if (_signaling != null) {
      _signaling?.invite(uid, talkObj['objId']);
    }
  }

  //接通
  void _accept() async {
    if (_session != null) {
      await _signaling?.accept(_session!.fromId);
    }
  }

  //拒接
  void _reject() {
    if (_session != null) {
      _signaling?.reject(_session!.fromId);
    }
  }

  //取消
  void _cancel() {
    if (_session != null) {
      _signaling?.bye(_session!.fromId, uid, talkObj['objId']);
    }
  }

  void _connect(BuildContext context) async {
    _signaling ??= Signaling()..connect(webSocketController);
    _signaling?.onSignalingStateChange = (SignalingState state) {
      switch (state) {
        case SignalingState.connectionClosed:
        case SignalingState.connectionError:
        case SignalingState.connectionOpen:
          break;
      }
    };

    _signaling?.onCallStateChange = (Session session, CallState state) async {
      print("onCallStateChange $state");
      switch (state) {
        case CallState.callStateNew:
          setState(() {
            _session = session;
          });
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
          setState(() {
            _localRenderer.srcObject = null;
            _remoteRenderer.srcObject = null;
            _session = null;
          });
          break;
        case CallState.callStateInvite:
          await _dialogUI(1);
          break;
        case CallState.callStateConnected:
          Navigator.of(context).pop(false);
          await _dialogUI(3);
          break;
        case CallState.callStateRinging:
      }
    };

    _signaling?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
      setState(() {});
    });

    _signaling?.onRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    _signaling?.onSendMsg = ((int fromId, int toId, int msgType, int msgMedia, String data) {
      Map msg = {
        'content': {'data': data},
        'fromId': fromId,
        'toId': toId,
        'msgType': msgType,
        'msgMedia': msgMedia,
      };
      print("LIAO MSG: $msg}");
      webSocketController.sendMessage(msg);
    });
  }
}