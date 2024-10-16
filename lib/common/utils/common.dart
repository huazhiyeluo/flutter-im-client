import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/controller/apply.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/talk.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/websocket.dart';
import 'package:qim/data/db/del.dart';
import 'package:qim/data/db/save.dart';
import 'package:qim/common/utils/date.dart';
import 'package:mime/mime.dart';
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

bool isImageFile(String path) {
  final mimeType = lookupMimeType(path);
  return mimeType != null && mimeType.startsWith('image/');
}

Map getTalkCommonObj(Map talkObj) {
  Map talkCommonObj = {};
  talkCommonObj['objId'] = talkObj['objId'];
  if (talkObj['type'] == ObjectTypes.user) {
    final UserController userController = Get.find();
    Map userObj = userController.getOneUser(talkObj['objId']);
    talkCommonObj['icon'] = userObj['avatar'];
    talkCommonObj['name'] = userObj['nickname'];
    talkCommonObj['num'] = 1;
  } else if (talkObj['type'] == ObjectTypes.group) {
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
  if ([
    AppWebsocket.msgMediaFriendAdd,
    AppWebsocket.msgMediaFriendAgree,
    AppWebsocket.msgMediaFriendRefuse,
  ].contains(msg['msgMedia'])) {
    applyController.upsetApply(data['apply']);
    saveDbApply(data['apply']);
  }
  //同意
  if ([AppWebsocket.msgMediaFriendAgree].contains(msg['msgMedia'])) {
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
          'id': genGUID(),
          'fromId': uid,
          'toId': data['apply']['toId'],
          'content': {"data": data['apply']['reason']},
          'msgMedia': AppWebsocket.msgMediaText,
          'msgType': AppWebsocket.msgTypeSingle,
          'createTime': getTime()
        };
        webSocketController.sendMessage(msg);
        msg['createTime'] = getTime();
        joinData(uid, msg);
      }
    }
  }
  //删除
  if ([AppWebsocket.msgMediaFriendDelete].contains(msg['msgMedia'])) {
    contactFriendController.delContactFriend(data['contactFriend']['fromId'], data['contactFriend']['toId']);
    delDbContactFriend(data['contactFriend']['fromId'], data['contactFriend']['toId']);

    chatController.delChat(data['user']['uid'], ObjectTypes.user);
    delDbChat(data['user']['uid'], ObjectTypes.user);

    final TalkController talkController = Get.put(TalkController());
    if (talkController.talkObj['objId'] == data['user']['uid']) {
      talkController.setTalk({});
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
  if ([AppWebsocket.msgMediaGroupJoin, AppWebsocket.msgMediaGroupAgree, AppWebsocket.msgMediaGroupRefuse].contains(msg['msgMedia'])) {
    if (data['apply'] != null) {
      applyController.upsetApply(data['apply']);
      saveDbApply(data['apply']);
    }
  }

  //创建
  if ([AppWebsocket.msgMediaGroupCreate].contains(msg['msgMedia'])) {
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
  if ([AppWebsocket.msgMediaGroupAgree].contains(msg['msgMedia'])) {
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
          'id': genGUID(),
          'fromId': uid,
          'toId': data['apply']['toId'],
          'content': {"data": data['apply']['info']},
          'msgMedia': AppWebsocket.msgMediaText,
          'msgType': AppWebsocket.msgTypeRoom,
          'createTime': getTime()
        };
        webSocketController.sendMessage(msg);
        joinData(uid, msg);
      }
    }
  }

  //退出
  if ([AppWebsocket.msgMediaGroupDelete].contains(msg['msgMedia'])) {
    if (uid == data['user']['uid']) {
      groupController.delGroup(data['group']['groupId']);
      delDbGroup(data['group']['groupId']);

      chatController.delChat(data['group']['groupId'], ObjectTypes.group);
      delDbChat(data['group']['groupId'], ObjectTypes.group);

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
  if ([AppWebsocket.msgMediaGroupDisband].contains(msg['msgMedia'])) {
    groupController.delGroup(data['group']['groupId']);
    delDbGroup(data['group']['groupId']);

    chatController.delChat(data['group']['groupId'], ObjectTypes.group);
    delDbChat(data['group']['groupId'], ObjectTypes.group);

    contactGroupController.delContactGroupByGroupId(data['group']['groupId']);
    delDbContactGroupByGroupId(data['group']['groupId']);
  }

  //群联系人更新
  if ([AppWebsocket.msgMediaContactGroupUpdate].contains(msg['msgMedia'])) {
    contactGroupController.upsetContactGroup(data['contactGroup']);
    saveDbContactGroup(data['contactGroup']);
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
  if ([
    AppWebsocket.msgMediaText,
    AppWebsocket.msgMediaNotOnline,
    AppWebsocket.msgMediaNoConnect,
    AppWebsocket.msgMediaOff,
  ].contains(msgMedia)) {
    return content['data'];
  }

  if (msgMedia == AppWebsocket.msgMediaImage) {
    return "[图片]";
  }

  if (msgMedia == AppWebsocket.msgMediaAudio) {
    return "[音频]";
  }

  if (msgMedia == AppWebsocket.msgMediaVideo) {
    return "[视频]";
  }

  if (msgMedia == AppWebsocket.msgMediaFile) {
    return "[文件]";
  }

  if (msgMedia == AppWebsocket.msgMediaEmoji) {
    return "[表情]";
  }

  if (msgMedia == AppWebsocket.msgMediaTimes) {
    return "通话时长: ${formatSecondsToHMS(int.parse(content['data']))}";
  }
  if (msgMedia == AppWebsocket.msgMediaInvite) {
    return "邀请你加入群聊";
  }
  if (msgMedia == AppWebsocket.msgMediaUser) {
    return "[个人名片]";
  }
  if (msgMedia == AppWebsocket.msgMediaGroup) {
    return "[群聊名片]";
  }

  return "";
}
