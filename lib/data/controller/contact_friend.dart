import 'package:get/get.dart';

class ContactFriendController extends GetxController {
  final RxList<Map> allContactFriends = <Map>[].obs;

  //1、更新
  void upsetContactFriend(Map contactFriend) {
    final fromId = contactFriend['fromId'];
    final toId = contactFriend['toId'];

    final existingIndex = allContactFriends.indexWhere((c) => c['fromId'] == fromId && c['toId'] == toId);

    if (existingIndex != -1) {
      final existingContactFriend = Map<String, dynamic>.from(allContactFriends[existingIndex]);
      contactFriend.forEach((key, value) {
        if (existingContactFriend.containsKey(key)) {
          existingContactFriend[key] = value;
        }
      });
      allContactFriends[existingIndex] = existingContactFriend;
    } else {
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
    final existingIndex = allContactFriends.indexWhere((c) => c['fromId'] == fromId && c['toId'] == toId);
    if (existingIndex != -1) {
      return allContactFriends[existingIndex];
    }
    return {};
  }

  void upsetContactFriendByFriendGroupId(int friendGroupId, Map contactFriend) {
    final matchingIndexes = allContactFriends.where((c) => c['friendGroupId'] == friendGroupId).toList();
    if (matchingIndexes.isNotEmpty) {
      for (var existingContactFriend in matchingIndexes) {
        contactFriend.forEach((key, value) {
          if (existingContactFriend.containsKey(key)) {
            existingContactFriend[key] = value; // 直接更新现有的 map
          }
        });
      }
    }
    update();
  }
}
