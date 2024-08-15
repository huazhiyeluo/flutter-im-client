import 'dart:convert';

import 'package:get/get.dart';
import 'package:qim/controller/apply.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/contact_group.dart';
import 'package:qim/controller/friend_group.dart';
import 'package:qim/controller/group.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/contact_friend.dart';
import 'package:qim/controller/user.dart';
import 'package:qim/dbdata/deldbdata.dart';
import 'package:qim/dbdata/getdbdata.dart';
import 'package:qim/dbdata/savedbdata.dart';
import 'package:qim/utils/play.dart';
import 'package:qim/utils/cache.dart';
import 'package:mime/mime.dart';

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

  Map? lastChat = chatController.getOneChat(objId, msg['msgType']);
  if (lastChat == null) {
    if ([1].contains(msg['msgType'])) {
      Map userObj = userController.getOneUser(objId)!;
      Map contactFriendObj = contactFriendController.getOneContactFriend(uid, objId)!;

      chatData['name'] = userObj['username'];
      chatData['info'] = userObj['info'];
      chatData['icon'] = userObj['avatar'];
      chatData['remark'] = contactFriendObj['remark'];
      chatData['isTop'] = contactFriendObj['isTop'];
      chatData['isHidden'] = contactFriendObj['isHidden'];
      chatData['isQuiet'] = contactFriendObj['isQuiet'];
    }

    if (msg['msgType'] == 2) {
      Map? groupObj = groupController.getOneGroup(objId)!;
      Map contactGroupObj = contactGroupController.getOneContactGroup(uid, objId)!;
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
    chatData['tips'] = (lastChat?['tips'] ?? 0) + 1;
    await audioPlayerManager?.playSound("2.mp3");
  }

  chatController.upsetChat(chatData);
  saveDbChat(chatData);
}

Future<void> joinMessage(int uid, Map temp) async {
  Map msg = Map.from(temp);
  final MessageController messageController = Get.find();
  bool isSelf = uid == msg['fromId'] ? true : false;
  if (isSelf) {
    Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
    msg['avatar'] = userInfo?['avatar'];
  } else {
    final UserController userController = Get.find();
    Map userObj = userController.getOneUser(msg['fromId'])!;
    msg['avatar'] = userObj['avatar'];
  }
  messageController.addMessage(msg);
  saveDbMessage(msg);
}

bool isImageFile(String path) {
  final mimeType = lookupMimeType(path);
  return mimeType != null && mimeType.startsWith('image/');
}

Map getTalkCommonObj(Map talkObj) {
  Map talkCommonObj = {};
  if (talkObj['type'] == 1) {
    final UserController userController = Get.find();
    Map userObj = userController.getOneUser(talkObj['objId'])!;
    talkCommonObj['icon'] = userObj['avatar'];
    talkCommonObj['name'] = userObj['username'];
  } else if (talkObj['type'] == 2) {
    final GroupController groupController = Get.find();
    Map? groupObj = groupController.getOneGroup(talkObj['objId'])!;
    talkCommonObj['icon'] = groupObj['icon'];
    talkCommonObj['name'] = groupObj['name'];
  }
  return talkCommonObj;
}

Future<void> loadFriendManage(int uid, Map msg) async {
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
    userController.upsetUser(data['user']);
    saveDbUser(data['user']);
    contactFriendController.upsetContactFriend(data['contactFriend']);
    saveDbContactFriend(data['contactFriend']);
  }
  //删除
  if ([24].contains(msg['msgMedia'])) {
    contactFriendController.delContactFriend(data['contactFriend']['fromId'], data['contactFriend']['toId']);
    delDbContactFriend(data['contactFriend']['fromId'], data['contactFriend']['toId']);

    chatController.delChat(data['user']['uid'], 1);
    delDbChat(data['user']['uid'], 1);
  }
}

Future<void> loadGroupManage(int uid, Map msg) async {
  // final GroupController groupController = Get.find();
  // final ApplyController applyController = Get.find();
  // final ChatController chatController = Get.find();
  // Map data = json.decode(msg['content']['data']);
  // if ([31, 32, 33].contains(msg['msgMedia'])) {
  //   if (data['apply'] != null) {
  //     applyController.upsetApply(data['apply']);
  //     saveDbApply(data['apply']);
  //   }
  // }

  // //同意
  // if ([32].contains(msg['msgMedia'])) {
  //   groupController.upsetGroup(data['group']);
  //   saveDbFriend(data['group']);
  // }

  // //退出
  // if ([34].contains(msg['msgMedia'])) {
  //   groupController.upsetGroup(data['group']);
  //   saveDbGroup(data['group']);

  //   chatController.delChat(data['group']['groupId'], 2);
  //   delDbChat(data['group']['groupId'], 2);
  // }
}
