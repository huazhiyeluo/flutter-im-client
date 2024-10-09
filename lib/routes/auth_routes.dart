import 'package:get/get.dart';
import 'package:qim/pages/auth/login.dart';
import 'package:qim/pages/auth/login_code.dart';
import 'package:qim/pages/auth/register.dart';
import 'package:qim/pages/auth/repasswd.dart';

class AuthRoutes {
  static final routes = [
    GetPage(name: "/login", page: () => const Login()),
    GetPage(name: "/login-code", page: () => const LoginCode()),
    GetPage(name: "/repasswd", page: () => const Repasswd()),
    GetPage(name: "/register", page: () => const Register()),
  ];
}
