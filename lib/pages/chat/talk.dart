import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/api/common.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/message.dart';
import 'package:qim/data/controller/talk.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/controller/websocket.dart';
import 'package:qim/pages/chat/talk/emoji_list.dart';
import 'package:qim/pages/chat/talk/plus_list.dart';
import 'package:qim/common/utils/common.dart';
import 'package:qim/common/utils/date.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/common/utils/permission.dart';
import 'package:qim/data/controller/signaling.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:qim/pages/chat/talk/chat_message.dart';
import 'package:extended_text_field/extended_text_field.dart';

class Talk extends StatefulWidget {
  const Talk({super.key});

  @override
  State<Talk> createState() => _TalkState();
}

class _TalkState extends State<Talk> {
  final UserInfoController userInfoController = Get.find();
  final TalkController talkObjController = Get.find();
  final UserController userController = Get.find();
  final GroupController groupController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final ContactGroupController contactGroupController = Get.find();

  Map talkObj = {};
  Map userInfo = {};
  int uid = 0;

  String iconObj = '';
  String textObj = '';
  String nickname = '';

  @override
  void initState() {
    super.initState();
    talkObj = Get.arguments ?? {};
    talkObjController.setTalk(talkObj);

    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    _initData();
  }

  void _initData() async {
    if (talkObj['type'] == ObjectTypes.user) {
      await initOneUser(talkObj['objId']);
    } else if (talkObj['type'] == ObjectTypes.group) {
      await initOneGroup(talkObj['objId']);
    }
  }

  @override
  void dispose() {
    super.dispose();
    talkObjController.setTalk({});
  }

  Widget _buildTitle() {
    if (talkObj['type'] == ObjectTypes.user) {
      return _buildUserTitle();
    } else if (talkObj['type'] == ObjectTypes.group) {
      return _buildGroupTitle();
    }
    return Container();
  }

  Row _buildUserTitle() {
    Map userObj = userController.getOneUser(talkObj['objId']);
    iconObj = userObj['avatar'];
    nickname = userObj['nickname'];

    Map contactFriendObj = contactFriendController.getOneContactFriend(uid, talkObj['objId']);
    textObj = contactFriendObj.isNotEmpty && contactFriendObj['joinTime'] > 0 ? (contactFriendObj['remark'].isNotEmpty ? contactFriendObj['remark'] : nickname) : (talkObj['objId'] == uid ? nickname : "$nickname(临时聊天)");

    return _buildTitleRow(iconObj, textObj);
  }

  Row _buildGroupTitle() {
    Map groupObj = groupController.getOneGroup(talkObj['objId']);
    Map contactGroupObj = contactGroupController.getOneContactGroup(uid, talkObj['objId']);
    iconObj = groupObj['icon'];
    textObj = "${contactGroupObj['remark'].isNotEmpty ? contactGroupObj['remark'] : groupObj['name']}(${groupObj['num']})";

    return _buildTitleRow(iconObj, textObj);
  }

