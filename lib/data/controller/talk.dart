import 'package:get/get.dart';

class TalkController extends GetxController {
  final RxMap talkObj = {}.obs;

  void setTalk(Map obj) {
    talkObj.value = obj.obs;
  }
}
