import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qim/utils/functions.dart';
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
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        try {
          Map result = json.decode(scanData.code!);
          // 在这里可以使用 msg 进行后续处理
          if (result.containsKey('type') && result.containsKey('content')) {
            if (result['type'] == 1) {
              Get.toNamed(
                '/add-contact-group-do',
                arguments: result['content'],
              );
            }
            if (result['type'] == 2) {
              Get.toNamed(
                '/add-contact-group-do',
                arguments: result['content'],
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
