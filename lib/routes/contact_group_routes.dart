import 'package:get/get.dart';
import 'package:qim/middleware/home_middleware.dart';
import 'package:qim/pages/contact_group/group_chat_setting.dart';
import 'package:qim/pages/contact_group/group_chat_setting_nickname.dart';
import 'package:qim/pages/contact_group/group_chat_setting_remark.dart';
import 'package:qim/pages/contact_group/group_join.dart';
import 'package:qim/pages/contact_group/group_join_show.dart';
import 'package:qim/pages/contact_group/group_user.dart';
import 'package:qim/pages/contact_group/group_user_add_friend.dart';
import 'package:qim/pages/contact_group/group_user_delete.dart';
import 'package:qim/pages/contact_group/group_user_invite.dart';

class ContactGroupRoutes {
  static final routes = [
    GetPage(name: "/group-chat-setting", page: () => const GroupChatSetting(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-user", page: () => const GroupUser(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-user-delete", page: () => const GroupUserDelete(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-user-invite", page: () => const GroupUserInvite(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-user-add-friend", page: () => const GroupUserAddFriend(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-join", page: () => const GroupJoin(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-join-show", page: () => const GroupJoinShow(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-chat-setting-nickname", page: () => const GroupChatSettingNickname(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-chat-setting-remark", page: () => const GroupChatSettingRemark(), middlewares: [HomeMiddleware()]),
  ];
}
