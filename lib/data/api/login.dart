import 'package:qim/data/api/apis.dart';
import 'package:qim/common/utils/request.dart';

class LoginApi {
  static void login(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.login,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void repassword(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.repassword,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
