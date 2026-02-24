import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/team_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/team/shared_access_model.dart';

class TeamController extends BaseController {
  RxList<SharedAccess> teamMembers = <SharedAccess>[].obs;
  RxList<SharedAccess> managedAccounts = <SharedAccess>[].obs;
  RxList<SharedAccess> pendingInvites = <SharedAccess>[].obs;
  RxBool isLoadingMembers = true.obs;
  RxBool isLoadingManaged = false.obs;
  RxBool isLoadingInvites = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyTeamMembers();
    fetchManagedAccounts();
    fetchTeamInvites();
  }

  Future<void> fetchMyTeamMembers() async {
    isLoadingMembers.value = true;
    try {
      final response = await TeamService.instance.fetchMyTeamMembers();
      if (response.status == true && response.data != null) {
        teamMembers.value = response.data!;
      }
    } catch (_) {}
    isLoadingMembers.value = false;
  }

  Future<void> fetchManagedAccounts() async {
    isLoadingManaged.value = true;
    try {
      final response = await TeamService.instance.fetchManagedAccounts();
      if (response.status == true && response.data != null) {
        managedAccounts.value = response.data!;
      }
    } catch (_) {}
    isLoadingManaged.value = false;
  }

  Future<void> fetchTeamInvites() async {
    isLoadingInvites.value = true;
    try {
      final response = await TeamService.instance.fetchTeamInvites();
      if (response.status == true && response.data != null) {
        pendingInvites.value = response.data!;
      }
    } catch (_) {}
    isLoadingInvites.value = false;
  }

  Future<void> inviteTeamMember(int userId, int role) async {
    showLoader();
    try {
      final response = await TeamService.instance.inviteTeamMember(
        memberUserId: userId,
        role: role,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.teamMemberInvited);
        fetchMyTeamMembers();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> respondToInvite(int accessId, bool accept) async {
    showLoader();
    try {
      final response = await TeamService.instance.respondToTeamInvite(
        accessId: accessId,
        accept: accept,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(accept ? LKey.teamInviteAccepted : LKey.teamInviteDeclined);
        pendingInvites.removeWhere((i) => i.id == accessId);
        if (accept) fetchManagedAccounts();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> updateMemberRole(int accessId, int newRole) async {
    showLoader();
    try {
      final response = await TeamService.instance.updateTeamMember(
        accessId: accessId,
        role: newRole,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.teamMemberUpdated);
        fetchMyTeamMembers();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> removeMember(int accessId) async {
    showLoader();
    try {
      final response = await TeamService.instance.removeTeamMember(
        accessId: accessId,
      );
      stopLoader();
      if (response.status == true) {
        teamMembers.removeWhere((m) => m.id == accessId);
        showSnackBar(LKey.teamMemberRemoved);
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> leaveTeam(int accessId) async {
    showLoader();
    try {
      final response = await TeamService.instance.leaveTeam(
        accessId: accessId,
      );
      stopLoader();
      if (response.status == true) {
        managedAccounts.removeWhere((a) => a.id == accessId);
        showSnackBar(LKey.teamLeft);
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }
}
