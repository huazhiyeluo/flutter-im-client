//1、保存用户
import 'package:qim/utils/db.dart';

Future<Map<String, dynamic>?> getDbOneFriend(int uid) async {
  Map<String, dynamic>? friend = await DBHelper.getOne('friends', [
    ['uid', '=', uid]
  ]);
  return friend;
}

Future<Map<String, dynamic>?> getDbOneGroup(int groupId) async {
  Map<String, dynamic>? group = await DBHelper.getOne('groups', [
    ['groupId', '=', groupId]
  ]);
  return group;
}
