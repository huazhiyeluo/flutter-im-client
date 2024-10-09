import 'package:qim/common/utils/cache.dart';
import 'package:qim/data/cache/keys.dart';
import 'package:qim/data/db/init.dart';
import 'package:qim/routes/contact_friend_routes.dart';
import 'package:qim/routes/contact_group_routes.dart';
import 'package:qim/routes/user_routes.dart';
import 'auth_routes.dart';
import 'home_routes.dart';
import 'contact_routes.dart';
import 'group_routes.dart';

class AppPage {
  static final routes = [
    ...AuthRoutes.routes,
    ...HomeRoutes.routes,
    ...ContactRoutes.routes,
    ...ContactFriendRoutes.routes,
    ...ContactGroupRoutes.routes,
    ...GroupRoutes.routes,
    ...UserRoutes.routes,
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
