import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class UserApi {
  static void editUser(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.editUser,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void actUser(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.login,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
