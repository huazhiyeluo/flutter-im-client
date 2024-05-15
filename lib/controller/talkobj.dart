import 'package:get/get.dart';

class TalkobjController extends GetxController {
  final RxMap talkObj = {}.obs;

  void setTalkObj(Map obj) {
    talkObj.value = obj;
  }
}
