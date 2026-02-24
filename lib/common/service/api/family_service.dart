import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/family/family_link_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class FamilyService {
  FamilyService._();

  static final FamilyService instance = FamilyService._();

  Future<PairingCodeModel> generatePairingCode() async {
    PairingCodeModel response = await ApiService.instance.call(
      url: WebService.family.generateCode,
      fromJson: PairingCodeModel.fromJson,
    );
    return response;
  }

  Future<FamilyLinkModel> linkWithCode({
    required String pairingCode,
  }) async {
    FamilyLinkModel response = await ApiService.instance.call(
      url: WebService.family.linkWithCode,
      fromJson: FamilyLinkModel.fromJson,
      param: {'pairing_code': pairingCode},
    );
    return response;
  }

  Future<StatusModel> unlinkAccount({
    required int linkId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.family.unlink,
      fromJson: StatusModel.fromJson,
      param: {'link_id': linkId},
    );
    return response;
  }

  Future<FamilyLinkModel> updateControls({
    required int linkId,
    required Map<String, dynamic> controls,
  }) async {
    FamilyLinkModel response = await ApiService.instance.call(
      url: WebService.family.updateControls,
      fromJson: FamilyLinkModel.fromJson,
      param: {
        'link_id': linkId,
        'controls': controls,
      },
    );
    return response;
  }

  Future<FamilyLinkedAccountsModel> fetchLinkedAccounts() async {
    FamilyLinkedAccountsModel response = await ApiService.instance.call(
      url: WebService.family.fetchLinkedAccounts,
      fromJson: FamilyLinkedAccountsModel.fromJson,
    );
    return response;
  }

  Future<MyControlsModel> fetchMyControls() async {
    MyControlsModel response = await ApiService.instance.call(
      url: WebService.family.fetchMyControls,
      fromJson: MyControlsModel.fromJson,
    );
    return response;
  }

  Future<ActivityReportModel> fetchActivityReport({
    required int linkId,
  }) async {
    ActivityReportModel response = await ApiService.instance.call(
      url: WebService.family.fetchActivityReport,
      fromJson: ActivityReportModel.fromJson,
      param: {'link_id': linkId},
    );
    return response;
  }
}
