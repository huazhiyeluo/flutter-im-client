import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/config/constants.dart';
import 'package:qim/data/controller/talk.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const UserInfoPage(),
      backgroundColor: Colors.grey[200],
    );
  }
}

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TalkController talkController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final UserController userController = Get.find();

  final ScreenshotController screenshotController = ScreenshotController();

  int uid = 0;
  Map userInfo = {};

  @override
  void initState() {
    super.initState();
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
  }

  List<Widget> _getTitle() {
    List<Widget> data = [];
    data.add(Text(
      '${userInfo['nickname']}',
      style: const TextStyle(
        fontSize: 24,
      ),
    ));
    data.add(Text('UID: ${userInfo['uid']}'));
    return data;
  }

  Future<void> _saveQrCode() async {
    // 先请求存储权限
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // 截取二维码图片
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        final result = await ImageGallerySaverPlus.saveImage(image, quality: 100, name: "qr_code_${DateTime.now().millisecondsSinceEpoch}");
        if (result["isSuccess"]) {
          TipHelper.instance.showToast("图片保存成功");
        } else {
          TipHelper.instance.showToast("图片保存失败");
        }
      } else {
        TipHelper.instance.showToast("生成图片失败");
      }
    } else {
      TipHelper.instance.showToast("请开启存储权限");
    }
  }

  Future<void> _shareQrCode() async {
    // 先请求存储权限
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // 截取二维码图片
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        final String dir = (await getTemporaryDirectory()).path; // 获取临时目录
        final String filePath = '$dir/temp_image_user_${DateTime.now().millisecondsSinceEpoch}.png'; // 定义临时文件路径
        final File tempFile = File(filePath);
        // 将图像字节写入临时文件
        await tempFile.writeAsBytes(image);
        Map msgObj = {
          'content': {"data": "", "url": filePath, "name": userInfo['nickname']},
          'msgMedia': 2
        };
        Get.toNamed(
          '/share',
          arguments: {"ttype": ShareTypes.complex, "msgObj": msgObj},
        );
      } else {
        TipHelper.instance.showToast("生成图片失败");
      }
    } else {
      TipHelper.instance.showToast("请开启存储权限");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Obx(() {
      Map result = {};
      result['type'] = 1;
      result['content'] = {"uid": userInfo['uid']};

      return Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            color: Colors.white,
            child: Screenshot(
              controller: screenshotController,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(60.0),
                        child: CachedNetworkImage(
                          imageUrl: userInfo['avatar'],
                          width: 60.0,
                          height: 60.0,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _getTitle(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    QrImageView(
                      data: jsonEncode(result),
                      version: QrVersions.auto,
                      size: screenSize.width * 0.75,
                      backgroundColor: Colors.white, // 设置二维码背景色
                      semanticsLabel: userInfo['nickname'],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: Container()),
          const Text("扫一扫二维码，加好友"),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () async {
                  _saveQrCode();
                },
                child: const Column(
                  children: [
                    Icon(
                      Icons.download,
                      size: 40,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("保存"),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _shareQrCode();
                },
                child: const Column(
                  children: [
                    Icon(
                      Icons.share,
                      size: 40,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("分享"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      );
    });
  }
}
