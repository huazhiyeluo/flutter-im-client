import 'package:get/get.dart';

class ShareController extends GetxController {
  final RxList<Map> allShares = <Map>[].obs;

  void upsetShare(Map chat) {
    final objId = chat['objId'];
    final type = chat['type'];
    // 查找是否已经存在相同的数据
    final existingShareIndex = allShares.indexWhere((c) => c['objId'] == objId && c['type'] == type);

    if (existingShareIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingShare = allShares[existingShareIndex];
      chat.forEach((key, value) {
        if (existingShare.containsKey(key)) {
          existingShare[key] = value;
        }
      });
      allShares[existingShareIndex] = existingShare;
    } else {
      // 否则，将数据添加到列表中
      allShares.add(chat);
    }
    allShares.sort((a, b) {
      return b['operateTime'].compareTo(a['operateTime']);
    });

    update();
  }

  void delShare(int objId, int type) {
    final existingShareIndex = allShares.indexWhere((c) => c['objId'] == objId && c['type'] == type);
    if (existingShareIndex != -1) {
      allShares.removeAt(existingShareIndex);
    }
    update();
  }

  Map getOneShare(int objId, int type) {
    // 查找是否已经存在相同的数据
    final existingShareIndex = allShares.indexWhere((c) => c['objId'] == objId && c['type'] == type);
    if (existingShareIndex != -1) {
      return allShares[existingShareIndex];
    }
    return {};
  }
}
