import 'package:intl/intl.dart';

String formatDate(int timestampSeconds,
    {String customFormat = "yyyy-MM-dd HH:mm:ss"}) {
  if (timestampSeconds == 0) {
    return "";
  }

  // 将时间戳（秒数）转换为DateTime对象
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000);

  // 使用自定义格式化字符串格式化日期时间
  String formattedDate = DateFormat(customFormat).format(date);

  // 打印自定义格式的日期时间
  return formattedDate;
}

int getTime() {
  int timestampSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return timestampSeconds;
}
