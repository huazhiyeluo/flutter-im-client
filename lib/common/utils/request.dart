import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qim/common/utils/cache.dart';
import 'package:qim/config/urls.dart';
import 'package:qim/common/utils/device_info.dart';
import 'package:qim/common/utils/functions.dart';
import 'package:qim/data/cache/keys.dart';

class RequestHelper {
  late final Dio _dio;

  static final RequestHelper _singleton = RequestHelper._();

  factory RequestHelper() => _singleton;

  static RequestHelper get instance => RequestHelper();

  RequestHelper._() {
    BaseOptions options = BaseOptions(
      baseUrl: Urls.apiPrefix,
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
      final List<ConnectivityResult> result = await Connectivity().checkConnectivity();
      if (result.isEmpty) {
        onError?.call({"code": 600, "msg": "网络错误"});
        return;
      }

      Response response;
      final mergedHeaders = headers ?? {'Content-Type': 'application/json'};
      DeviceInfo deviceInfo = await DeviceInfo.getDeviceInfo();
      mergedHeaders['devname'] = deviceInfo.deviceName;
      mergedHeaders['deviceid'] = deviceInfo.deviceId;
      mergedHeaders['token'] = CacheHelper.getStringData(Keys.token);

      if (isUpload) {
        FormData formData = FormData.fromMap(data); // 将传入的数据转换为 FormData 对象
        response = await _dio.post(
          endpoint,
          data: formData,
          options: Options(),
        );
      } else {
        logPrint("send-headers:$mergedHeaders | send-data:$data");
        response = await _dio.request(
          endpoint,
          data: data,
          options: Options(headers: mergedHeaders, method: method),
        );
      }

      if (response.data.containsKey('code') && response.data['code'] == 0) {
        logPrint("response-onSuccess: $response");
        onSuccess?.call(response.data);
      } else {
        logPrint("response-onError: $response");
        onError?.call(response.data);
      }
    } on DioException catch (e) {
      onError?.call({"code": 500, "msg": "${e.message}"});
    }
  }
}
