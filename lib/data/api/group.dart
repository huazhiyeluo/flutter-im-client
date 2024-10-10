import 'package:qim/data/api/apis.dart';
import 'package:qim/common/utils/request.dart';

class GroupApi {
  static void getOneGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getOneGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

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
