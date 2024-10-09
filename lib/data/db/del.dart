import 'package:qim/common/utils/db.dart';

Future<void> delDbChat(int objId, int type) async {
  await DBHelper.deleteData('chat', [
    ["objId", "=", objId],
    ["type", "=", type]
  ]);
}

Future<void> delDbApply(int type) async {
  await DBHelper.deleteData('apply', [
    ["type", "=", type]
  ]);
}

Future<void> delDbUser(int uid) async {
  await DBHelper.deleteData('user', [
    ["uid", "=", uid]
  ]);
}

Future<void> delDbFriendGroup(int friendGroupId) async {
  await DBHelper.deleteData('friend_group', [
    ['friendGroupId', '=', friendGroupId]
  ]);
}

Future<void> delDbContactFriend(int fromId, int toId) async {
  await DBHelper.deleteData('contact_friend', [
    ['fromId', '=', fromId],
    ['toId', '=', toId]
  ]);
}

Future<void> delDbGroup(int groupId) async {
  await DBHelper.deleteData('group', [
    ["groupId", "=", groupId]
  ]);
}

Future<void> delDbContactGroup(int fromId, int toId) async {
  await DBHelper.deleteData('contact_group', [
    ['fromId', '=', fromId],
    ['toId', '=', toId]
  ]);
}

Future<void> delDbContactGroupByGroupId(int toId) async {
  await DBHelper.deleteData('contact_group', [
    ['toId', '=', toId]
  ]);
}

Future<void> delDbMessageById(String id) async {
  await DBHelper.deleteData('message', [
    ['id', '=', id],
  ]);
}
