import 'package:get/get.dart';
import 'package:qim/middleware/home_middleware.dart';
import 'package:qim/pages/group/group_create.dart';
import 'package:qim/pages/group/group_detail.dart';
import 'package:qim/pages/group/group_info.dart';
import 'package:qim/pages/group/group_manage.dart';
import 'package:qim/pages/group/group_manage_add.dart';
import 'package:qim/pages/group/group_setting_info.dart';
import 'package:qim/pages/group/group_setting_name.dart';

class GroupRoutes {
  static final routes = [
    GetPage(name: "/group-create", page: () => const GroupCreate(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-detail", page: () => const GroupDetail(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-info", page: () => const GroupInfo(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-setting-info", page: () => const GroupSettingInfo(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-setting-name", page: () => const GroupSettingName(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-manager", page: () => const GroupManager(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/group-manager-add", page: () => const GroupManagerAdd(), middlewares: [HomeMiddleware()]),
  ];
}
