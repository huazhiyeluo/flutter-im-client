import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qim/config/constants.dart';
import 'routes/route.dart';
import 'common/utils/cache.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await CacheHelper.getInstance();

  runApp(const MyApp());

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: AppColors.systemNavigationBarColor,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    }
  }

  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    debugPrint(flutterErrorDetails.toString());
    return const Center(child: Text("App错误,快去反馈给开发者!"));
  };
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
    _initData();
  }

  void _initData() async {
    String initialRouteData = await initialRoute();
    setState(() {
      _initialRoute = initialRouteData;
    });
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.backgroundColor,
      hintColor: Colors.grey.withOpacity(0.3),
      splashColor: Colors.transparent,
      canvasColor: Colors.transparent,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bottomBackgroundColor,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.sheetBackgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBackgroundColor,
        elevation: 1,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return GetMaterialApp(
        title: AppConstants.appName,
        theme: _buildAppTheme(),
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.rightToLeft,
        initialRoute: _initialRoute,
        getPages: AppPage.routes,
      );
    }
  }
}
