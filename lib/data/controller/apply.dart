import 'package:get/get.dart';

class ApplyController extends GetxController {
  final RxList<Map> allApplys = <Map>[].obs;
  final RxList<Map> allFriendApplys = <Map>[].obs;
  final RxList<Map> allGroupApplys = <Map>[].obs;
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
    allFriendApplys.assignAll(allApplys.where((c) => c['type'] == 1).toList());
    allGroupApplys.assignAll(allApplys.where((c) => c['type'] == 2).toList());

    allFriendApplys.sort((a, b) {
      int compareStatus = a['status'].compareTo(b['status']);
      if (compareStatus != 0) {
        return compareStatus;
      } else {
        return b['operateTime'].compareTo(a['operateTime']);
      }
    });

    allGroupApplys.sort((a, b) {
      int compareStatus = a['status'].compareTo(b['status']);
      if (compareStatus != 0) {
        return compareStatus;
      } else {
        return b['operateTime'].compareTo(a['operateTime']);
      }
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

  Map getOneApply(int id) {
    // 查找是否已经存在相同的数据
    final existingApplyIndex = allApplys.indexWhere((c) => c['id'] == id);
    if (existingApplyIndex != -1) {
      return allApplys[existingApplyIndex];
    }
    return {};
  }

  void clearApply(int type) {
    allApplys.removeWhere((c) => c['type'] == type);
    allFriendApplys.assignAll(allApplys.where((c) => c['type'] == 1).toList());
    allGroupApplys.assignAll(allApplys.where((c) => c['type'] == 2).toList());
    if (type == 1) {
      showFriendRedPoint.value = false;
    }
    if (type == 2) {
      showGroupRedPoint.value = false;
    }
    update();
  }
}
