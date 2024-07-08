import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/middleware/homeMiddleware.dart';
import 'package:qim/pages/other/group.dart';
import 'package:qim/pages/other/group_user.dart';
import 'package:qim/pages/chat/talk.dart';
import 'package:qim/pages/other/notice_group.dart';
import 'package:qim/pages/other/notice_user.dart';
import 'package:qim/pages/other/notice_user_detail.dart';
import 'package:qim/pages/other/user.dart';
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
    GetPage(name: "/user", page: () => const User()),
    GetPage(name: "/group", page: () => const Group()),
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
  List<String> tableSQLs = [
    'CREATE TABLE IF NOT EXISTS users (uid INTEGER PRIMARY KEY, username TEXT, avatar TEXT, info TEXT, exp INTEGER,createTime INTEGER,level INTEGER, remark TEXT,joinTime INTEGER, isOnline INTEGER)',
    'CREATE TABLE IF NOT EXISTS groups (groupId INTEGER PRIMARY KEY, ownerUid INTEGER, name TEXT, icon TEXT, info TEXT, num INTEGER,exp INTEGER,createTime INTEGER,level INTEGER, remark TEXT,joinTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS group_members (id INTEGER PRIMARY KEY AUTOINCREMENT, groupId INTEGER, memberId INTEGER, username TEXT, avatar TEXT,level INTEGER, remark TEXT,joinTime INTEGER, isOnline INTEGER)',
    'CREATE TABLE IF NOT EXISTS message (id INTEGER PRIMARY KEY AUTOINCREMENT,belongFlag TEXT, fromId INTEGER, toId INTEGER, avatar TEXT, msgType INTEGER, msgMedia INTEGER, content TEXT,  createTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS apply (id INTEGER PRIMARY KEY AUTOINCREMENT, fromId INTEGER, fromName TEXT, fromIcon TEXT, toId INTEGER, toName TEXT, toIcon TEXT, type INTEGER, status INTEGER, reason TEXT, operateTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS chats (id INTEGER PRIMARY KEY,objId INTEGER,type INTEGER, name TEXT, info TEXT,remark TEXT, icon TEXT, weight INTEGER,tips INTEGER, operateTime INTEGER, msgMedia INTEGER, content TEXT)',
  ];
  await DBHelper.initDatabase(dbName, tableSQLs);
}
