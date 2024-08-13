import 'dart:convert';

import 'package:qim/utils/db.dart';
import 'package:qim/utils/functions.dart';

//0、保存用户组
void saveDbFriendGroup(Map data) {
  Map<String, dynamic> friendGroup = {};

  // 需要保存的字段列表
  List<String> fields = [
    'friendGroupId',
    'ownerUid',
    'name',
  ];
  // 遍历字段列表，检查是否存在于数据中，并将其添加到用户信息中
  for (var field in fields) {
    if (data[field] != null) {
      friendGroup[field] = data[field];
    }
  }
  DBHelper.upsertData('friend_group', friendGroup, [
    ["friendGroupId", "=", friendGroup['friendGroupId']]
  ]);
}

//1、保存用户
void saveDbFriend(Map data) {
  Map<String, dynamic> friend = {};

  // 需要保存的字段列表
  List<String> fields = [
    'uid',
    'username',
    'email',
    'phone',
    'avatar',
    'sex',
    'birthday',
    'info',
    'exp',
    'createTime',
    'friendGroupId',
    'level',
    'remark',
    'desc',
    'isTop',
    'isHidden',
    'isQuiet',
    'joinTime',
    'isOnline'
  ];
  // 遍历字段列表，检查是否存在于数据中，并将其添加到用户信息中
  for (var field in fields) {
    if (data[field] != null) {
      friend[field] = data[field];
    }
  }
  DBHelper.upsertData('friends', friend, [
    ["uid", "=", friend['uid']]
  ]);
}

//2、保存群组
void saveDbGroup(Map data) {
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
    'groupPower',
    'level',
    'remark',
    'nickname',
    'isTop',
    'isHidden',
    'isQuiet',
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

//3、保存chat
void saveDbChat(Map data) {
  Map<String, dynamic> chat = {};

  // 需要保存的字段列表
  List<String> fields = [
    'objId',
    'type',
    'name',
    'info',
    'remark',
    'icon',
    'isTop',
    'isHidden',
    'isQuiet',
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

  logPrint(chat);

  DBHelper.upsertData('chats', chat, [
    ["objId", "=", chat['objId']],
    ["type", "=", chat['type']]
  ]);
}

//4、保存message
void saveDbMessage(Map data) {
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

//5、保存apply
void saveDbApply(Map data) {
  Map<String, dynamic> apply = {};

  // 需要保存的字段列表
  List<String> fields = [
    'id',
    'fromId',
    'fromName',
    'fromIcon',
    'toId',
    'toName',
    'toIcon',
    'type',
    'status',
    'reason',
    'operateTime',
  ];

  // 遍历字段列表，检查是否存在于数据中，并将其添加到用户信息中
  for (var field in fields) {
    if (data[field] != null) {
      apply[field] = data[field];
    }
  }
  DBHelper.insertData('apply', apply);
}
