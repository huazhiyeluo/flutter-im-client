import 'package:flutter/material.dart';
import 'routes/route.dart';
import 'utils/cache.dart';
import 'package:get/get.dart';
import 'utils/db.dart';

void main() async {
  /// 确保初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  /// sp初始化
  await CacheHelper.getInstance();

// Define the database name and table SQLs
  String dbName = 'qim.db';
  List<String> tableSQLs = [
    'CREATE TABLE IF NOT EXISTS users (uid INTEGER PRIMARY KEY, username TEXT, avatar TEXT, info TEXT, exp INTEGER,createTime INTEGER,level INTEGER, remark TEXT,joinTime INTEGER, isOnline INTEGER)',
    'CREATE TABLE IF NOT EXISTS groups (groupId INTEGER PRIMARY KEY, ownerUid INTEGER, name TEXT, icon TEXT, info TEXT, num INTEGER,exp INTEGER,createTime INTEGER,level INTEGER, remark TEXT,joinTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS group_members (id INTEGER PRIMARY KEY AUTOINCREMENT, groupId INTEGER, memberId INTEGER, username TEXT, avatar TEXT,level INTEGER, remark TEXT,joinTime INTEGER, isOnline INTEGER)',
    'CREATE TABLE IF NOT EXISTS message (id INTEGER PRIMARY KEY AUTOINCREMENT, fromId INTEGER, toId INTEGER, avatar TEXT, msgType INTEGER, msgMedia INTEGER, content TEXT,  createTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS apply (id INTEGER PRIMARY KEY AUTOINCREMENT, fromId INTEGER, fromName TEXT, fromIcon TEXT, toId INTEGER, toName TEXT, toIcon TEXT, type INTEGER, status INTEGER, reason TEXT, operateTime INTEGER)',
    'CREATE TABLE IF NOT EXISTS chats (id INTEGER PRIMARY KEY,objId INTEGER,type INTEGER, name TEXT, info TEXT,remark TEXT, icon TEXT, weight INTEGER,tips INTEGER, operateTime INTEGER, msgMedia INTEGER, content TEXT)',
  ];

  await DBHelper.initDatabase(dbName, tableSQLs);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    String initialRouteData = initialRoute();
    setState(() {
      _initialRoute = initialRouteData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      return const CircularProgressIndicator(); // 显示加载指示器等待数据初始化完成
    } else {
      return GetMaterialApp(
        title: "QIM",
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        initialRoute: _initialRoute,
        defaultTransition: Transition.rightToLeft,
        getPages: AppPage.routes,
      );
    }
  }
}