  Row _buildTitleRow(String icon, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 15, backgroundImage: NetworkImage(icon)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 20)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (talkObj.isEmpty) {
      return const Center(child: Text(""));
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to previous route
          },
        ),
        title: Obx(() => _buildTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 更多选项的操作
              if (talkObj['type'] == ObjectTypes.user) {
                Navigator.pushNamed(
                  context,
                  '/friend-chat-setting',
                  arguments: talkObj,
                );
              } else if (talkObj['type'] == ObjectTypes.group) {
                Navigator.pushNamed(
                  context,
                  '/group-chat-setting',
                  arguments: talkObj,
                );
              }
            },
          ),
        ],
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
  final TalkController talkObjController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final WebSocketController webSocketController = Get.find();
  final SignalingController signalingController = Get.find();
  final MessageController messageController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  final TextEditingController _inputController = TextEditingController();

  double keyboardHeight = 270.0;
  int uid = 0;
  Map userInfo = {};
  Map talkObj = {};
  Map talkCommonObj = {};
  bool isShowEmoji = false;
  bool isShowPlus = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    talkObj = talkObjController.talkObj;
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    talkCommonObj = getTalkCommonObj(talkObj);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        isShowEmoji = false;
        isShowPlus = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _inputController.dispose();
    talkObjController.setTalk({});
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
      child: Column(
        children: [
          const Expanded(
            child: ChatMessage(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            constraints: const BoxConstraints(
              minHeight: 45.0,
              maxHeight: 135.0,
            ),
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
                          if (_focusNode.hasFocus) {
                            isShowEmoji = false;
                            isShowPlus = false;
                          }
                        }),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(5.0),
                        ),
                        onChanged: (v) => setState(() {}),
                        controller: _inputController,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 5,
                        cursorColor: const Color(0xff07c160),
                        style: const TextStyle(
                          textBaseline: TextBaseline.alphabetic,
                          fontSize: 20,
                          color: Color(0xff181818),
                        ),
                      ),
                    ),
                    _showEmoji(),
                    _inputController.text.trim() == "" ? _showPlus() : _showSend(),
                  ],
                );
              },
            ),
          ),
          Visibility(
            visible: isShowEmoji,
            child: EmojiList(
                isShowEmoji: isShowEmoji,
                keyboardHeight: keyboardHeight,
                onEmoji: (String image) {
                  _sendEmoji(image);
                  setState(() {
                    isShowEmoji = !isShowEmoji;
                  });
                }),
          ),
          Visibility(
            visible: isShowPlus,
            child: PlusList(
              isShowPlus: isShowPlus,
              keyboardHeight: keyboardHeight,
              isneedphone: talkObj['type'] == ObjectTypes.user && talkObj['objId'] != uid,
              onPlus: (int index) {
                _pick(index);
                setState(() {
                  isShowPlus = !isShowPlus;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  //显示表情
  Widget _showEmoji() {
    return SizedBox(
      width: 31,
      child: IconButton(
        icon: const Icon(Icons.emoji_emotions),
        iconSize: 35,
        padding: const EdgeInsets.all(2),
        onPressed: () {
          setState(() {
            _focusNode.unfocus();
            isShowEmoji = !isShowEmoji;
            isShowPlus = false;
          });
        },
      ),
    );
  }

  //显示加号
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
            isShowPlus = !isShowPlus;
            isShowEmoji = false;
          });
        },
      ),
    );
  }

  //显示发送
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

  // 发送文本
  void _sendText() async {
    if (_inputController.text.trim() == "") {
      TipHelper.instance.showToast("消息不得为空");
      return;
    }
    Map msg = {
      'fromId': uid,
      'toId': talkObj['objId'],
      'content': {"data": _inputController.text, "url": "", "name": ""},
      'msgType': talkObj['type'],
      'msgMedia': AppWebsocket.msgMediaText
    };
    _send(msg);
    _inputController.text = "";
  }

  // 发送表情
  void _sendEmoji(String url) async {
    Map msg = {
      'fromId': uid,
      'toId': talkObj['objId'],
      'content': {"data": "", "url": url, "name": ""},
      'msgType': talkObj['type'],
      'msgMedia': AppWebsocket.msgMediaEmoji
    };
    _send(msg);
  }

  // 发送文件
  void _sendFile(String url, int msgMedia, String name) async {
    Map msg = {
      'fromId': uid,
      'toId': talkObj['objId'],
      'content': {"data": "", "url": url, "name": name},
      'msgType': talkObj['type'],
      'msgMedia': msgMedia
    };
    _send(msg);
  }

  // 实际发送
  void _send(Map msg) async {
    msg["id"] = genGUID();
    msg['createTime'] = getTime();
    webSocketController.sendMessage(msg);
    if (![
      AppWebsocket.msgTypeSingle,
      AppWebsocket.msgTypeRoom,
    ].contains(msg['msgType'])) {
      return;
    }
    joinData(uid, msg);
  }

  //----------------------------------------------------------------➕处理----------------------------------------------------------------

  // 1,图片
  // 2,相机
  // 3,电话
  // 4,音频
  // 5,视频
  // 6,文件
  Future<void> _pick(int val) async {
    if (val == 1) {
      _pickPicture(AppWebsocket.msgMediaImage, ImageSource.gallery);
    }
    if (val == 2) {
      _pickPicture(AppWebsocket.msgMediaImage, ImageSource.camera);
    }
    if (val == 3) {
      _invite();
    }
    if (val == 4) {
      _pickFile(AppWebsocket.msgMediaAudio);
    }
    if (val == 5) {
      _pickFile(AppWebsocket.msgMediaVideo);
    }
    if (val == 6) {
      _pickFile(AppWebsocket.msgMediaFile);
    }
  }

  Future<void> _pickPicture(int msgMedia, ImageSource imageSource) async {
    var isGrantedStorage = await PermissionUtil.requestStoragePermission();
    if (!isGrantedStorage) {
      TipHelper.instance.showToast("未允许存储读写权限");
      return;
    }
    ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      XFile compressedFile = await compressImage(pickedFile);
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

    FilePickerResult? filePickerResult;
    if (msgMedia == AppWebsocket.msgMediaAudio) {
      filePickerResult = await FilePicker.platform.pickFiles(type: FileType.audio);
    }
    if (msgMedia == AppWebsocket.msgMediaVideo) {
      filePickerResult = await FilePicker.platform.pickFiles(type: FileType.video);
    }
    if (msgMedia == AppWebsocket.msgMediaFile) {
      filePickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
    }

    if (filePickerResult != null) {
      PlatformFile pickedFile = filePickerResult.files.first;
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

  //----------------------------------------------------------------拨打电话处理----------------------------------------------------------------
  //邀请通话
  void _invite() async {
    signalingController.invite(talkCommonObj);
  }
}
