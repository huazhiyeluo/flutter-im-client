import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qim/api/common.dart';
import 'package:qim/api/user.dart';
import 'package:qim/common/keys.dart';
import 'package:qim/utils/cache.dart';
import 'package:qim/utils/common.dart';
import 'package:qim/utils/permission.dart';
import 'package:qim/utils/tips.dart';
import 'package:dio/dio.dart' as dio;

class PersonInfo extends StatefulWidget {
  const PersonInfo({super.key});

  @override
  State<PersonInfo> createState() => _PersonInfoState();
}

class _PersonInfoState extends State<PersonInfo> {
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
      body: const PersonInfoPage(),
    );
  }
}

class PersonInfoPage extends StatefulWidget {
  const PersonInfoPage({super.key});

  @override
  State<PersonInfoPage> createState() => _PersonInfoPageState();
}

class _PersonInfoPageState extends State<PersonInfoPage> {
  int uid = 0;
  Map userInfo = {};

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    userInfo = CacheHelper.getMapData(Keys.userInfo)!;
    uid = userInfo['uid'] ?? "";
  }

  @override
  Widget build(BuildContext context) {
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
        onTap: () {},
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
              userInfo['username'],
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {},
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: const Divider(),
      ),
      ListTile(
        leading: const Text(
          "个性签名",
          style: TextStyle(fontSize: 16),
        ),
        subtitle: Text(
          userInfo['info'],
          style: const TextStyle(fontSize: 16),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
        ),
        trailing: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {},
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: const Divider(),
      ),
      const SizedBox(height: 20),
    ]);
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
          userInfo['avatar'] = params['avatar'];
          setState(() {
            userInfo = userInfo;
          });
          CacheHelper.saveData(Keys.userInfo, userInfo);
        }, onError: (res) {
          TipHelper.instance.showToast(res['msg']);
        });
      });
    }
  }
}
