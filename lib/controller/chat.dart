import 'package:get/get.dart';
import 'package:qim/utils/functions.dart';

class ChatController extends GetxController {
  final RxList<Map> allChats = <Map>[].obs;

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
    logPrint(allChats);
    update();
  }

  // [{"field":'', value:"1", opt:0}]
  void upsetOptChat(int objId, int type, List<Map<String, dynamic>> chatList) {
    // 查找是否已经存在相同的数据
    final existingChatIndex = allChats.indexWhere((c) => c['objId'] == objId && c['type'] == type);

    if (existingChatIndex != -1) {
      // 如果已经存在相同的数据，则更新对应字段的值
      final existingChat = allChats[existingChatIndex];
      for (var chat in chatList) {
        final field = chat['field'];
        final value = chat['value'];
        final opt = chat['opt'];

        if (existingChat.containsKey(field)) {
          if (opt == 0 && value is num && existingChat[field] is num) {
            existingChat[field] += value;
          } else if (opt == 1 && value is num && existingChat[field] is num) {
            existingChat[field] -= value;
          } else {
            existingChat[field] = value;
          }
        } else {
          existingChat[field] = value;
        }
      }
      allChats[existingChatIndex] = existingChat;
    } else {
      // 否则，将数据添加到列表中
      final newChat = {
        'objId': objId,
        'type': type,
      };
      for (var chat in chatList) {
        newChat[chat['field']] = chat['value'];
      }
      allChats.add(newChat);
    }
    update();
  }

  Map? getOneChat(int objId, int type) {
    // 查找是否已经存在相同的数据
    final existingChatIndex = allChats.indexWhere((c) => c['objId'] == objId && c['type'] == type);
    if (existingChatIndex != -1) {
      return allChats[existingChatIndex];
    }
    return null;
  }

  int getTipsTotalNum() {
    int total = 0;
    for (var item in allChats) {
      total += (item["tips"] ?? 0) as int;
    }
    return total;
  }
}
