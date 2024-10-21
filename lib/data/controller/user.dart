import 'package:get/get.dart';

class UserController extends GetxController {
  final RxList<Map> allUsers = <Map>[].obs;

  //1、更新
  void upsetUser(Map user) {
    final uid = user['uid'];

    final existingIndex = allUsers.indexWhere((c) => c['uid'] == uid);

    if (existingIndex != -1) {
      final existingUser = Map<String, dynamic>.from(allUsers[existingIndex]);
      user.forEach((key, value) {
        if (existingUser.containsKey(key)) {
          existingUser[key] = value;
        }
      });
      allUsers[existingIndex] = existingUser;
    } else {
      allUsers.add(user);
    }
    update();
  }

  //2、删除
  void delUser(int uid) {
    final existingIndex = allUsers.indexWhere((c) => c['uid'] == uid);
    if (existingIndex != -1) {
      allUsers.removeAt(existingIndex);
      update();
    }
  }

  //3、获得单条记录

  Map getOneUser(int uid) {
    Map userObj = {};

    final existingUserIndex = allUsers.indexWhere((c) => c['uid'] == uid);
    if (existingUserIndex != -1) {
      return allUsers[existingUserIndex];
    }
    return userObj;
  }
}
