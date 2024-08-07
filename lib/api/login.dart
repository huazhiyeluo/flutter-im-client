import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class LoginApi {
  static void login(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.login,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
