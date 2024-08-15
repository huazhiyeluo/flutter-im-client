import 'package:get/get.dart';

class ContactGroupController extends GetxController {
  final RxList<Map> allContactGroups = <Map>[].obs;

  //1、更新
  void upsetContactGroup(Map contactGroup) {
    final fromId = contactGroup['fromId'];
    final toId = contactGroup['toId'];

    // 查找是否已经存在相同的数据
    final existingIndex = allContactGroups.indexWhere((c) => c['fromId'] == fromId && c['toId'] == toId);

    if (existingIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingContactGroup = allContactGroups[existingIndex];
      contactGroup.forEach((key, value) {
        if (existingContactGroup.containsKey(key)) {
          existingContactGroup[key] = value;
        }
      });
      allContactGroups[existingIndex] = existingContactGroup;
    } else {
      // 否则，将数据添加到列表中
      allContactGroups.add(contactGroup);
    }
    update();
  }

  //2、删除
  void delContactGroup(int fromId, int toId) {
    final existingIndex = allContactGroups.indexWhere((c) => c['fromId'] == fromId && c['toId'] == toId);
    if (existingIndex != -1) {
      allContactGroups.removeAt(existingIndex);
      update();
    }
  }

  //3、获得单条记录
  Map? getOneContactGroup(int fromId, int toId) {
    // 查找是否已经存在相同的数据
    final existingIndex = allContactGroups.indexWhere((c) => c['fromId'] == fromId && c['toId'] == toId);
    if (existingIndex != -1) {
      return allContactGroups[existingIndex];
    }
    return null;
  }
}
