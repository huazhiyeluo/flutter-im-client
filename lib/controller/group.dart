import 'package:get/get.dart';

class GroupController extends GetxController {
  final RxList<Map> allGroups = <Map>[].obs;

  void upsetGroup(Map group) {
    final groupId = group['groupId'];

    // 查找是否已经存在相同的数据
    final existingGroupIndex = allGroups.indexWhere((c) => c['groupId'] == groupId);

    if (existingGroupIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingGroup = allGroups[existingGroupIndex];
      group.forEach((key, value) {
        if (existingGroup.containsKey(key)) {
          existingGroup[key] = value;
        }
      });
      allGroups[existingGroupIndex] = existingGroup;
    } else {
      // 否则，将数据添加到列表中
      allGroups.add(group);
    }
    update();
  }

  Map? getOneGroup(int groupId) {
    // 查找是否已经存在相同的数据
    final existingGroupIndex = allGroups.indexWhere((c) => c['groupId'] == groupId);
    if (existingGroupIndex != -1) {
      return allGroups[existingGroupIndex];
    }
    return null;
  }
}
