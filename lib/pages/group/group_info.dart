import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/common/utils/tips.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/talkobj.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qim/data/controller/userinfo.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo({super.key});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Map talkObj = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const GroupInfoPage(),
      backgroundColor: Colors.grey[200],
    );
  }
}

class GroupInfoPage extends StatefulWidget {
  const GroupInfoPage({super.key});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final TalkobjController talkobjController = Get.find();
  final UserInfoController userInfoController = Get.find();
  final GroupController groupController = Get.find();

  final UserController userController = Get.find();
  final ScreenshotController screenshotController = ScreenshotController();

  int uid = 0;
  Map userInfo = {};

  Map talkObj = {};
  Map groupObj = {};

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      talkObj = Get.arguments;
    }
    userInfo = userInfoController.userInfo;
    uid = userInfo['uid'];
    _initData();
  }

  void _initData() async {
    await initOneGroup(talkObj['objId']);
  }

  List<Widget> _getTitle() {
    List<Widget> data = [];
    data.add(Text(
      '${groupObj['name']}',
      style: const TextStyle(
        fontSize: 24,
      ),
    ));
    data.add(Text('群号: ${groupObj['groupId']}'));
    return data;
  }

  Future<void> _saveQrCode() async {
    // 先请求存储权限
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // 截取二维码图片
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        final result = await ImageGallerySaverPlus.saveImage(image,
            quality: 100, name: "qr_code_${DateTime.now().millisecondsSinceEpoch}");
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
        final String filePath = '$dir/temp_image_group_${DateTime.now().millisecondsSinceEpoch}.png'; // 定义临时文件路径
        final File tempFile = File(filePath);
        // 将图像字节写入临时文件
        await tempFile.writeAsBytes(image);
        Map msgObj = {
          'content': {"data": "", "url": filePath, "name": groupObj['name']},
          'msgMedia': 2
        };
        Get.toNamed(
          '/share',
          arguments: {"ttype": 2, "msgObj": msgObj},
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
      if (talkObj.isEmpty) {
        return const Center(child: Text(""));
      }
      groupObj = groupController.getOneGroup(talkObj['objId']);
      if (groupObj.isEmpty) {
        return const Center(child: Text(""));
      }
      Map result = {};
      result['type'] = 2;
      result['content'] = {"groupId": talkObj['objId']};

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
                          imageUrl: groupObj['icon'],
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
          const Text("扫一扫二维码，加入群聊"),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () async {
                  // 点击事件的逻辑
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
                  // 点击事件的逻辑
                  print("点击了!");
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
