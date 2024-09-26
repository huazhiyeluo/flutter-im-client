import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/middleware/home_middleware.dart';
import 'package:qim/pages/contact/add_contact.dart';
import 'package:qim/pages/contact/add_contact_friend_do.dart';
import 'package:qim/pages/contact/add_contact_group_do.dart';
import 'package:qim/pages/contact_friend/friend_detail_more.dart';
import 'package:qim/pages/contact_friend/friend_group.dart';
import 'package:qim/pages/contact_group/group_chat_setting.dart';
import 'package:qim/pages/contact_group/group_chat_setting_nickname.dart';
import 'package:qim/pages/contact_group/group_chat_setting_remark.dart';
import 'package:qim/pages/contact_group/group_join.dart';
import 'package:qim/pages/contact_group/group_join_show.dart';
import 'package:qim/pages/contact_group/group_user.dart';
import 'package:qim/pages/chat/talk.dart';
import 'package:qim/pages/contact_friend/friend_detail.dart';
import 'package:qim/pages/contact_friend/friend_detail_setting.dart';
import 'package:qim/pages/contact_friend/friend_detail_setting_remark.dart';
import 'package:qim/pages/contact_group/group_user_add_friend.dart';
import 'package:qim/pages/contact_group/group_user_delete.dart';
import 'package:qim/pages/contact_group/group_user_invite.dart';
import 'package:qim/pages/group/create.dart';
import 'package:qim/pages/group/group_detail.dart';
import 'package:qim/pages/group/group_info.dart';
import 'package:qim/pages/group/group_setting_info.dart';
import 'package:qim/pages/group/group_setting_name.dart';
import 'package:qim/pages/notice/notice_group.dart';
import 'package:qim/pages/notice/notice_user.dart';
import 'package:qim/pages/notice/notice_user_detail.dart';
import 'package:qim/pages/contact_friend/friend_chat_setting.dart';
import 'package:qim/pages/home.dart';
import 'package:qim/pages/person/info.dart';
import 'package:qim/pages/person/info_info.dart';
import 'package:qim/pages/person/info_username.dart';
import 'package:qim/pages/person/info_username_bind.dart';
import 'package:qim/pages/person/setting.dart';
import 'package:qim/pages/person/info_nickname.dart';
import 'package:qim/pages/qrview.dart';
import 'package:qim/pages/search.dart';
import 'package:qim/pages/share/share.dart';
import 'package:qim/pages/share/share_shect.dart';
import 'package:qim/pages/user/login.dart';
import 'package:qim/pages/user/login_code.dart';
import 'package:qim/pages/user/register.dart';
import 'package:qim/pages/term.dart';
import 'package:qim/pages/user/repasswd.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/db.dart';

import '../pages/contact_friend/friend_detail_setting_group.dart';

