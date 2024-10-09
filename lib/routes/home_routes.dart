import 'package:get/get.dart';
import 'package:qim/middleware/home_middleware.dart';
import 'package:qim/pages/chat/talk.dart';
import 'package:qim/pages/home.dart';
import 'package:qim/pages/notice/notice_group.dart';
import 'package:qim/pages/notice/notice_user.dart';
import 'package:qim/pages/notice/notice_user_detail.dart';
import 'package:qim/pages/search.dart';
import 'package:qim/pages/qrview.dart';
import 'package:qim/pages/share/share.dart';
import 'package:qim/pages/share/share_shect.dart';
import 'package:qim/pages/term.dart';

class HomeRoutes {
  static final routes = [
    GetPage(name: "/", page: () => const Home(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/talk", page: () => const Talk(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/notice-user", page: () => const NoticeUser(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/notice-friend-detail", page: () => const NoticeFriendDetail(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/notice-group", page: () => const NoticeGroup(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/search", page: () => const Search(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/qrview", page: () => const QrView(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/share", page: () => const Share(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/share-select", page: () => const ShareSelect(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/term", page: () => const Term()),
  ];
}
