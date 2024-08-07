import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class GroupApi {
  static void editGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.editGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void actGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.login,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
