import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qim/data/api/common.dart';
import 'package:qim/data/api/user.dart';
import 'package:qim/data/cache/keys.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qim/common/utils/cache.dart';
import 'package:qim/common/utils/common.dart';
import 'package:qim/common/utils/permission.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:dio/dio.dart' as dio;

class UserDetail extends StatefulWidget {
  const UserDetail({super.key});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("个人信息"),
      ),
      body: const UserDetailPage(),
    );
  }
}

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final UserInfoController userInfoController = Get.find();

  final ImagePicker _picker = ImagePicker();

  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      userInfo = userInfoController.userInfo;
      return ListView(children: [
        const SizedBox(height: 20),
        ListTile(
          leading: const Text(
            "头像",
            style: TextStyle(fontSize: 16),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // 必须与 Container 的 borderRadius 相同
                child: Image.network(
                  userInfo['avatar'], // 替换为你的图片URL
                  width: 60.0,
                  height: 60.0,
                  fit: BoxFit.cover,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            _uploadAvatar();
          },
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          leading: const Text(
            "昵称",
            style: TextStyle(fontSize: 16),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userInfo['nickname'],
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/user-nickname',
            );
          },
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        ListTile(
          leading: const Text(
            "用户名",
            style: TextStyle(fontSize: 16),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userInfo['username'] == '' ? '去绑定' : userInfo['username'],
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            userInfo['username'] == ''
                ? Navigator.pushNamed(
                    context,
                    '/user-username-bind',
                  )
                : Navigator.pushNamed(
                    context,
                    '/user-username',
                  );
          },
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 16, 24, 16),
            child: Row(
              children: [
                const Text(
                  "个性签名",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    userInfo['info'],
                    style: const TextStyle(fontSize: 16),
                    maxLines: 10,
                    textAlign: TextAlign.end,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/user-detail-info',
            );
          },
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: const Divider(),
        ),
        const SizedBox(height: 20),
      ]);
    });
  }

  Future<void> _uploadAvatar() async {
    var isGrantedStorage = await PermissionUtil.requestStoragePermission();
    if (!isGrantedStorage) {
      TipHelper.instance.showToast("未允许存储读写权限");
      return;
    }
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      XFile compressedFile = await compressImage(imageFile);
      dio.MultipartFile file = await dio.MultipartFile.fromFile(compressedFile.path);
      CommonApi.upload({'file': file}, onSuccess: (res) {
        var params = {
          'avatar': res['data'],
          'uid': uid,
        };
        UserApi.actUser(params, onSuccess: (res) async {
          userInfoController.setUserInfo({...userInfoController.userInfo, 'avatar': params['avatar']});
          CacheHelper.saveData(Keys.userInfo, userInfoController.userInfo);
        }, onError: (res) {
          TipHelper.instance.showToast(res['msg']);
        });
      });
    }
  }
}
