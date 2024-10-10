import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/controller/apply.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/message.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/controller/websocket.dart';
import 'package:qim/data/db/del.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/date.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/common/utils/play.dart';
import 'package:mime/mime.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart' as imgcompress;

String getKey({int msgType = 1, int fromId = 1, int toId = 1}) {
  String key = '';
  if (msgType == 1) {
    key = fromId > toId ? '${msgType}_${fromId}_$toId' : '${msgType}_${toId}_$fromId';
  } else if (msgType == 2) {
    key = '${msgType}_$toId';
  }
  return key;
}

Future<void> joinData(int uid, Map msg, {AudioPlayerManager? audioPlayerManager}) async {
  if ([1, 2].contains(msg['msgType'])) {
    joinMessage(uid, msg);
  }
  joinChat(uid, msg, audioPlayerManager);
}

Future<void> joinChat(int uid, Map temp, AudioPlayerManager? audioPlayerManager) async {
  Map msg = Map.from(temp);
  final ChatController chatController = Get.find();
  final ContactFriendController contactFriendController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  final UserController userController = Get.find();
  final GroupController groupController = Get.find();

  int objId = 0;
  if ([1, 4].contains(msg['msgType'])) {
    objId = uid == msg['fromId'] ? msg['toId'] : msg['fromId'];
  } else if (msg['msgType'] == 2) {
    objId = msg['toId'];
  }

  if (msg['msgType'] == 4) {
    msg['msgType'] = 1;
  }
  Map chatData = {};
  chatData['objId'] = objId;
  chatData['type'] = msg['msgType'];
  chatData['msgMedia'] = msg['msgMedia'];
  chatData['operateTime'] = msg['createTime'];
  chatData['content'] = msg['content'];

  Map lastChat = chatController.getOneChat(objId, msg['msgType']);
  if (lastChat.isEmpty) {
    if ([1].contains(msg['msgType'])) {
      Map userObj = userController.getOneUser(objId) as Map;
      Map contactFriendObj = contactFriendController.getOneContactFriend(uid, objId);

      chatData['name'] = userObj['nickname'];
      chatData['info'] = userObj['info'];
      chatData['icon'] = userObj['avatar'];
      if (contactFriendObj.isNotEmpty) {
        chatData['remark'] = contactFriendObj['remark'];
        chatData['isTop'] = contactFriendObj['isTop'];
        chatData['isHidden'] = contactFriendObj['isHidden'];
        chatData['isQuiet'] = contactFriendObj['isQuiet'];
      } else {
        chatData['remark'] = "";
        chatData['isTop'] = 0;
        chatData['isHidden'] = 0;
        chatData['isQuiet'] = 0;
      }
    }
    if ([2].contains(msg['msgType'])) {
      Map groupObj = groupController.getOneGroup(objId);
      Map contactGroupObj = contactGroupController.getOneContactGroup(uid, objId);
      chatData['name'] = groupObj['name'];
      chatData['info'] = groupObj['info'];
      chatData['icon'] = groupObj['icon'];
      chatData['remark'] = contactGroupObj['remark'];
      chatData['isTop'] = contactGroupObj['isTop'];
      chatData['isHidden'] = contactGroupObj['isHidden'];
      chatData['isQuiet'] = contactGroupObj['isQuiet'];
    }
  } else {
    chatData['name'] = lastChat['name'];
    chatData['info'] = lastChat['info'];
    chatData['remark'] = lastChat['remark'];
    chatData['icon'] = lastChat['icon'];
    chatData['isTop'] = lastChat['isTop'];
    chatData['isHidden'] = lastChat['isHidden'];
    chatData['isQuiet'] = lastChat['isQuiet'];
  }

  final TalkobjController talkobjController = Get.put(TalkobjController());
  if (talkobjController.talkObj['objId'] == msg['fromId'] || talkobjController.talkObj['objId'] == msg['toId']) {
    chatData['tips'] = 0;
  } else {
    chatData['tips'] = (lastChat['tips'] ?? 0) + 1;

    audioPlayerManager ??= AudioPlayerManager();
    await audioPlayerManager.playSound("2.mp3");
  }

  chatController.upsetChat(chatData);
  saveDbChat(chatData);
}

