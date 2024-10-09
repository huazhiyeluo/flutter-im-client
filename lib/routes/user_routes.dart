import 'package:get/get.dart';
import 'package:qim/middleware/home_middleware.dart';
import 'package:qim/pages/user/user_detail.dart';
import 'package:qim/pages/user/user_detail_info.dart';
import 'package:qim/pages/user/user_nickname.dart';
import 'package:qim/pages/user/user_username.dart';
import 'package:qim/pages/user/user_username_bind.dart';
import 'package:qim/pages/user/setting.dart';
import 'package:qim/pages/user/user_info.dart';

class UserRoutes {
  static final routes = [
    GetPage(name: "/setting", page: () => const Setting(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/user-detail", page: () => const UserDetail(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/user-info", page: () => const UserInfo(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/user-detail-info", page: () => const UserDetailInfo(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/user-nickname", page: () => const UserNickname(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/user-username", page: () => const UserUsername(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/user-username-bind", page: () => const UserUsernameBind(), middlewares: [HomeMiddleware()]),
  ];
}
