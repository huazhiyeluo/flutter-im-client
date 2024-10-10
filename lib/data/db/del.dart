import 'package:qim/common/utils/db.dart';

// 删除 chat 数据
Future<void> delDbChat(int objId, int type) async {
  await DBHelper.deleteData('chat', [
    ["objId", "=", objId],
    ["type", "=", type]
  ]);
}

// 删除 apply 数据
Future<void> delDbApply(int type) async {
  await DBHelper.deleteData('apply', [
    ["type", "=", type]
  ]);
}

// 删除 user 数据
Future<void> delDbUser(int uid) async {
  await DBHelper.deleteData('user', [
    ["uid", "=", uid]
  ]);
}

// 删除 friend_group 数据
Future<void> delDbFriendGroup(int friendGroupId) async {
  await DBHelper.deleteData('friend_group', [
    ['friendGroupId', '=', friendGroupId]
  ]);
}

// 删除 contact_friend 数据
Future<void> delDbContactFriend(int fromId, int toId) async {
  await DBHelper.deleteData('contact_friend', [
    ['fromId', '=', fromId],
    ['toId', '=', toId]
  ]);
}

// 删除 group 数据
Future<void> delDbGroup(int groupId) async {
  await DBHelper.deleteData('group', [
    ["groupId", "=", groupId]
  ]);
}

// 删除 contact_group 数据
Future<void> delDbContactGroup(int fromId, int toId) async {
  await DBHelper.deleteData('contact_group', [
    ['fromId', '=', fromId],
    ['toId', '=', toId]
  ]);
}

// 删除 contact_group 数据
Future<void> delDbContactGroupByGroupId(int toId) async {
  await DBHelper.deleteData('contact_group', [
    ['toId', '=', toId]
  ]);
}

// 删除 message 数据
Future<void> delDbMessageById(String id) async {
  await DBHelper.deleteData('message', [
    ['id', '=', id],
  ]);
}
