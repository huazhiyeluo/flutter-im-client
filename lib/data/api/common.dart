import 'package:qim/data/api/apis.dart';
import 'package:qim/common/utils/request.dart';

class CommonApi {
  static void upload(params, {Function? onSuccess, Function? onError}) {
    RequestHelper.instance.request(
      Apis.upload,
      data: params,
      onSuccess: onSuccess,
      onError: onError,
      isUpload: true,
    );
  }
}
