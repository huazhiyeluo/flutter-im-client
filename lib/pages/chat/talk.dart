import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qim/api/common.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/group.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/controller/websocket.dart';
import 'package:qim/pages/chat/talk/emoji_list.dart';
import 'package:qim/pages/chat/talk/phone_from.dart';
import 'package:qim/pages/chat/talk/phone_ing.dart';
import 'package:qim/pages/chat/talk/phone_to.dart';
import 'package:qim/pages/chat/talk/plus_list.dart';
import 'package:qim/utils/Signaling.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/date.dart';
import 'package:qim/utils/functions.dart';
import 'package:qim/utils/permission.dart';
import 'package:qim/utils/tips.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:qim/pages/chat/talk/chat_message.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart' as imgcompress;

class Talk extends StatefulWidget {
  const Talk({super.key});

  @override
  State<Talk> createState() => _TalkState();
}

class _TalkState extends State<Talk> {
  final TalkobjController talkobjController = Get.find();
  final UserController userController = Get.find();
  final GroupController groupController = Get.find();

  Map talkObj = {};

  String iconObj = '';
  String textObj = '';

  @override
  void initState() {
    super.initState();
    talkObj = talkobjController.talkObj;
    if (talkObj['type'] == 1) {
      Map? user = userController.getOneUser(talkObj['objId']);
      iconObj = user?['avatar'];
      textObj = user?['username'];
    } else if (talkObj['type'] == 2) {
      Map? group = groupController.getOneGroup(talkObj['objId']);
      iconObj = group?['icon'];
      textObj = "${group?['name']}(${group?['num']})";
    }
  }

