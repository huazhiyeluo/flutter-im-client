import 'package:qim/utils/db.dart';

Future<void> delDbChat(int objId, int type) async {
  await DBHelper.deleteData('chats', [
    ["objId", "=", objId],
    ["type", "=", type]
  ]);
}

Future<void> delDbFriend(int uid) async {
  await DBHelper.deleteData('friends', [
    ["uid", "=", uid]
  ]);
}

Future<void> delDbApply(int type) async {
  await DBHelper.deleteData('apply', [
    ["type", "=", type]
  ]);
}
