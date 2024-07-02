import 'package:flutter/material.dart';
import 'package:qim/pages/test/test1.dart';
import 'package:qim/pages/test/test2.dart';
import 'routes/route.dart';
import 'utils/cache.dart';
import 'package:get/get.dart';

void main() async {
  /// 确保初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  /// sp初始化
  await CacheHelper.getInstance();

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
    String initialRouteData = await initialRoute();
    setState(() {
      _initialRoute = initialRouteData;
    });
  }

  // Map routes = {
  //   "/test1": (context, {arguments}) => Test1(arguments: arguments),
  //   "/test2": (context) => const Test2("liao"),
  // };

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      return const CircularProgressIndicator(); // 显示加载指示器等待数据初始化完成
    } else {
      return GetMaterialApp(
        title: "QIM",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: _initialRoute,
        defaultTransition: Transition.rightToLeft,
        getPages: AppPage.routes,
        // onGenerateRoute: (settings) {
        //   // 获取路由名称
        //   String? name = settings.name;

        //   final Function? pageContentBuilder = routes[name];

        //   if (pageContentBuilder != null) {
        //     if (settings.arguments != null) {
        //       final Route route = MaterialPageRoute(
        //         builder: (context) => pageContentBuilder(context, arguments: settings.arguments),
        //       );
        //       return route;
        //     } else {
        //       final Route route = MaterialPageRoute(
        //         builder: (context) => pageContentBuilder(context),
        //       );
        //       return route;
        //     }
        //   }
        //   return null;
        // },
      );
    }
  }
}
