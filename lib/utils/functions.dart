import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qim/utils/date.dart';

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
    print("Error writing to log file: $e");
  }
}
