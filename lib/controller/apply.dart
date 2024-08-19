import 'package:get/get.dart';

class ApplyController extends GetxController {
  final RxList<Map> allApplys = <Map>[].obs;
  final RxList<Map> allFriendChats = <Map>[].obs;
  final RxList<Map> allGroupChats = <Map>[].obs;
  RxBool showFriendRedPoint = false.obs;
  RxBool showGroupRedPoint = false.obs;

  void upsetApply(Map apply) {
    final id = apply['id'];

    // 查找是否已经存在相同的数据
    final existingApplyIndex = allApplys.indexWhere((c) => c['id'] == id);

    if (existingApplyIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingApply = allApplys[existingApplyIndex];
      apply.forEach((key, value) {
        if (existingApply.containsKey(key)) {
          existingApply[key] = value;
        }
      });
      allApplys[existingApplyIndex] = existingApply;
    } else {
      // 否则，将数据添加到列表中
      allApplys.add(apply);
    }
    allFriendChats.assignAll(allApplys.where((c) => c['type'] == 1).toList());
    allGroupChats.assignAll(allApplys.where((c) => c['type'] == 2).toList());

    allFriendChats.sort((a, b) {
      return a['status'].compareTo(b['status']);
    });
    allGroupChats.sort((a, b) {
      return a['status'].compareTo(b['status']);
    });

    showFriendRedPoint.value = false;
    showGroupRedPoint.value = false;
    allApplys.where((c) => c['type'] == 1 && c['status'] == 0).forEach((element) {
      showFriendRedPoint.value = true;
    });

    allApplys.where((c) => c['type'] == 2 && c['status'] == 0).forEach((element) {
      showGroupRedPoint.value = true;
    });

    update();
  }

  Map? getOneApply(int id) {
    // 查找是否已经存在相同的数据
    final existingApplyIndex = allApplys.indexWhere((c) => c['id'] == id);
    if (existingApplyIndex != -1) {
      return allApplys[existingApplyIndex];
    }
    return null;
  }

  void clearApply(int type) {
    allApplys.removeWhere((c) => c['type'] == type);
    allFriendChats.assignAll(allApplys.where((c) => c['type'] == 1).toList());
    allGroupChats.assignAll(allApplys.where((c) => c['type'] == 2).toList());
    if (type == 1) {
      showFriendRedPoint.value = false;
    }
    if (type == 2) {
      showGroupRedPoint.value = false;
    }
    update();
  }
}
