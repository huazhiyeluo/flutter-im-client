import 'package:get/get.dart';
import 'package:qim/data/api/getdata.dart';
import 'package:qim/data/db/get.dart';

class GroupController extends GetxController {
  final RxList<Map> allGroups = <Map>[].obs;

  //1、更新
  void upsetGroup(Map group) {
    final groupId = group['groupId'];

    // 查找是否已经存在相同的数据
    final existingIndex = allGroups.indexWhere((c) => c['groupId'] == groupId);

    if (existingIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingGroup = allGroups[existingIndex];
      group.forEach((key, value) {
        if (existingGroup.containsKey(key)) {
          existingGroup[key] = value;
        }
      });
      allGroups[existingIndex] = existingGroup;
    } else {
      // 否则，将数据添加到列表中
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
    // 查找是否已经存在相同的数据
    final existingIndex = allGroups.indexWhere((c) => c['groupId'] == groupId);
    if (existingIndex != -1) {
      return allGroups[existingIndex];
    }
    return groupObj;
  }
}
