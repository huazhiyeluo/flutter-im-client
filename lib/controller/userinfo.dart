import 'package:get/get.dart';

class UserInfoController extends GetxController {
  final RxMap userInfo = {}.obs;

  void setUserInfo(Map obj) {
    userInfo.value = obj;
  }
}
