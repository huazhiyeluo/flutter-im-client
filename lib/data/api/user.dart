import 'package:qim/data/api/apis.dart';
import 'package:qim/common/utils/request.dart';

class UserApi {
  static void getOneUser(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getOneUser,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void actUser(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.actUser,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void searchUser(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.searchUser,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void actDeviceToken(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.actDeviceToken,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
