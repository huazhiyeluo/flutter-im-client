import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      return const CircularProgressIndicator(); // 显示加载指示器等待数据初始化完成
    } else {
      return GetMaterialApp(
        title: "QIM",
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(246, 255, 255, 255),
          hintColor: Colors.grey.withOpacity(0.3),
          splashColor: const Color.fromARGB(0, 37, 15, 15),
          canvasColor: Colors.transparent,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: _initialRoute,
        defaultTransition: Transition.rightToLeft,
        getPages: AppPage.routes,
      );
    }
  }
}
