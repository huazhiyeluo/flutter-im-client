import 'dart:convert';
import 'package:qim/utils/db.dart';

// 1-1、保存user
Future<void> saveDbUser(Map data) async {
  Map<String, dynamic> user = {};

  List<String> fields = [
    'uid',
    'nickname',
    'email',
    'phone',
    'avatar',
    'sex',
    'birthday',
    'info',
    'exp',
    'createTime',
  ];

  for (var field in fields) {
    if (data[field] != null) {
      user[field] = data[field];
    }
  }

  await DBHelper.upsertData('user', user, [
    ["uid", "=", user['uid']]
  ]);
}

// 1-2、保存用户组
Future<void> saveDbFriendGroup(Map data) async {
  Map<String, dynamic> friendGroup = {};

  List<String> fields = [
    'friendGroupId',
    'ownerUid',
    'name',
  ];

  for (var field in fields) {
    if (data[field] != null) {
      friendGroup[field] = data[field];
    }
  }

  await DBHelper.upsertData('friend_group', friendGroup, [
    ["friendGroupId", "=", friendGroup['friendGroupId']]
  ]);
}

// 1-3、保存联系人好友
Future<void> saveDbContactFriend(Map data) async {
  Map<String, dynamic> contactFriend = {};

  List<String> fields = [
    'fromId',
    'toId',
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

  for (var field in fields) {
    if (data[field] != null) {
      contactFriend[field] = data[field];
    }
  }

  await DBHelper.upsertData('contact_friend', contactFriend, [
    ["fromId", "=", contactFriend['fromId']],
    ["toId", "=", contactFriend['toId']]
  ]);
}

// 2-1、保存群组
Future<void> saveDbGroup(Map data) async {
  Map<String, dynamic> group = {};

  List<String> fields = [
    'groupId',
    'ownerUid',
    'name',
    'icon',
    'info',
    'num',
    'exp',
    'createTime',
  ];

  for (var field in fields) {
    if (data[field] != null) {
      group[field] = data[field];
    }
  }

  await DBHelper.upsertData('group', group, [
    ["groupId", "=", group['groupId']]
  ]);
}

// 2-2、保存联系群
Future<void> saveDbContactGroup(Map data) async {
  Map<String, dynamic> contactGroup = {};

  List<String> fields = [
    'fromId',
    'toId',
    'groupPower',
    'level',
    'remark',
    'nickname',
    'isTop',
    'isHidden',
    'isQuiet',
    'joinTime',
  ];

  for (var field in fields) {
    if (data[field] != null) {
      contactGroup[field] = data[field];
    }
  }

  await DBHelper.upsertData('contact_group', contactGroup, [
    ["fromId", "=", contactGroup['fromId']],
    ["toId", "=", contactGroup['toId']]
  ]);
}

// 3、保存chat
Future<void> saveDbChat(Map data) async {
  Map<String, dynamic> chat = {};

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

  for (var field in fields) {
    if (data[field] != null) {
      if (field == 'content') {
        chat[field] = jsonEncode(data[field]);
      } else {
        chat[field] = data[field];
      }
    }
  }

  await DBHelper.upsertData('chat', chat, [
    ["objId", "=", chat['objId']],
    ["type", "=", chat['type']]
  ]);
}

// 4、保存message
Future<void> saveDbMessage(Map data) async {
  Map<String, dynamic> message = {};

  List<String> fields = [
    'fromId',
    'toId',
    'nickname',
    'avatar',
    'msgType',
    'msgMedia',
    'content',
    'createTime',
  ];

  for (var field in fields) {
    if (data[field] != null) {
      if (field == 'content') {
        message[field] = jsonEncode(data[field]);
      } else {
        message[field] = data[field];
      }
    }
  }

  await DBHelper.insertData('message', message);
}

// 5、保存apply
Future<void> saveDbApply(Map data) async {
  Map<String, dynamic> apply = {};

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

  for (var field in fields) {
    if (data[field] != null) {
      apply[field] = data[field];
    }
  }

  await DBHelper.upsertData('apply', apply, [
    ["id", "=", apply['id']],
  ]);
}
