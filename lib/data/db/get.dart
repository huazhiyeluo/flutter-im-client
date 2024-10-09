//1、保存用户
import 'package:qim/common/utils/db.dart';

Future<Map<String, dynamic>?> getDbOneUser(int uid) async {
  Map<String, dynamic>? user = await DBHelper.getOne('user', [
    ['uid', '=', uid]
  ]);
  return user;
}

Future<Map<String, dynamic>?> getDbOneGroup(int groupId) async {
  Map<String, dynamic>? group = await DBHelper.getOne('group', [
    ['groupId', '=', groupId]
  ]);
  return group;
}

Future<Map<String, dynamic>?> getDbOneContactFriend(int fromId, int toId) async {
  Map<String, dynamic>? contactFriend = await DBHelper.getOne('contact_friend', [
    ['fromId', '=', fromId],
    ['toId', '=', toId]
  ]);
  return contactFriend;
}

Future<Map<String, dynamic>?> getDbOneContactGroup(int fromId, int toId) async {
  Map<String, dynamic>? contactGroup = await DBHelper.getOne('contact_group', [
    ['fromId', '=', fromId],
    ['toId', '=', toId]
  ]);
  return contactGroup;
}
