import 'package:get/get.dart';
import 'package:qim/middleware/home_middleware.dart';
import 'package:qim/pages/contact/add_contact.dart';
import 'package:qim/pages/contact/add_contact_friend_do.dart';
import 'package:qim/pages/contact/add_contact_group_do.dart';

class ContactRoutes {
  static final routes = [
    GetPage(name: "/add-contact", page: () => const AddContact(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/add-contact-friend-do", page: () => const AddContactFriendDo(), middlewares: [HomeMiddleware()]),
    GetPage(name: "/add-contact-group-do", page: () => const AddContactGroupDo(), middlewares: [HomeMiddleware()]),
  ];
}
