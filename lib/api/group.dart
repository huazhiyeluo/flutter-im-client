import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class GroupApi {
  static void createGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.createGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void actGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.actGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void searchGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.searchGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
