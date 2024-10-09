import 'package:get/get.dart';

class FriendGroupController extends GetxController {
  final RxList<Map> allFriendGroups = <Map>[].obs;

  void upsetFriendGroup(Map friendGroup) {
    final friendGroupId = friendGroup['friendGroupId'];

    // 查找是否已经存在相同的数据
    final existingFriendGroupIndex = allFriendGroups.indexWhere((c) => c['friendGroupId'] == friendGroupId);

    if (existingFriendGroupIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingFriendGroup = allFriendGroups[existingFriendGroupIndex];
      friendGroup.forEach((key, value) {
        if (existingFriendGroup.containsKey(key)) {
          existingFriendGroup[key] = value;
        }
      });
      allFriendGroups[existingFriendGroupIndex] = existingFriendGroup;
    } else {
      // 否则，将数据添加到列表中
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
    // 查找是否已经存在相同的数据
    final existingFriendGroupIndex = allFriendGroups.indexWhere((c) => c['friendGroupId'] == friendGroupId);
    if (existingFriendGroupIndex != -1) {
      return allFriendGroups[existingFriendGroupIndex];
    }
    return {};
  }

  //默认组
  Map getOneDefaultFriendGroup() {
    // 查找是否已经存在相同的数据
    final existingFriendGroupIndex = allFriendGroups.indexWhere((c) => c['isDefault'] == 1);
    if (existingFriendGroupIndex != -1) {
      return allFriendGroups[existingFriendGroupIndex];
    }
    return {};
  }
}
