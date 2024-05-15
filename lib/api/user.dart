import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class UserApi {
  static void login(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.login,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void register(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.register,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
