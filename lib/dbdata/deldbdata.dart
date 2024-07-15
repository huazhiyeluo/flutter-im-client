import 'package:qim/utils/db.dart';

Future<void> delDbChat(int objId, int type) async {
  await DBHelper.deleteData('chats', [
    ["objId", "=", objId],
    ["type", "=", type]
  ]);
}
