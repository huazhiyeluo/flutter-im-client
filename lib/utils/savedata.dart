import 'dart:convert';

import 'package:qim/utils/db.dart';

void saveUser(Map data) {
  Map<String, dynamic> user = {};

  // 需要保存的字段列表
  List<String> fields = [
    'uid',
    'username',
    'avatar',
    'info',
    'exp',
    'createTime',
    'level',
    'remark',
    'joinTime',
    'isOnline'
  ];

  // 遍历字段列表，检查是否存在于数据中，并将其添加到用户信息中
  for (var field in fields) {
    if (data[field] != null) {
      user[field] = data[field];
    }
  }

  DBHelper.upsertData('users', user, [
    ["uid", "=", user['uid']]
  ]);
}

void saveGroup(Map data) {
  Map<String, dynamic> group = {};

  // 需要保存的字段列表
  List<String> fields = [
    'groupId',
    'ownerUid',
    'name',
    'icon',
    'info',
    'num',
    'exp',
    'createTime',
    'level',
    'remark',
    'joinTime',
  ];

  // 遍历字段列表，检查是否存在于数据中，并将其添加到用户信息中
  for (var field in fields) {
    if (data[field] != null) {
      group[field] = data[field];
    }
  }

  DBHelper.upsertData('groups', group, [
    ["groupId", "=", group['groupId']]
  ]);
}

void saveChat(Map data) {
  Map<String, dynamic> chat = {};

  // 需要保存的字段列表
  List<String> fields = [
    'objId',
    'type',
    'name',
    'info',
    'remark',
    'icon',
    'weight',
    'tips',
    'operateTime',
    'msgMedia',
    'content',
  ];

  // 遍历字段列表，检查是否存在于数据中，并将其添加到用户信息中
  for (var field in fields) {
    if (data[field] != null) {
      if (field == 'content') {
        chat[field] = jsonEncode(data[field]);
      } else {
        chat[field] = data[field];
      }
    }
  }

  DBHelper.upsertData('chats', chat, [
    ["objId", "=", chat['objId']],
    ["type", "=", chat['type']]
  ]);
}

void saveMessage(Map data) {
  Map<String, dynamic> message = {};

  // 需要保存的字段列表
  List<String> fields = [
    'fromId',
    'toId',
    'avatar',
    'msgType',
    'msgMedia',
    'content',
    'createTime',
  ];

  // 遍历字段列表，检查是否存在于数据中，并将其添加到用户信息中
  for (var field in fields) {
    if (data[field] != null) {
      if (field == 'content') {
        message[field] = jsonEncode(data[field]);
      } else {
        message[field] = data[field];
      }
    }
  }
  DBHelper.insertData('message', message);
}
