import 'package:get/get.dart';
import 'package:qim/middleware/home_middleware.dart';
import 'package:qim/pages/contact_friend/friend_chat_setting.dart';
import 'package:qim/pages/contact_friend/friend_detail.dart';
import 'package:qim/pages/contact_friend/friend_detail_more.dart';
import 'package:qim/pages/contact_friend/friend_detail_setting.dart';
import 'package:qim/pages/contact_friend/friend_detail_setting_group.dart';
import 'package:qim/pages/contact_friend/friend_detail_setting_remark.dart';
import 'package:qim/pages/contact_friend/friend_group.dart';

class ContactFriendRoutes {
  static final routes = [
    GetPage(name: "/friend-chat-setting", page: () => const FriendSettingChat(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/friend-detail-more", page: () => const FriendDetailMore(), middlewares: [HomeMiddleware()]),
    GetPage(
        name: "/friend-detail-setting-remark",
        page: () => const FriendDetailSettingRemark(),
        middlewares: [HomeMiddleware()]),
    GetPage(
        name: "/friend-detail-setting-group",
        page: () => const FriendDetailSettingGroup(),
        middlewares: [HomeMiddleware()]),
    GetPage(name: "/friend-detail-setting", page: () => const FriendDetailSetting(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/friend-detail", page: () => const FriendDetail(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/friend-group", page: () => const FriendGroup(), middlewares: [HomeMiddleware()]),
  ];
}
