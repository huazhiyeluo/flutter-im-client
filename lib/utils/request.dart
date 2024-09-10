import 'dart:math';

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qim/common/apis.dart';
import 'package:qim/utils/device_info.dart';
import 'package:qim/utils/functions.dart';

class RequestHelper {
  late final Dio _dio;

  static final RequestHelper _singleton = RequestHelper._();

  factory RequestHelper() => _singleton;

  static RequestHelper get instance => RequestHelper();

  RequestHelper._() {
    BaseOptions options = BaseOptions(
      baseUrl: Apis.apiPrefix,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
    );
    _dio = Dio(options);
  }

  Future<dynamic> request(
    String endpoint, {
    dynamic data,
    Function? onSuccess,
    Function? onError,
    Map<String, dynamic>? headers,
    String method = 'POST',
    bool isUpload = false, // 新增的参数，用于标识是否是文件上传请求
  }) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        onError?.call({"code": 600, "msg": "网络错误"});
        return;
      }

      Response response;
      final mergedHeaders = headers ?? {'Content-Type': 'application/json'};
      DeviceInfo deviceInfo = await DeviceInfo.getDeviceInfo();
      mergedHeaders['devname'] = deviceInfo.deviceName;
      mergedHeaders['deviceid'] = deviceInfo.deviceId;

      if (isUpload) {
        // 如果是文件上传请求
        FormData formData = FormData.fromMap(data); // 将传入的数据转换为 FormData 对象

        response = await _dio.post(
          endpoint,
          data: formData,
          options: Options(),
        );
      } else {
        logPrint(data);
        // 如果不是文件上传请求
        response = await _dio.request(
          endpoint,
          data: data,
          options: Options(headers: mergedHeaders, method: method),
        );
      }

      if (response.data.containsKey('code') && response.data['code'] == 0) {
        onSuccess?.call(response.data);
      } else {
        onError?.call(response.data);
      }
    } on DioException catch (e) {
      onError?.call({"code": 500, "msg": "${e.message}"});
    }
  }
}
