import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/middleware/homeMiddleware.dart';
import 'package:qim/pages/contact/group_setting.dart';
import 'package:qim/pages/contact/group_user.dart';
import 'package:qim/pages/chat/talk.dart';
import 'package:qim/pages/contact/user_detail.dart';
import 'package:qim/pages/contact/user_setting.dart';
import 'package:qim/pages/contact/user_setting_remark.dart';
import 'package:qim/pages/notice/notice_group.dart';
import 'package:qim/pages/notice/notice_user.dart';
import 'package:qim/pages/notice/notice_user_detail.dart';
import 'package:qim/pages/contact/user_setting_chat.dart';
import 'package:qim/pages/home.dart';
import 'package:qim/pages/person/setting.dart';
import 'package:qim/pages/search.dart';
import 'package:qim/pages/entry.dart';
import 'package:qim/pages/user/login.dart';
import 'package:qim/pages/user/register_one.dart';
import 'package:qim/pages/user/register_two.dart';
import 'package:qim/pages/user/register_three.dart';
import 'package:qim/pages/user/repasswd.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/db.dart';

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
    GetPage(name: "/user-setting", page: () => const UserSetting()),
    GetPage(name: "/user-setting-remark", page: () => const UserSettingRemark()),
    GetPage(name: "/user-setting-chat", page: () => const UserSettingChat()),
    GetPage(name: "/user-detail", page: () => const UserDetail()),
    GetPage(name: "/group-setting", page: () => const Group()),
    GetPage(name: "/group-user", page: () => const GroupUser()),
    GetPage(name: "/notice-user", page: () => const NoticeUser()),
    GetPage(name: "/notice-user-detail", page: () => const NoticeUserDetail()),
    GetPage(name: "/notice-group", page: () => const NoticeGroup()),
    GetPage(name: "/person-setting", page: () => const Setting()),
  ];
}

Future<String> initialRoute() async {
  Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
  if (userInfo != null) {
    await initialDb(userInfo['uid']);
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

Future<void> initialDb(int uid) async {
  // Define the database name and table SQLs
  String dbName = 'qim-$uid.db';
  // await DBHelper.deleteDatabase(dbName);
  List<String> tableSQLs = [
    'CREATE TABLE IF NOT EXISTS contact_groups (friendGroupId INTEGER PRIMARY KEY, name TEXT, ownerUid INTEGER);',
    'CREATE TABLE IF NOT EXISTS users (uid INTEGER PRIMARY KEY, username TEXT, email TEXT, phone TEXT, avatar TEXT, sex INTEGER, birthday INTEGER, info TEXT, exp INTEGER, createTime INTEGER, friendGroupId INTEGER, level INTEGER, remark TEXT, isTop INTEGER, isHidden INTEGER, isQuiet INTEGER, joinTime INTEGER, isOnline INTEGER);',
    'CREATE TABLE IF NOT EXISTS groups (groupId INTEGER PRIMARY KEY, ownerUid INTEGER, name TEXT, icon TEXT, info TEXT, num INTEGER, exp INTEGER, createTime INTEGER, groupPower INTEGER, level INTEGER, remark TEXT, nickname TEXT, isTop INTEGER, isHidden INTEGER, isQuiet INTEGER, joinTime INTEGER);',
    'CREATE TABLE IF NOT EXISTS group_members (id INTEGER PRIMARY KEY AUTOINCREMENT, groupId INTEGER, memberId INTEGER, username TEXT, avatar TEXT,level INTEGER, remark TEXT,joinTime INTEGER, isOnline INTEGER)',
    'CREATE TABLE IF NOT EXISTS message (id INTEGER PRIMARY KEY AUTOINCREMENT, fromId INTEGER, toId INTEGER, avatar TEXT, msgType INTEGER, msgMedia INTEGER, content TEXT,  createTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS apply (id INTEGER PRIMARY KEY AUTOINCREMENT, fromId INTEGER, fromName TEXT, fromIcon TEXT, toId INTEGER, toName TEXT, toIcon TEXT, type INTEGER, status INTEGER, reason TEXT, operateTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS chats (id INTEGER PRIMARY KEY,objId INTEGER,type INTEGER, name TEXT, info TEXT,remark TEXT, icon TEXT, weight INTEGER,tips INTEGER, operateTime INTEGER, msgMedia INTEGER, content TEXT)',
  ];
  await DBHelper.initDatabase(dbName, tableSQLs);
}
