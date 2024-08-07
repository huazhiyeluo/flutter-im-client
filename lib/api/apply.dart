import 'package:qim/common/apis.dart';
import 'package:qim/utils/request.dart';

class ApplyApi {
  static void getApplyList(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.getApplyList,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  static void operateApply(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.operateApply,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}
