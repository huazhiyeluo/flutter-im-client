import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/controller/message.dart';
import 'package:qim/controller/talkobj.dart';
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
      Map<String, dynamic>? objUser = await getDbOneUser(objId);
      if (objUser == null) {
        return;
      }
      chatData['name'] = objUser['username'];
      chatData['info'] = objUser['info'];
      chatData['remark'] = objUser['remark'];
      chatData['icon'] = objUser['avatar'];
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
    }
    chatData['weight'] = 0;
  } else {
    chatData['name'] = lastChat['name'];
    chatData['info'] = lastChat['info'];
    chatData['remark'] = lastChat['remark'];
    chatData['icon'] = lastChat['icon'];
    chatData['weight'] = lastChat['weight'];
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
    Map<String, dynamic>? objUser = await getDbOneUser(msg['fromId']);
    msg['avatar'] = objUser?['avatar'];
  }
  messageController.addMessage(msg);
  saveDbMessage(msg);
}

bool isImageFile(String path) {
  final mimeType = lookupMimeType(path);
  return mimeType != null && mimeType.startsWith('image/');
}
