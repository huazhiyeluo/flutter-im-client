import 'package:get/get.dart';

class ContactGroupController extends GetxController {
  final RxMap<int, RxList<Map>> allContactGroups = <int, RxList<Map>>{}.obs;

  //1、更新
  void upsetContactGroup(Map contactGroup) {
    final fromId = contactGroup['fromId'];
    final toId = contactGroup['toId'];

    if (allContactGroups.containsKey(toId)) {
      final contactList = allContactGroups[toId]!;
      final existingIndex = contactList.indexWhere(
        (c) => c['fromId'] == fromId && c['toId'] == toId,
      );

      if (existingIndex != -1) {
        final existingContactGroup = contactList[existingIndex];
        contactGroup.forEach((key, value) {
          existingContactGroup[key] = value;
        });
        contactList[existingIndex] = existingContactGroup;
      } else {
        contactList.add(contactGroup);
      }
      allContactGroups[toId] = contactList;
    } else {
      allContactGroups[toId] = RxList<Map>.from([contactGroup]);
    }

    update();
  }

  //2、删除
  void delContactGroup(int fromId, int toId) {
    if (allContactGroups.containsKey(toId)) {
      final contactList = allContactGroups[toId];

      final existingIndex = contactList!.indexWhere(
        (c) => c['fromId'] == fromId && c['toId'] == toId,
      );

      if (existingIndex != -1) {
        contactList.removeAt(existingIndex);
        if (contactList.isEmpty) {
          allContactGroups.remove(toId);
        }
        update();
      }
    }
  }

  //2、删除
  void delContactGroupByGroupId(int toId) {
    if (allContactGroups.containsKey(toId)) {
      allContactGroups.remove(toId);
      update();
    }
  }

  //3、获得单条记录
  Map getOneContactGroup(int fromId, int toId) {
    if (allContactGroups.containsKey(toId)) {
      final existingIndex = allContactGroups[toId]!.indexWhere(
        (c) => c['fromId'] == fromId && c['toId'] == toId,
      );
      if (existingIndex != -1) {
        return allContactGroups[toId]![existingIndex];
      }
    }
    return {};
  }

  // 4、组成员
  RxList<Map> getMessages(int toId) {
    return allContactGroups[toId] ?? <Map>[].obs;
  }
}
