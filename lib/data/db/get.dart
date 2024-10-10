//1、保存用户
import 'package:qim/common/utils/db.dart';

Future<Map> getDbOneUser(int uid) async {
  Map user = await DBHelper.getOne('user', [
    ['uid', '=', uid]
  ]);
  return user;
}

Future<Map> getDbOneGroup(int groupId) async {
  Map group = await DBHelper.getOne('group', [
    ['groupId', '=', groupId]
  ]);
  return group;
}

Future<Map> getDbOneContactFriend(int fromId, int toId) async {
  Map contactFriend = await DBHelper.getOne('contact_friend', [
    ['fromId', '=', fromId],
    ['toId', '=', toId]
  ]);
  return contactFriend;
}

Future<Map> getDbOneContactGroup(int fromId, int toId) async {
  Map contactGroup = await DBHelper.getOne('contact_group', [
    ['fromId', '=', fromId],
    ['toId', '=', toId]
  ]);
  return contactGroup;
}
