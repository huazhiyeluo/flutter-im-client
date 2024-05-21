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

class Talk extends StatefulWidget {
  const Talk({super.key});

  @override
  State<Talk> createState() => _TalkState();
}

class _TalkState extends State<Talk> {
  final TalkobjController talkobjController = Get.find();

  @override
  Widget build(BuildContext context) {
    Map? talkObj = talkobjController.talkObj;
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
  }

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    inputController.dispose();
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
    // 发送按钮的操作
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
    // 申请相机等权限
    var isGrantedCamera = await PermissionUtil.requestCameraPermission();
    if (!isGrantedCamera) {
      TipHelper.instance.showToast("未允许相机权限");
      return;
    }
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    // Handle the picked image file
    if (pickedFile != null) {
      // Use the picked file (e.g., display it in an Image widget)
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
    // Handle the picked image file
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
      // User canceled the image picking
      print('No image selected.');
    }
  }

  // ----------------------------------------------------------------语音通话 ----------------------------------------------------------------
  _goPhone() {
    _send({
      'content': {'data': ""},
      'fromId': uid,
      'toId': talkObj['objId'],
      'msgMedia': 0,
      'msgType': 4
    });
    Navigator.pushNamed(context, '/talk-phone', arguments: {
      "type": 1,
    });
  }
}
