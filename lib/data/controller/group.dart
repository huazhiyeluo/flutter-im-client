import 'package:get/get.dart';

class GroupController extends GetxController {
  final RxList<Map> allGroups = <Map>[].obs;

  //1、更新
  void upsetGroup(Map group) {
    final groupId = group['groupId'];

    final existingIndex = allGroups.indexWhere((c) => c['groupId'] == groupId);

    if (existingIndex != -1) {
      final existingGroup = Map<String, dynamic>.from(allGroups[existingIndex]);
      group.forEach((key, value) {
        if (existingGroup.containsKey(key)) {
          existingGroup[key] = value;
        }
      });
      allGroups[existingIndex] = existingGroup;
    } else {
      allGroups.add(group);
    }
    update();
  }

  //2、删除
  void delGroup(int groupId) {
    final existingIndex = allGroups.indexWhere((c) => c['groupId'] == groupId);
    if (existingIndex != -1) {
      allGroups.removeAt(existingIndex);
      update();
    }
  }

  //3、获得单条记录
  Map getOneGroup(int groupId) {
    Map groupObj = {};

    final existingIndex = allGroups.indexWhere((c) => c['groupId'] == groupId);
    if (existingIndex != -1) {
      return allGroups[existingIndex];
    }
    return groupObj;
  }
}