  @override
  void dispose() {
    talkobjController.setTalkObj({"objId": 0});
    super.dispose();
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
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(iconObj),
            ),
            const SizedBox(width: 8),
            Text(
              textObj,
              style: const TextStyle(
                fontSize: 20,
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
                  '/user-setting-chat',
                );
              } else if (talkObj['type'] == 2) {
                Navigator.pushNamed(
                  context,
                  '/group-setting',
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
  final UserController userController = Get.find();
  final TextEditingController _inputController = TextEditingController();

  double keyboardHeight = 270.0;
  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};
  Map talkCommonObj = {};
  int isShowEmoji = 0;
  int isShowPlus = 0;

  final _localRenderer = webrtc.RTCVideoRenderer();
  final _remoteRenderer = webrtc.RTCVideoRenderer();
  Signaling? _signaling;
  Session? _session;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
    talkObj = talkobjController.talkObj;
    talkCommonObj = getTalkCommonObj(talkObj);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        isShowEmoji = 0;
        isShowPlus = 0;
      }
    });

    initRenderers();
    _connect(context);
    if (Get.arguments != null) {
      int actionType = Get.arguments['actionType'];
      if (actionType == 1) {
        _invite();
      }
    }
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _inputController.dispose();
    _signaling?.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    talkobjController.setTalkObj({"objId": 0});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (keyboardHeight == 270.0 && MediaQuery.of(context).viewInsets.bottom != 0) {
      keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    }
    return Container(
      decoration: const BoxDecoration(color: Color(0xffefefef)),
      height: double.infinity,
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            isShowEmoji = 0;
            isShowPlus = 0;
          });
        },
        child: Column(
          children: [
            const Expanded(
              child: ChatMessage(),
            ),
            Container(
              height: 45.0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: const BoxDecoration(
                color: Color(0xfff7f7f7),
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.2),
                  bottom: BorderSide(color: Colors.grey, width: 0.2),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ExtendedTextField(
                          onTap: () => setState(() {
                            if (_focusNode.hasFocus) isShowEmoji = 0;
                          }),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(5.0),
                          ),
                          onChanged: (v) => setState(() {}),
                          controller: _inputController,
                          focusNode: _focusNode,
                          maxLines: 99,
                          cursorColor: const Color(0xff07c160),
                          style: const TextStyle(
                            textBaseline: TextBaseline.alphabetic,
                            fontSize: 20,
                            color: Color(0xff181818),
                          ),
                        ),
                      ),
                      _showEmoji(),
                      _inputController.text == "" ? _showPlus() : _showSend(),
                    ],
                  );
                },
              ),
            ),
            Visibility(
              visible: isShowEmoji == 1,
              child: EmojiList(
                  isShowEmoji: isShowEmoji,
                  keyboardHeight: keyboardHeight,
                  onEmoji: (String image) {
                    _sendEmoji(image);
                    setState(() {
                      isShowEmoji = 1 - isShowEmoji;
                    });
                  }),
            ),
            Visibility(
              visible: isShowPlus == 1,
              child: PlusList(
                isShowPlus: isShowPlus,
                keyboardHeight: keyboardHeight,
                isneedphone: talkObj['type'] == 1,
                onPlus: (int index) {
                  setState(() {
                    _pick(index);
                    isShowPlus = 1 - isShowPlus;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _showEmoji() {
    return SizedBox(
      width: 31,
      child: IconButton(
        icon: const Icon(Icons.emoji_emotions),
        iconSize: 35,
        padding: const EdgeInsets.all(2),
        onPressed: () {
          setState(() {
            _focusNode.unfocus();
            isShowEmoji = 1 - isShowEmoji;
            isShowPlus = 0;
          });
        },
      ),
    );
  }

  //发送添加按钮
  Widget _showPlus() {
    return SizedBox(
      width: 31,
      child: IconButton(
        icon: const Icon(Icons.add),
        iconSize: 35,
        padding: const EdgeInsets.all(2),
        onPressed: () {
          setState(() {
            _focusNode.unfocus();
            isShowPlus = 1 - isShowPlus;
            isShowEmoji = 0;
          });
        },
      ),
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
          setState(() {
            _focusNode.unfocus();
          });
          _sendText();
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
                  ? _phoneTo(context)
                  : ttype == 2
                      ? _phoneFrom(context)
                      : _phoneIng(context),
            ),
          );
        });
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

  void _sendText() async {
    if (_inputController.text == "") {
      TipHelper.instance.showToast("bu'd");
      return;
    }
    // 发送按钮的操作
    Map msg = {
      'fromId': uid,
      'toId': talkObj['objId'],
      'content': {"data": _inputController.text, "url": "", "name": ""},
      'msgMedia': 1,
      'msgType': talkObj['type']
    };
    _send(msg);
    _inputController.text = "";
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

  void _sendFile(String url, int msgMedia, String name) async {
    // 发送按钮的操作
    Map msg = {
      'fromId': uid,
      'toId': talkObj['objId'],
      'content': {"data": "", "url": url, "name": name},
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
    joinData(uid, msg);
  }

  //----------------------------------------------------------------文件处理----------------------------------------------------------------

  Future<void> _pick(int val) async {
    if (val == 1) {
      _pickPhoto(2);
    }
    if (val == 2) {
      _pickCamera(2);
    }
    if (val == 3) {
      _invite();
    }
    if (val == 4) {
      _pickFile(3);
    }
    if (val == 5) {
      _pickFile(4);
    }
    if (val == 6) {
      _pickFile(5);
    }
  }

  Future<void> _pickCamera(int msgMedia) async {
    var isGrantedCamera = await PermissionUtil.requestCameraPermission();
    if (!isGrantedCamera) {
      TipHelper.instance.showToast("未允许相机权限");
      return;
    }
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      XFile compressedFile = await _compressImage(pickedFile);
      dio.MultipartFile file = await dio.MultipartFile.fromFile(compressedFile.path);
      CommonApi.upload({'file': file}, onSuccess: (res) {
        setState(() {
          _sendFile(res['data'], msgMedia, pickedFile.name);
        });
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    }
  }

  Future<void> _pickPhoto(int msgMedia) async {
    var isGrantedStorage = await PermissionUtil.requestStoragePermission();
    if (!isGrantedStorage) {
      TipHelper.instance.showToast("未允许存储读写权限");
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      XFile compressedFile = await _compressImage(pickedFile);
      dio.MultipartFile file = await dio.MultipartFile.fromFile(compressedFile.path);
      CommonApi.upload({'file': file}, onSuccess: (res) {
        setState(() {
          _sendFile(res['data'], msgMedia, pickedFile.name);
        });
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    }
  }

  Future<void> _pickFile(int msgMedia) async {
    var isGrantedStorage = await PermissionUtil.requestStoragePermission();
    if (!isGrantedStorage) {
      TipHelper.instance.showToast("未允许存储读写权限");
      return;
    }

    FilePickerResult? result;

    if (msgMedia == 3) {
      result = await FilePicker.platform.pickFiles(type: FileType.audio);
    }
    if (msgMedia == 4) {
      result = await FilePicker.platform.pickFiles(type: FileType.video);
    }
    if (msgMedia == 5) {
      result = await FilePicker.platform.pickFiles(type: FileType.image);
    }

    if (result != null) {
      PlatformFile pickedFile = result.files.first;
      dio.MultipartFile file = await dio.MultipartFile.fromFile(pickedFile.path!);
      CommonApi.upload({'file': file}, onSuccess: (res) {
        setState(() {
          _sendFile(res['data'], msgMedia, pickedFile.name);
        });
      }, onError: (res) {
        TipHelper.instance.showToast(res['msg']);
      });
    }
  }

  Future<XFile> _compressImage(XFile pickedFile) async {
    final dir = await getTemporaryDirectory();

    String fileName = pickedFile.name;
    String fileExtension = fileName.split('.').last;

    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    final result = await imgcompress.FlutterImageCompress.compressAndGetFile(
      File(pickedFile.path).absolute.path,
      targetPath,
      quality: 70,
    );
    return result ?? pickedFile;
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
      _signaling?.onSendMsg!(uid, talkObj['objId'], 4, 2, "");
      await _signaling?.accept(uid, talkObj['objId']);
    }
  }

  //取消
  void _reject() {
    if (_session != null) {
      _signaling?.onSendMsg!(uid, talkObj['objId'], 1, 13, "挂断电话");
      _signaling?.reject(uid, talkObj['objId']);
    }
  }

  //接通后取消
  void _cancel(int num) {
    if (_session != null) {
      _signaling?.onSendMsg!(uid, talkObj['objId'], 1, 12, "$num");
      _signaling?.bye(uid, talkObj['objId']);
    }
  }

  //翻转镜头
  void _switchCamera() {
    _signaling?.switchCamera();
  }

  //关闭开启镜头
  void _turnCamera(bool tnumted) {
    _signaling?.turnCamera(tnumted);
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
      logPrint("$state");
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
      webSocketController.sendMessage(msg);
      if (msgType == 1) {
        msg['createTime'] = getTime();
        joinData(fromId, msg);
      }
    });
  }
}
