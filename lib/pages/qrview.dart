import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/common/utils/data.dart';
import 'package:qim/data/controller/group.dart';
import 'package:qim/data/controller/user.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrView extends StatefulWidget {
  const QrView({super.key});

  @override
  State<QrView> createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        try {
          Map result = json.decode(scanData.code!);
          // 在这里可以使用 msg 进行后续处理
          if (result.containsKey('type') && result.containsKey('content')) {
            if (result['type'] == 1) {
              initOneUser(result['content']['uid']);
              final UserController userController = Get.find();
              Map userObj = userController.getOneUser(result['content']['uid']);
              Get.toNamed(
                '/add-contact-friend-do',
                arguments: userObj,
              );
            }
            if (result['type'] == 2) {
              initOneGroup(result['content']['groupId']);
              final GroupController groupController = Get.find();
              Map groupObj = groupController.getOneGroup(result['content']['groupId']);
              Get.toNamed(
                '/add-contact-group-do',
                arguments: groupObj,
              );
            }
          } else {
            setState(() {
              qrText = scanData.code;
            });
          }
        } catch (e) {
          setState(() {
            qrText = scanData.code;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二维码扫描'),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(qrText != null ? '未识别结果: $qrText' : ''),
              ),
            )
          ],
        ),
      ),
    );
  }
}
