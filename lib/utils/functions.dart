import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qim/utils/date.dart';

void logPrint(Object? content, {String filename = "log.txt"}) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$filename';
  var file = File(path);
  // 追加字符串到文件
  await file.writeAsString('${content.toString()}\n', mode: FileMode.append);
  if (kDebugMode) {
    String date = getDate();
    print("QIM[$date]: $content");
  }
}
