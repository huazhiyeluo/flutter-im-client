import 'package:get/get.dart';

class ChatController extends GetxController {
  final RxList<Map> allChats = <Map>[].obs;
  final RxList<Map> allShowChats = <Map>[].obs;

  void upsetChat(Map chat) {
    final objId = chat['objId'];
    final type = chat['type'];
    // 查找是否已经存在相同的数据
    final existingChatIndex = allChats.indexWhere((c) => c['objId'] == objId && c['type'] == type);

    if (existingChatIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingChat = allChats[existingChatIndex];
      chat.forEach((key, value) {
        if (existingChat.containsKey(key)) {
          existingChat[key] = value;
        }
      });
      allChats[existingChatIndex] = existingChat;
    } else {
      // 否则，将数据添加到列表中
      allChats.add(chat);
    }
    allChats.sort((a, b) {
      int compareWeight = b['isTop'].compareTo(a['isTop']);
      if (compareWeight != 0) {
        return compareWeight;
      } else {
        return b['operateTime'].compareTo(a['operateTime']);
      }
    });

    allShowChats.assignAll(allChats.where((c) => c['isHidden'] != 1).toList());

    update();
  }

  void delChat(int objId, int type) {
    final existingChatIndex = allChats.indexWhere((c) => c['objId'] == objId && c['type'] == type);
    if (existingChatIndex != -1) {
      allChats.removeAt(existingChatIndex);
    }

    final existingChatShowIndex = allShowChats.indexWhere((c) => c['objId'] == objId && c['type'] == type);
    if (existingChatIndex != -1) {
      allShowChats.removeAt(existingChatShowIndex);
    }
    update();
  }

  Map getOneChat(int objId, int type) {
    // 查找是否已经存在相同的数据
    final existingChatIndex = allChats.indexWhere((c) => c['objId'] == objId && c['type'] == type);
    if (existingChatIndex != -1) {
      return allChats[existingChatIndex];
    }
    return {};
  }

  int getTipsTotalNum() {
    int total = 0;
    for (var item in allShowChats) {
      total += (item["tips"] ?? 0) as int;
    }
    return total;
  }
}
