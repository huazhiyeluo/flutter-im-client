import 'dart:async';

import 'package:get/get.dart';
import 'package:qim/common/utils/play.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/data/api/contact_group.dart';
import 'package:qim/data/api/getdata.dart';
import 'package:qim/data/controller/chat.dart';
import 'package:qim/data/controller/contact_friend.dart';
import 'package:qim/data/controller/contact_group.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/message.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/data/db/get.dart';
import 'package:qim/data/db/save.dart';

Future<void> joinData(int uid, Map msg, {AudioPlayerManager? audioPlayerManager}) async {
  if ([1, 2].contains(msg['msgType'])) {
    joinMessage(uid, msg);
  }
  joinChat(uid, msg, audioPlayerManager);
}

Future<void> joinChat(int uid, Map temp, AudioPlayerManager? audioPlayerManager) async {
  Map msg = Map.from(temp);

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

  final ChatController chatController = Get.find();
  Map lastChat = chatController.getOneChat(objId, msg['msgType']);
  if (lastChat.isEmpty) {
    if ([1].contains(msg['msgType'])) {
      final UserController userController = Get.find();
      final ContactFriendController contactFriendController = Get.find();

      initOneUser(objId);
      Map userObj = userController.getOneUser(objId);
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
      final GroupController groupController = Get.find();
      final ContactGroupController contactGroupController = Get.find();

      initOneGroup(objId);
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

      initOneUser(msg['fromId']);
      Map userObj = userController.getOneUser(msg['fromId']);
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

      initOneUser(msg['fromId']);
      Map userObj = userController.getOneUser(msg['fromId']);
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

Future<void> initOneUser(int uid) async {
  final UserController userController = Get.find();
  Map userObj = {};
  userObj = userController.getOneUser(uid);
  if (userObj.isEmpty) {
    userObj = await getDbOneUser(uid);
    if (userObj.isEmpty) {
      userObj = await getApiOneUser(uid);
    }
    userController.upsetUser(userObj);
  }
}

Future<void> initOneGroup(int uid) async {
  final GroupController groupController = Get.find();
  Map groupObj = {};
  groupObj = groupController.getOneGroup(uid);
  if (groupObj.isEmpty) {
    groupObj = await getDbOneUser(uid);
    if (groupObj.isEmpty) {
      groupObj = await getApiOneGroup(uid);
    }
    groupController.upsetGroup(groupObj);
  }
}
