import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class RegisterApi {
  static void register(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.register,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void bind(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.bind,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
