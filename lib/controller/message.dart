import 'package:get/get.dart';
import 'package:qim/utils/common.dart';

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

  // 获取指定用户的消息列表
  RxList<Map> getMessages(String key) {
    return allUserMessages[key] ?? <Map>[].obs;
  }
}