Future<void> joinMessage(int uid, Map temp) async {
  Map msg = Map.from(temp);
  final MessageController messageController = Get.find();
  final GroupController groupController = Get.find();
  final ContactGroupController contactGroupController = Get.find();
  bool isSelf = uid == msg['fromId'] ? true : false;
  if (isSelf) {
    final UserInfoController userInfoController = Get.find();
    Map userInfo = userInfoController.userInfo;
    msg['avatar'] = userInfo['avatar'];
    msg['nickname'] = userInfo['nickname'];
  } else {
    if (msg['msgType'] == 1) {
      final ContactFriendController contactFriendController = Get.find();
      final UserController userController = Get.find();
      Map userObj = userController.getOneUser(msg['fromId']) as Map;
      Map contactFriendObj = contactFriendController.getOneContactFriend(uid, msg['fromId']);
      msg['avatar'] = userObj['avatar'];

      if (contactFriendObj.isNotEmpty) {
        msg['nickname'] = contactFriendObj['remark'] != "" ? contactFriendObj['remark'] : userObj['nickname'];
      } else {
        msg['nickname'] = userObj['nickname'];
      }
    }
    if (msg['msgType'] == 2) {
      final ContactGroupController contactGroupController = Get.find();
      final UserController userController = Get.find();
      Map userObj = userController.getOneUser(msg['fromId']) as Map;

      Map contactGroupObj = contactGroupController.getOneContactGroup(msg['fromId'], msg['toId']);
      msg['avatar'] = userObj['avatar'];
      msg['nickname'] = contactGroupObj.isNotEmpty && contactGroupObj['nickname'] != ""
          ? contactGroupObj['nickname']
          : userObj['nickname'];
    }
  }
  messageController.addMessage(msg);
  saveDbMessage(msg);
}

Future<void> getGroupInfo(int groupId) async {
  logPrint("_____$groupId");
  final UserController userController = Get.find();
  final ContactGroupController contactGroupController = Get.find();

  final Completer<void> completer = Completer<void>();
  var params = {
    'groupId': groupId,
  };
  ContactGroupApi.getContactGroupUser(params, onSuccess: (res) async {
    List usersArr = [];
    if (res['data']['users'] != null) {
      usersArr = res['data']['users'];
    }
    for (var item in usersArr) {
      userController.upsetUser(item);
      await saveDbUser(item);
    }

    List contactGroupsArr = [];
    if (res['data']['contactGroups'] != null) {
      contactGroupsArr = res['data']['contactGroups'];
    }
    for (var item in contactGroupsArr) {
      contactGroupController.upsetContactGroup(item);
      await saveDbContactGroup(item);
    }
    // 完成异步任务
    completer.complete();
  }, onError: (res) {
    TipHelper.instance.showToast(res['msg']);
    completer.complete();
  });
  return completer.future;
}

bool isImageFile(String path) {
  final mimeType = lookupMimeType(path);
  return mimeType != null && mimeType.startsWith('image/');
}

Map getTalkCommonObj(Map talkObj) {
  Map talkCommonObj = {};
  talkCommonObj['objId'] = talkObj['objId'];
  if (talkObj['type'] == 1) {
    final UserController userController = Get.find();
    Map userObj = userController.getOneUser(talkObj['objId']);
    talkCommonObj['icon'] = userObj['avatar'];
    talkCommonObj['name'] = userObj['nickname'];
    talkCommonObj['num'] = 1;
  } else if (talkObj['type'] == 2) {
    final GroupController groupController = Get.find();
    Map groupObj = groupController.getOneGroup(talkObj['objId']);
    talkCommonObj['icon'] = groupObj['icon'];
    talkCommonObj['name'] = groupObj['name'];
    talkCommonObj['num'] = groupObj['num'];
  }
  return talkCommonObj;
}

Future<void> loadFriendManage(int uid, Map msg) async {
  final WebSocketController webSocketController = Get.find();
  final UserController userController = Get.find();
  final ContactFriendController contactFriendController = Get.find();

  final ApplyController applyController = Get.find();
  final ChatController chatController = Get.find();
  Map data = json.decode(msg['content']['data']);
  if ([21, 22, 23].contains(msg['msgMedia'])) {
    applyController.upsetApply(data['apply']);
    saveDbApply(data['apply']);
  }
  //同意
  if ([22].contains(msg['msgMedia'])) {
    if (data['user'] != null) {
      userController.upsetUser(data['user']);
      saveDbUser(data['user']);
    }
    if (data['contactFriend'] != null) {
      contactFriendController.upsetContactFriend(data['contactFriend']);
      saveDbContactFriend(data['contactFriend']);
    }

    if (data['apply'] != null) {
      if (uid == data['apply']['fromId']) {
        Map msg = {
          'fromId': uid,
          'toId': data['apply']['toId'],
          'content': {"data": data['apply']['reason']},
          'msgMedia': 1,
          'msgType': 1
        };
        webSocketController.sendMessage(msg);
        msg['createTime'] = getTime();
        joinData(uid, msg);
      }
    }
  }
  //删除
  if ([24].contains(msg['msgMedia'])) {
    contactFriendController.delContactFriend(data['contactFriend']['fromId'], data['contactFriend']['toId']);
    delDbContactFriend(data['contactFriend']['fromId'], data['contactFriend']['toId']);

    chatController.delChat(data['user']['uid'], 1);
    delDbChat(data['user']['uid'], 1);

    final TalkobjController talkobjController = Get.put(TalkobjController());
    if (talkobjController.talkObj['objId'] == data['user']['uid']) {
      talkobjController.setTalkObj({});
      Get.until((route) => route.settings.name == '/');
      Get.toNamed('/');
    }
  }
}