class AppPage {
  static final routes = [
    GetPage(name: "/login", page: () => const Login()),
    GetPage(name: "/login-code", page: () => const LoginCode()),
    GetPage(name: "/repasswd", page: () => const Repasswd()),
    GetPage(name: "/register", page: () => const Register()),
    GetPage(name: "/term", page: () => const Term()),
    GetPage(name: "/search", page: () => const Search()),
    GetPage(name: "/qrview", page: () => const QrView()),
    GetPage(name: "/share", page: () => const Share()),
    GetPage(name: "/share-select", page: () => const ShareSelect()),
    GetPage(name: "/", page: () => const Home(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/talk", page: () => const Talk(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/notice-user", page: () => const NoticeUser(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/notice-friend-detail", page: () => const NoticeFriendDetail(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/notice-group", page: () => const NoticeGroup(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/person-setting", page: () => const Setting(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/person-info", page: () => const PersonInfo(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/person-info-nickname", page: () => const PersonInfoNickname(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/person-info-username", page: () => const PersonInfoUsername(), middlewares: [HomeMiddleware()]),
    GetPage(
        name: "/person-info-username-bind",
        page: () => const PersonInfoUsernameBind(),
        middlewares: [HomeMiddleware()]),
    GetPage(name: "/person-info-info", page: () => const PersonInfoInfo(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/add-contact", page: () => const AddContact(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/add-contact-friend-do", page: () => const AddContactFriendDo(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/add-contact-group-do", page: () => const AddContactGroupDo(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/friend-detail", page: () => const FriendDetail(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/friend-detail-more", page: () => const FriendDetailMore(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/friend-detail-setting", page: () => const FriendDetailSetting(), middlewares: [HomeMiddleware()]),
    GetPage(
        name: "/friend-detail-setting-remark",
        page: () => const FriendDetailSettingRemark(),
        middlewares: [HomeMiddleware()]),
    GetPage(
        name: "/friend-detail-setting-group",
        page: () => const FriendDetailSettingGroup(),
        middlewares: [HomeMiddleware()]),
    GetPage(name: "/friend-group", page: () => const FriendGroup(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/friend-chat-setting", page: () => const FriendSettingChat(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-chat-setting", page: () => const GroupChatSetting(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-user", page: () => const GroupUser(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-user-delete", page: () => const GroupUserDelete(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-user-invite", page: () => const GroupUserInvite(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-user-add-friend", page: () => const GroupUserAddFriend(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-join", page: () => const GroupJoin(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-join-show", page: () => const GroupJoinShow(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-create", page: () => const GroupCreate(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-detail", page: () => const GroupDetail(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-info", page: () => const GroupInfo(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-setting-name", page: () => const GroupSettingName(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-setting-info", page: () => const GroupSettingInfo(), middlewares: [HomeMiddleware()]),
    GetPage(
        name: "/group-chat-setting-nickname",
        page: () => const GroupChatSettingNickname(),
        middlewares: [HomeMiddleware()]),
    GetPage(
        name: "/group-chat-setting-remark",
        page: () => const GroupChatSettingRemark(),
        middlewares: [HomeMiddleware()]),
  ];
}

Future<String> initialRoute() async {
  Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
  if (userInfo != null) {
    await initialDb(userInfo['uid']);
    return "/";
  } else {
    return '/login';
  }
}

Future<void> initialDb(int uid) async {
  // Define the database name and table SQLs
  String dbName = 'qim-$uid.db';
  // await DBHelper.deleteDatabase(dbName);
  List<String> tableSQLs = [
    'CREATE TABLE IF NOT EXISTS `user` (uid INTEGER PRIMARY KEY, nickname TEXT, email TEXT, phone TEXT, avatar TEXT, sex INTEGER, birthday INTEGER, info TEXT, exp INTEGER, createTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS `group` (groupId INTEGER PRIMARY KEY, ownerUid INTEGER, name TEXT, icon TEXT, info TEXT, num INTEGER, exp INTEGER, createTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS `apply` (id INTEGER PRIMARY KEY, fromId INTEGER, fromName TEXT, fromIcon TEXT, toId INTEGER, toName TEXT, toIcon TEXT, type INTEGER, status INTEGER, reason TEXT, operateTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS `friend_group` (friendGroupId INTEGER PRIMARY KEY, name TEXT, ownerUid INTEGER, isDefault INTEGER, sort INTEGER);',
    'CREATE TABLE IF NOT EXISTS `contact_friend` (fromId INTEGER,toId INTEGER,friendGroupId INTEGER, level INTEGER, remark TEXT,desc TEXT,isTop INTEGER, isHidden INTEGER, isQuiet INTEGER, joinTime INTEGER, isOnline INTEGER);',
    'CREATE TABLE IF NOT EXISTS `contact_group` (fromId INTEGER,toId INTEGER,groupPower INTEGER, level INTEGER, remark TEXT, nickname TEXT, isTop INTEGER, isHidden INTEGER, isQuiet INTEGER, joinTime INTEGER);',
    'CREATE TABLE IF NOT EXISTS `message` (id INTEGER PRIMARY KEY, fromId INTEGER, toId INTEGER, nickname TEXT,avatar TEXT, msgType INTEGER, msgMedia INTEGER, content TEXT,  createTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS `chat` (id INTEGER PRIMARY KEY,objId INTEGER,type INTEGER, name TEXT, info TEXT,remark TEXT, icon TEXT, isTop INTEGER, isHidden INTEGER, isQuiet INTEGER, tips INTEGER, operateTime INTEGER, msgMedia INTEGER, content TEXT)',
  ];
  await DBHelper.initDatabase(dbName, tableSQLs);
}
