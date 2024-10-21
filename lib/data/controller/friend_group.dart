import 'package:get/get.dart';

class FriendGroupController extends GetxController {
  final RxList<Map> allFriendGroups = <Map>[].obs;

  void upsetFriendGroup(Map friendGroup) {
    final friendGroupId = friendGroup['friendGroupId'];

    final existingFriendGroupIndex = allFriendGroups.indexWhere((c) => c['friendGroupId'] == friendGroupId);

    if (existingFriendGroupIndex != -1) {
      final existingFriendGroup = Map<String, dynamic>.from(allFriendGroups[existingFriendGroupIndex]);
      friendGroup.forEach((key, value) {
        if (existingFriendGroup.containsKey(key)) {
          existingFriendGroup[key] = value;
        }
      });
      allFriendGroups[existingFriendGroupIndex] = existingFriendGroup;
    } else {
      allFriendGroups.add(friendGroup);
    }
    update();
  }

  //2、删除
  void delFriendGroup(int friendGroupId) {
    final existingIndex = allFriendGroups.indexWhere((c) => c['friendGroupId'] == friendGroupId);
    if (existingIndex != -1) {
      allFriendGroups.removeAt(existingIndex);
      update();
    }
  }

  Map getOneFriendGroup(int friendGroupId) {
    final existingFriendGroupIndex = allFriendGroups.indexWhere((c) => c['friendGroupId'] == friendGroupId);
    if (existingFriendGroupIndex != -1) {
      return allFriendGroups[existingFriendGroupIndex];
    }
    return {};
  }

  //默认组
  Map getOneDefaultFriendGroup() {
    final existingFriendGroupIndex = allFriendGroups.indexWhere((c) => c['isDefault'] == 1);
    if (existingFriendGroupIndex != -1) {
      return allFriendGroups[existingFriendGroupIndex];
    }
    return {};
  }
}
