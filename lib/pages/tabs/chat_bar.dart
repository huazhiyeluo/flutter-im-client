import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/utils/cache.dart';

final List<Map<String, dynamic>> items = [
  {"val": 1, "label": "创建群聊", "icon": Icons.wechat},
  {"val": 2, "label": "加好友/群", "icon": Icons.person_add_alt},
  {"val": 3, "label": "扫一扫", "icon": Icons.qr_code},
];

AppBar chatBar() {
  Map? userInfo = CacheHelper.getMapData(Keys.userInfo);
  String username = userInfo == null ? "" : userInfo['username'];
  String avatar = userInfo == null ? "" : userInfo['avatar'];
  return AppBar(
      centerTitle: false,
      title: Row(
        children: [
          CircleAvatar(
            // 聊天对象的头像
            radius: 14,
            backgroundImage: NetworkImage(avatar),
          ),
          const SizedBox(width: 8),
          Text(
            username,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "2") {
              Get.toNamed('/add-contact');
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
          icon: const Icon(Icons.add),
          color: Colors.white,
        ),
      ]);
}
