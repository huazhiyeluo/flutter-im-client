import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/data/controller/userinfo.dart';

final List<Map<String, dynamic>> items = [
  {"val": 1, "label": "创建群聊", "icon": Icons.wechat},
  {"val": 2, "label": "加好友/群", "icon": Icons.person_add_alt},
  {"val": 3, "label": "扫一扫", "icon": Icons.qr_code},
];

AppBar chatBar() {
  final UserInfoController userInfoController = Get.find();
  Map userInfo = userInfoController.userInfo;
  String nickname = userInfo['nickname'];
  String avatar = userInfo['avatar'];
  return AppBar(
      centerTitle: false,
      title: Row(
        children: [
          CircleAvatar(
            // 聊天对象的头像
            radius: 16,
            backgroundImage: CachedNetworkImageProvider(avatar),
          ),
          const SizedBox(width: 8),
          Text(
            nickname,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "1") {
              Get.toNamed('/group-create');
            }
            if (value == "2") {
              Get.toNamed('/add-contact');
            }
            if (value == "3") {
              Get.toNamed('/qrview');
            }
          },
          position: PopupMenuPosition.under,
          itemBuilder: (BuildContext context) {
            return items.map((Map item) {
              return PopupMenuItem<String>(
                value: "${item['val']}",
                child: Container(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(item['label']),
                    leading: Icon(item['icon']),
                  ),
                ),
              );
            }).toList();
          },
          icon: const Icon(
            Icons.add,
            size: 30,
          ),
          color: Colors.white,
        ),
      ]);
}
