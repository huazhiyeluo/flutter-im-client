import 'package:get/get.dart';

class ContactFriendController extends GetxController {
  final RxList<Map> allContactFriends = <Map>[].obs;

  //1、更新
  void upsetContactFriend(Map contactFriend) {
    final fromId = contactFriend['fromId'];
    final toId = contactFriend['toId'];

    // 查找是否已经存在相同的数据
    final existingIndex = allContactFriends.indexWhere((c) => c['fromId'] == fromId && c['toId'] == toId);

    if (existingIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingContactFriend = allContactFriends[existingIndex];
      contactFriend.forEach((key, value) {
        if (existingContactFriend.containsKey(key)) {
          existingContactFriend[key] = value;
        }
      });
      allContactFriends[existingIndex] = existingContactFriend;
    } else {
      // 否则，将数据添加到列表中
      allContactFriends.add(contactFriend);
    }
    update();
  }

  //2、删除
  void delContactFriend(int fromId, int toId) {
    final existingIndex = allContactFriends.indexWhere((c) => c['fromId'] == fromId && c['toId'] == toId);
    if (existingIndex != -1) {
      allContactFriends.removeAt(existingIndex);
      update();
    }
  }

  //3、获得单条记录
  Map getOneContactFriend(int fromId, int toId) {
    // 查找是否已经存在相同的数据
    final existingIndex = allContactFriends.indexWhere((c) => c['fromId'] == fromId && c['toId'] == toId);
    if (existingIndex != -1) {
      return allContactFriends[existingIndex];
    }
    return {};
  }

  void upsetContactFriendByFriendGroupId(int friendGroupId, Map contactFriend) {
    // 查找是否已经存在相同的数据
    final matchingIndexes = allContactFriends.asMap().entries.where((entry) => entry.value['friendGroupId'] == friendGroupId).map((entry) => entry.key).toList();

    if (matchingIndexes.isNotEmpty) {
      for (int index in matchingIndexes) {
        final existingContactFriend = allContactFriends[index];
        contactFriend.forEach((key, value) {
          if (existingContactFriend.containsKey(key)) {
            existingContactFriend[key] = value;
          }
        });
        allContactFriends[index] = existingContactFriend; // 更新列表中的 Map
      }
    } else {
      // 否则，将数据添加到列表中
      allContactFriends.add(contactFriend);
    }
    update();
  }
}
