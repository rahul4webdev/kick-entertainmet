import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/team/shared_access_model.dart';

class TeamService {
  TeamService._();

  static final TeamService instance = TeamService._();

  Future<SharedAccessModel> inviteTeamMember({
    required int memberUserId,
    required int role,
  }) async {
    SharedAccessModel response = await ApiService.instance.call(
      url: WebService.team.invite,
      fromJson: SharedAccessModel.fromJson,
      param: {
        'member_user_id': memberUserId,
        'role': role,
      },
    );
    return response;
  }

  Future<StatusModel> respondToTeamInvite({
    required int accessId,
    required bool accept,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.team.respond,
      fromJson: StatusModel.fromJson,
      param: {
        'access_id': accessId,
        'accept': accept ? 1 : 0,
      },
    );
    return response;
  }

  Future<SharedAccessListModel> fetchMyTeamMembers() async {
    SharedAccessListModel response = await ApiService.instance.call(
      url: WebService.team.fetchMembers,
      fromJson: SharedAccessListModel.fromJson,
    );
    return response;
  }

  Future<SharedAccessListModel> fetchManagedAccounts() async {
    SharedAccessListModel response = await ApiService.instance.call(
      url: WebService.team.fetchManagedAccounts,
      fromJson: SharedAccessListModel.fromJson,
    );
    return response;
  }

  Future<SharedAccessListModel> fetchTeamInvites() async {
    SharedAccessListModel response = await ApiService.instance.call(
      url: WebService.team.fetchInvites,
      fromJson: SharedAccessListModel.fromJson,
    );
    return response;
  }

  Future<SharedAccessModel> updateTeamMember({
    required int accessId,
    int? role,
    Map<String, dynamic>? permissions,
  }) async {
    SharedAccessModel response = await ApiService.instance.call(
      url: WebService.team.updateMember,
      fromJson: SharedAccessModel.fromJson,
      param: {
        'access_id': accessId,
        if (role != null) 'role': role,
        if (permissions != null) 'permissions': permissions,
      },
    );
    return response;
  }

  Future<StatusModel> removeTeamMember({
    required int accessId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.team.removeMember,
      fromJson: StatusModel.fromJson,
      param: {'access_id': accessId},
    );
    return response;
  }

  Future<StatusModel> leaveTeam({
    required int accessId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.team.leave,
      fromJson: StatusModel.fromJson,
      param: {'access_id': accessId},
    );
    return response;
  }
}
