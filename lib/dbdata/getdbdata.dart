//1、保存用户
import 'package:qim/utils/db.dart';

Future<Map<String, dynamic>?> getDbOneUser(int uid) async {
  Map<String, dynamic>? user = await DBHelper.getOne('users', [
    ['uid', '=', uid]
  ]);
  return user;
}

Future<Map<String, dynamic>?> getDbOneGroup(int groupId) async {
  Map<String, dynamic>? group = await DBHelper.getOne('groups', [
    ['groupId', '=', groupId]
  ]);
  return group;
}
