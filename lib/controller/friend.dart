import 'package:get/get.dart';

class FriendController extends GetxController {
  final RxList<Map> allFriends = <Map>[].obs;

  void upsetFriend(Map friend) {
    final uid = friend['uid'];

    // 查找是否已经存在相同的数据
    final existingFriendIndex = allFriends.indexWhere((c) => c['uid'] == uid);

    if (existingFriendIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingFriend = allFriends[existingFriendIndex];
      friend.forEach((key, value) {
        if (existingFriend.containsKey(key)) {
          existingFriend[key] = value;
        }
      });
      allFriends[existingFriendIndex] = existingFriend;
    } else {
      // 否则，将数据添加到列表中
      allFriends.add(friend);
    }
    update();
  }

  void delFriend(int uid) {
    final existingFriendIndex = allFriends.indexWhere((c) => c['uid'] == uid);
    if (existingFriendIndex != -1) {
      allFriends.removeAt(existingFriendIndex);
      update();
    }
  }

  Map? getOneFriend(int uid) {
    // 查找是否已经存在相同的数据
    final existingFriendIndex = allFriends.indexWhere((c) => c['uid'] == uid);
    if (existingFriendIndex != -1) {
      return allFriends[existingFriendIndex];
    }
    return null;
  }
}
