import 'package:get/get.dart';
import 'package:qim/common/utils/common.dart';

class MessageController extends GetxController {
  final RxMap<String, RxList<Map>> allUserMessages = <String, RxList<Map>>{}.obs;

  void addMessage(Map msg) {
    final key = getKey(msgType: msg['msgType'], fromId: msg['fromId'], toId: msg['toId']);
    allUserMessages.putIfAbsent(key, () => <Map>[].obs).insert(0, msg);
    update();
  }

  void delMessage(int msgType, int fromId, int toId) {
    final key = getKey(msgType: msgType, fromId: fromId, toId: toId);
    if (allUserMessages.containsKey(key)) {
      allUserMessages[key]?.clear();
      update();
    }
  }

  // 删除指定 ID 的消息
  void delMessageById(Map msg) {
    final key = getKey(msgType: msg['msgType'], fromId: msg['fromId'], toId: msg['toId']);
    if (allUserMessages.containsKey(key)) {
      final messageList = allUserMessages[key];
      // 使用 removeWhere 删除指定 id 的消息
      messageList?.removeWhere((temp) => temp['id'] == msg['id']);
      update();
    }
  }

  // 获取指定用户的消息列表
  RxList<Map> getMessages(String key) {
    return allUserMessages[key] ?? <Map>[].obs;
  }
}
