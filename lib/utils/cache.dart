import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class CacheHelper {

  static CacheHelper ? _singleton;

  static final Lock _lock = Lock();

  static SharedPreferences? _prefs;

  static Future<CacheHelper?> getInstance() async {
    if (_singleton == null) {
      await _lock.synchronized(() async {
        if (_singleton == null) {
          // keep local instance till it is fully initialized.
          // 保持本地实例直到完全初始化。
          var singleton = CacheHelper._();
          await singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton;
  }
  // 私有构造函数，禁止外部实例化
  CacheHelper._();

  // 初始化 SharedPreferences
  Future _init()  async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 保存数据
  static Future<bool>? saveData(String key, dynamic value) {
    if (value is String) {
      return _prefs?.setString(key, value);
    } else if (value is int) {
      return _prefs?.setInt(key, value);
    } else if (value is bool) {
      return _prefs?.setBool(key, value);
    } else if (value is double) {
      return _prefs?.setDouble(key, value);
    } else if (value is List<String>) {
      return _prefs?.setStringList(key, value);
    } else {
      // Convert object to JSON string and save
      var jsonString = json.encode(value);
      return _prefs?.setString(key, jsonString);
    }
  }

  static Future<bool>? saveBoolData(String key, bool value) {
    return _prefs?.setBool(key, value);
  }

  // 获取数据
  static String? getStringData(String key, {String? defValue = ''}) {
    return _prefs?.getString(key) ?? defValue;
  }

    /// get bool.
  static bool? getBoolData(String key, {bool? defValue = false}) {
    return _prefs?.getBool(key) ?? defValue;
  }

  static Map? getMapData(String key) {
    String? _data = _prefs?.getString(key);
    return (_data == null || _data.isEmpty) ? null : json.decode(_data);
  }

    /// remove.
  static Future<bool>? remove(String key) {
    return _prefs?.remove(key);
  }

  // 清空数据
  static Future<bool>? clearData() {
    return _prefs?.clear();
  }
}
