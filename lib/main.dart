import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes/route.dart';
import 'common/utils/cache.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  /// 确保初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color.fromRGBO(237, 237, 237, 1),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

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
          scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          hintColor: Colors.grey.withOpacity(0.3),
          splashColor: const Color.fromARGB(0, 37, 15, 15),
          canvasColor: Colors.transparent,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[200], // 设置 AppBar 背景色
            elevation: 1, // 如果你想要去掉 AppBar 的阴影，可以设置为 0
            titleTextStyle: const TextStyle(
              fontSize: 18, // 设置文字大小
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: _initialRoute,
        defaultTransition: Transition.rightToLeft,
        getPages: AppPage.routes,
      );
    }
  }
}
