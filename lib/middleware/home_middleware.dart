import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qim/data/cache/keys.dart';
import 'package:qim/common/utils/cache.dart';

class HomeMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
    if (userInfo == null) {
      return const RouteSettings(name: '/login');
    } else {
      return null;
    }
  }
}
