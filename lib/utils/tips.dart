import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TipHelper {
  static final TipHelper _singleton = TipHelper._();

  factory TipHelper() => _singleton;

  static TipHelper get instance => TipHelper();

  // 私有构造函数，禁止外部实例化
  TipHelper._() {
    _init();
  }

  // 初始化 SharedPreferences
  Future<void> _init() async {}

  // 保存数据
  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
