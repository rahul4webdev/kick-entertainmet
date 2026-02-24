import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';

class ComplianceService {
  static final instance = ComplianceService();

  // Grievance
  Future<Map<String, dynamic>> submitGrievance({
    required String category,
    required String subject,
    required String description,
  }) async {
    return await ApiService.instance.call(
      url: WebService.grievance.submit,
      param: {
        Params.grievanceCategory: category,
        Params.subject: subject,
        Params.description: description,
      },
      fromJson: (json) => json,
    );
  }

  Future<Map<String, dynamic>> fetchGrievances() async {
    return await ApiService.instance.call(
      url: WebService.grievance.list,
      param: {},
      fromJson: (json) => json,
    );
  }

  Future<Map<String, dynamic>> fetchGrievanceDetail(int id) async {
    return await ApiService.instance.call(
      url: WebService.grievance.detail,
      param: {'id': id},
      fromJson: (json) => json,
    );
  }

  Future<Map<String, dynamic>> addGrievanceResponse({
    required int grievanceId,
    required String message,
  }) async {
    return await ApiService.instance.call(
      url: WebService.grievance.respond,
      param: {
        Params.grievanceId: grievanceId,
        'message': message,
      },
      fromJson: (json) => json,
    );
  }

  Future<Map<String, dynamic>> fetchGROInfo() async {
    return await ApiService.instance.call(
      url: WebService.grievance.groInfo,
      param: {},
      fromJson: (json) => json,
    );
  }

  // Appeals
  Future<Map<String, dynamic>> submitAppeal({
    required String appealType,
    required String reason,
    int? referenceId,
    String? additionalContext,
  }) async {
    final params = <String, dynamic>{
      Params.appealType: appealType,
      Params.reason: reason,
    };
    if (referenceId != null) params[Params.referenceId] = referenceId;
    if (additionalContext != null) params[Params.additionalContext] = additionalContext;

    return await ApiService.instance.call(
      url: WebService.appeal.submit,
      param: params,
      fromJson: (json) => json,
    );
  }

  Future<Map<String, dynamic>> fetchAppeals() async {
    return await ApiService.instance.call(
      url: WebService.appeal.list,
      param: {},
      fromJson: (json) => json,
    );
  }

  Future<Map<String, dynamic>> fetchAppealDetail(int id) async {
    return await ApiService.instance.call(
      url: WebService.appeal.detail,
      param: {'id': id},
      fromJson: (json) => json,
    );
  }
}
