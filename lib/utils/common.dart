import 'dart:convert';

import 'package:get/get.dart';
import 'package:qim/controller/apply.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/group.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
import 'package:qim/controller/friend.dart';
import 'package:qim/dbdata/deldbdata.dart';
import 'package:qim/dbdata/getdbdata.dart';
import 'package:qim/dbdata/savedbdata.dart';
import 'package:qim/utils/functions.dart';
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
  final ChatController chatController = Get.put(ChatController());
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
      Map<String, dynamic>? objUser = await getDbOneFriend(objId);
      if (objUser == null) {
        return;
      }
      chatData['name'] = objUser['username'];
      chatData['info'] = objUser['info'];
      chatData['remark'] = objUser['remark'];
      chatData['icon'] = objUser['avatar'];
      chatData['isTop'] = objUser['isTop'];
      chatData['isHidden'] = objUser['isHidden'];
      chatData['isQuiet'] = objUser['isQuiet'];
    }

    if (msg['msgType'] == 2) {
      Map<String, dynamic>? objGroup = await getDbOneGroup(msg['toId']);
      if (objGroup == null) {
        return;
      }
      chatData['name'] = objGroup['name'];
      chatData['info'] = objGroup['info'];
      chatData['remark'] = objGroup['remark'];
      chatData['icon'] = objGroup['icon'];
      chatData['isTop'] = objGroup['isTop'];
      chatData['isHidden'] = objGroup['isHidden'];
      chatData['isQuiet'] = objGroup['isQuiet'];
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
  final MessageController messageController = Get.put(MessageController());
  bool isSelf = uid == msg['fromId'] ? true : false;
  if (isSelf) {
    Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
    msg['avatar'] = userInfo?['avatar'];
  } else {
    Map<String, dynamic>? objUser = await getDbOneFriend(msg['fromId']);
    msg['avatar'] = objUser?['avatar'];
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
    final FriendController friendController = Get.find();
    Map? user = friendController.getOneFriend(talkObj['objId']);
    talkCommonObj['icon'] = user?['avatar'];
    talkCommonObj['name'] = user?['username'];
  } else if (talkObj['type'] == 2) {
    final GroupController groupController = Get.find();
    Map? group = groupController.getOneGroup(talkObj['objId']);
    talkCommonObj['icon'] = group?['icon'];
    talkCommonObj['name'] = group?['name'];
  }
  return talkCommonObj;
}

Future<void> loadFriendManage(int uid, Map msg) async {
  final FriendController friendController = Get.find();
  final ApplyController applyController = Get.find();
  final ChatController chatController = Get.find();
  Map data = json.decode(msg['content']['data']);
  if ([21, 22, 23].contains(msg['msgMedia'])) {
    applyController.upsetApply(data['apply']);
    saveDbApply(data['apply']);
  }
  //同意
  if ([22].contains(msg['msgMedia'])) {
    friendController.upsetFriend(data['user']);
    saveDbFriend(data['user']);
  }
  //删除
  if ([24].contains(msg['msgMedia'])) {
    friendController.delFriend(data['user']['uid']);
    delDbFriend(data['user']['uid']);

    chatController.delChat(data['user']['uid'], 1);
    delDbChat(data['user']['uid'], 1);
  }
}

Future<void> loadGroupManage(int uid, Map msg) async {
  if ([30].contains(msg['msgMedia'])) {}
  if ([31].contains(msg['msgMedia'])) {}
  if ([32].contains(msg['msgMedia'])) {}
  if ([33].contains(msg['msgMedia'])) {}
  if ([34].contains(msg['msgMedia'])) {}
  if ([35].contains(msg['msgMedia'])) {}
}
