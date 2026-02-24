import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/green_screen/green_screen_bg_model.dart';

class GreenScreenService {
  GreenScreenService._();
  static final GreenScreenService instance = GreenScreenService._();

  Future<GreenScreenBgResponse> fetchBackgrounds({
    String? category,
  }) async {
    final param = <String, dynamic>{};
    if (category != null) param['category'] = category;
    return await ApiService.instance.call(
      url: WebService.greenScreen.fetchBackgrounds,
      fromJson: GreenScreenBgResponse.fromJson,
      param: param,
    );
  }
}
