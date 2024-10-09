import 'package:intl/intl.dart';

String formatDate(int timestampSeconds, {String customFormat = "yyyy-MM-dd HH:mm:ss"}) {
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

String getDate({String customFormat = "yyyy-MM-dd HH:mm:ss"}) {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  String formatted = formatter.format(now);
  return formatted;
}

String formatSecondsToHMS(int totalSeconds) {
  Duration duration = Duration(seconds: totalSeconds);

  String hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  String formattedTime = '$hours$minutes:$seconds';

  return formattedTime;
}

String getSpecialDate(int createTime) {
  int nowtime = getTime();
  String today = formatDate(nowtime, customFormat: "yyyy-MM-dd");
  String mDay = formatDate(createTime, customFormat: "yyyy-MM-dd");
  if (today == mDay) {
    return formatDate(createTime, customFormat: "HH:mm");
  } else {
    return formatDate(createTime, customFormat: "MM-dd");
  }
}
