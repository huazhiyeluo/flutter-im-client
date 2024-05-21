import 'package:get/get.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/savedata.dart';

class MessageController extends GetxController {
  final RxMap<String, RxList<Map>> allUserMessages = <String, RxList<Map>>{}.obs;

  void addMessage(Map msg) {
    final key = getKey(msgType: msg['msgType'], fromId: msg['fromId'], toId: msg['toId']);
    allUserMessages.putIfAbsent(key, () => <Map>[].obs).add(msg);
    saveMessage(msg);
    update();
  }
}
