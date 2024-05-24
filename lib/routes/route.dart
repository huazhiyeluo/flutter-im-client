import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/middleware/homeMiddleware.dart';
import 'package:qim/pages/other/group.dart';
import 'package:qim/pages/other/group_user.dart';
import 'package:qim/pages/chat/talk_phone.dart';
import 'package:qim/pages/chat/talk.dart';
import 'package:qim/pages/other/notice_group.dart';
import 'package:qim/pages/other/notice_user.dart';
import 'package:qim/pages/other/user.dart';
import 'package:qim/pages/home.dart';
import 'package:qim/pages/search.dart';
import 'package:qim/pages/entry.dart';
import 'package:qim/pages/test.dart';
import 'package:qim/pages/users/login.dart';
import 'package:qim/pages/users/register_one.dart';
import 'package:qim/pages/users/register_two.dart';
import 'package:qim/pages/users/register_three.dart';
import 'package:qim/pages/users/repasswd.dart';
import 'package:qim/utils/cache.dart';

class AppPage {
  static final routes = [
    GetPage(name: "/", page: () => const Home(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/entry", page: () => const Entry()),
    GetPage(name: "/login", page: () => const Login()),
    GetPage(name: "/register-one", page: () => const RegisterOne()),
    GetPage(name: "/register-two", page: () => const RegisterTwo()),
    GetPage(name: "/register-three", page: () => const RegisterThree()),
    GetPage(name: "/repasswd", page: () => const Repasswd()),
    GetPage(name: "/search", page: () => const Search()),
    GetPage(name: "/talk", page: () => const Talk()),
    GetPage(name: "/talk-phone", page: () => const TalkPhone()),
    GetPage(name: "/user", page: () => const User()),
    GetPage(name: "/group", page: () => const Group()),
    GetPage(name: "/group-user", page: () => const GroupUser()),
    GetPage(name: "/notice-user", page: () => const NoticeUser()),
    GetPage(name: "/notice-group", page: () => const NoticeGroup()),
    GetPage(name: "/test", page: () => const Test()),
  ];
}

String initialRoute() {
  Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
  if (userInfo != null) {
    return "/";
  } else {
    bool? entryPage = CacheHelper.getBoolData(Keys.entryPage);
    if (entryPage == true) {
      return '/login';
    } else {
      return '/entry';
    }
  }
}
