import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:qim/controller/chat.dart';
import 'package:qim/utils/db.dart';
import 'package:qim/utils/savedata.dart';

String getKey({int msgType = 1, int fromId = 1, int toId = 1}) {
  String key = '';
  if (msgType == 1) {
    key = fromId > toId ? '${msgType}_${fromId}_$toId' : '${msgType}_${toId}_$fromId';
  } else if (msgType == 2) {
    key = '${msgType}_$toId';
  }
  return key;
}

String currentRouteName(BuildContext context) {
  // 通过 ModalRoute.of(context) 获取当前页面对应的路由对象
  ModalRoute<Object>? route = ModalRoute.of(context);
  // 如果路由对象不为空，则返回路由的名称，否则返回空字符串
  return route?.settings.name ?? '';
}

Future<void> processReceivedMessage(int uid, Map temp, ChatController chatController) async {
  if (![1, 2].contains(temp['msgType'])) {
    return;
  }
  bool isSelf = uid == temp['fromId'] ? true : false;

  Map chatData = {};
  if (temp['msgType'] == 1) {
    Map<String, dynamic> objUser = {};
    if (isSelf) {
      objUser = (await DBHelper.getOne('users', [
        ['uid', '=', temp['toId']]
      ]))!;
    } else {
      objUser = (await DBHelper.getOne('users', [
        ['uid', '=', temp['fromId']]
      ]))!;
    }

    chatData['objId'] = objUser['uid'];
    chatData['name'] = objUser['username'];
    chatData['info'] = objUser['info'];
    chatData['remark'] = objUser['remark'];
    chatData['icon'] = objUser['avatar'];
    chatData['weight'] = objUser['fromId'];
  }

  if (temp['msgType'] == 2) {
    Map<String, dynamic>? toGroup = await DBHelper.getOne('groups', [
      ['groupId', '=', temp['toId']]
    ]);

    chatData['objId'] = temp['toId'];
    chatData['name'] = toGroup?['name'];
    chatData['info'] = toGroup?['info'];
    chatData['remark'] = toGroup?['remark'];
    chatData['icon'] = toGroup?['icon'];
    chatData['weight'] = toGroup?['fromId'];
  }
  chatData['type'] = temp['msgType'];

  Map? lastChat = chatController.getOneChat(chatData['objId'], chatData['type']);

  if (!isSelf) {
    chatData['tips'] = lastChat?['tips'] ?? 0 + 1;
  } else {
    chatData['tips'] = lastChat?['tips'] ?? 0 + 1;
  }
  chatData['operateTime'] = temp['createTime'];
  chatData['msgMedia'] = temp['msgMedia'];
  chatData['content'] = temp['content'];

  chatController.upsetChat(chatData);
  saveChat(chatData);
}
