import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class ContactApi {
  static void getFriendList(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getFriendList,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getFriendOne(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getFriendOne,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getFriendGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getFriendGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getGroupList(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getGroupList,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getGroupOne(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getGroupOne,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getGroupUser(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getGroupUser,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
