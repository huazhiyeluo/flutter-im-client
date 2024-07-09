import 'package:get/get.dart';

class ContactGroupController extends GetxController {
  final RxList<Map> allContactGroups = <Map>[].obs;

  void upsetContactGroup(Map contactGroup) {
    final friendGroupId = contactGroup['friendGroupId'];

    // 查找是否已经存在相同的数据
    final existingContactGroupIndex = allContactGroups.indexWhere((c) => c['friendGroupId'] == friendGroupId);

    if (existingContactGroupIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingContactGroup = allContactGroups[existingContactGroupIndex];
      contactGroup.forEach((key, value) {
        if (existingContactGroup.containsKey(key)) {
          existingContactGroup[key] = value;
        }
      });
      allContactGroups[existingContactGroupIndex] = existingContactGroup;
    } else {
      // 否则，将数据添加到列表中
      allContactGroups.add(contactGroup);
    }
    update();
  }

  Map? getOneContactGroup(int friendGroupId) {
    // 查找是否已经存在相同的数据
    final existingContactGroupIndex = allContactGroups.indexWhere((c) => c['friendGroupId'] == friendGroupId);
    if (existingContactGroupIndex != -1) {
      return allContactGroups[existingContactGroupIndex];
    }
    return null;
  }
}