Future<void> loadGroupManage(int uid, Map msg) async {
  final WebSocketController webSocketController = Get.find();
  final UserController userController = Get.find();
  final GroupController groupController = Get.find();
  final ContactGroupController contactGroupController = Get.find();

  final ApplyController applyController = Get.find();
  final ChatController chatController = Get.find();
  Map data = json.decode(msg['content']['data']);
  if ([31, 32, 33].contains(msg['msgMedia'])) {
    if (data['apply'] != null) {
      applyController.upsetApply(data['apply']);
      saveDbApply(data['apply']);
    }
  }

  //创建
  if ([30].contains(msg['msgMedia'])) {
    if (data['group'] != null) {
      groupController.upsetGroup(data['group']);
      saveDbGroup(data['group']);
    }
    if (data['contactGroup'] != null) {
      contactGroupController.upsetContactGroup(data['contactGroup']);
      saveDbContactGroup(data['contactGroup']);
    }
    if (data['user'] != null) {
      userController.upsetUser(data['user']);
      saveDbUser(data['user']);
    }
  }

  //同意
  if ([32].contains(msg['msgMedia'])) {
    if (data['group'] != null) {
      groupController.upsetGroup(data['group']);
      saveDbGroup(data['group']);
    }
    if (data['contactGroup'] != null) {
      contactGroupController.upsetContactGroup(data['contactGroup']);
      saveDbContactGroup(data['contactGroup']);
    }
    if (data['user'] != null) {
      userController.upsetUser(data['user']);
      saveDbUser(data['user']);
    }
    if (data['apply'] != null) {
      if (uid == data['apply']['fromId']) {
        Map msg = {
          'fromId': uid,
          'toId': data['apply']['toId'],
          'content': {"data": data['apply']['info']},
          'msgMedia': 1,
          'msgType': 2
        };
        webSocketController.sendMessage(msg);
        msg['createTime'] = getTime();
        joinData(uid, msg);
      }
    }
  }

  //退出
  if ([34].contains(msg['msgMedia'])) {
    if (uid == data['user']['uid']) {
      groupController.delGroup(data['group']['groupId']);
      delDbGroup(data['group']['groupId']);

      chatController.delChat(data['group']['groupId'], 2);
      delDbChat(data['group']['groupId'], 2);

      contactGroupController.delContactGroupByGroupId(data['group']['groupId']);
      delDbContactGroupByGroupId(data['group']['groupId']);
    } else {
      groupController.upsetGroup(data['group']);
      saveDbGroup(data['group']);
      contactGroupController.delContactGroup(data['user']['uid'], data['group']['groupId']);
      delDbContactGroup(data['user']['uid'], data['group']['groupId']);
    }
  }

  //解散
  if ([35].contains(msg['msgMedia'])) {
    groupController.delGroup(data['group']['groupId']);
    delDbGroup(data['group']['groupId']);

    chatController.delChat(data['group']['groupId'], 2);
    delDbChat(data['group']['groupId'], 2);

    contactGroupController.delContactGroupByGroupId(data['group']['groupId']);
    delDbContactGroupByGroupId(data['group']['groupId']);
  }
}

Future<XFile> compressImage(XFile pickedFile) async {
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

String getContent(int msgMedia, Map content) {
  if ([1, 10, 11, 13].contains(msgMedia)) {
    return content['data'];
  }

  if (msgMedia == 2) {
    return "[图片]";
  }

  if (msgMedia == 3) {
    return "[音频]";
  }

  if (msgMedia == 4) {
    return "[视频]";
  }

  if (msgMedia == 5) {
    return "[文件]";
  }

  if (msgMedia == 6) {
    return "[表情]";
  }

  if (msgMedia == 12) {
    return "通话时长: ${formatSecondsToHMS(int.parse(content['data']))}";
  }
  if (msgMedia == 21) {
    return "邀请你加入群聊";
  }
  if (msgMedia == 22) {
    return "个人名片";
  }

  return "";
}
