import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qim/common/utils/date.dart';
import 'package:uuid/uuid.dart';

Future<void> logPrint(Object? content, {String filename = "log.txt"}) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename';
    var file = File(path);

    // 异步追加字符串到文件
    await file.writeAsString('${content.toString()}\n', mode: FileMode.append);

    if (kDebugMode) {
      String date = getDate();
      print("QIM[$date]: $content");
    }
  } catch (e) {
    // 处理可能的错误
    if (kDebugMode) {
      print("Error writing to log file: $e");
    }
  }
}

String genGUID() {
  var uuid = Uuid();
  // 生成 UUID v4
  String guid = uuid.v4();
  // 去掉所有的 '-'
  return guid.replaceAll("-", "");
}
