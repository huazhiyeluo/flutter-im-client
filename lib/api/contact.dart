import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class ContactApi {
  static void actContactFriend(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.actContactFriend,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void actContactGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.actContactGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getContactFriendGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getContactFriendGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getContactFriendList(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getContactFriendList,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getContactGroupList(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getContactGroupList,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getContactGroupUser(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getContactGroupUser,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getApplyList(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getApplyList,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
