import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qim/common/apis.dart';

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
  }) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        onError?.call({"code": 600, "msg": "网络错误"});
        return;
      }

      Response response;
      final mergedHeaders = headers ?? {'Content-Type': 'application/json'};

      response = await _dio.request(
        endpoint,
        data: data,
        options: Options(headers: mergedHeaders, method: method),
      );
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
