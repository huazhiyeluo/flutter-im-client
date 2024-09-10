import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class ContactFriendApi {
  static void getContactFriendGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getContactFriendGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void addContactFriendGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.addContactFriendGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void delContactFriendGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.delContactFriendGroup,
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

  static void getContactFriendOne(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getContactFriendOne,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void addContactFriend(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.addContactFriend,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void inviteContactFriend(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.inviteContactFriend,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void delContactFriend(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.delContactFriend,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void actContactFriend(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.actContactFriend,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
