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

  Map getOneFriendGroup(int friendGroupId) {
    // 查找是否已经存在相同的数据
    final existingFriendGroupIndex = allFriendGroups.indexWhere((c) => c['friendGroupId'] == friendGroupId);
    if (existingFriendGroupIndex != -1) {
      return allFriendGroups[existingFriendGroupIndex];
    }
    return {};
  }
}
