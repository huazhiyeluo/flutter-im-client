import 'package:qim/data/api/apis.dart';
import 'package:qim/common/utils/request.dart';

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

  static void delContactGroup(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.delContactGroup,
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

  static void addGroupManger(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.addGroupManger,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void delGroupManger(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.delGroupManger,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
