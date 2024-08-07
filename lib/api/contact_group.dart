import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class ContactGroupApi {
  static void getContactGroupList(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getContactGroupList,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void getContactGroupOne(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getContactGroupOne,
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

  static void joinContactGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.joinContactGroup,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void quitContactGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.quitContactGroup,
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
}
