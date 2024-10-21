import 'package:get/get.dart';

class ShareController extends GetxController {
  final RxList<Map> allShares = <Map>[].obs;

  void upsetShare(Map share) {
    final objId = share['objId'];
    final type = share['type'];

    final existingShareIndex = allShares.indexWhere((c) => c['objId'] == objId && c['type'] == type);

    if (existingShareIndex != -1) {
      final existingShare = Map<String, dynamic>.from(allShares[existingShareIndex]);
      share.forEach((key, value) {
        if (existingShare.containsKey(key)) {
          existingShare[key] = value;
        }
      });
      allShares[existingShareIndex] = existingShare;
    } else {
      allShares.add(share);
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
    final existingShareIndex = allShares.indexWhere((c) => c['objId'] == objId && c['type'] == type);
    if (existingShareIndex != -1) {
      return allShares[existingShareIndex];
    }
    return {};
  }
}
