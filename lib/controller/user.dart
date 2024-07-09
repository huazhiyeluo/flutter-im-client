import 'package:get/get.dart';

class UserController extends GetxController {
  final RxList<Map> allUsers = <Map>[].obs;

  void upsetUser(Map user) {
    final uid = user['uid'];

    // 查找是否已经存在相同的数据
    final existingUserIndex = allUsers.indexWhere((c) => c['uid'] == uid);

    if (existingUserIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingUser = allUsers[existingUserIndex];
      user.forEach((key, value) {
        if (existingUser.containsKey(key)) {
          existingUser[key] = value;
        }
      });
      allUsers[existingUserIndex] = existingUser;
    } else {
      // 否则，将数据添加到列表中
      allUsers.add(user);
    }
    update();
  }

  Map? getOneUser(int uid) {
    // 查找是否已经存在相同的数据
    final existingUserIndex = allUsers.indexWhere((c) => c['uid'] == uid);
    if (existingUserIndex != -1) {
      return allUsers[existingUserIndex];
    }
    return null;
  }
}
