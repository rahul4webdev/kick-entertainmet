import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/team/shared_access_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/team_screen/team_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeamController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            CustomAppBar(title: LKey.teamManagement),
            TabBar(
              labelColor: textDarkGrey(context),
              unselectedLabelColor: textLightGrey(context),
              indicatorColor: themeAccentSolid(context),
              labelStyle: TextStyleCustom.outFitMedium500(fontSize: 13),
              unselectedLabelStyle:
                  TextStyleCustom.outFitRegular400(fontSize: 13),
              tabs: [
                Tab(text: LKey.teamMembers),
                Tab(text: LKey.managedAccounts),
                Tab(text: LKey.teamInvites),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MyTeamTab(controller: controller),
                  _ManagedAccountsTab(controller: controller),
                  _InvitesTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── My Team Tab ─────────────────────────────────────────────────

class _MyTeamTab extends StatelessWidget {
  final TeamController controller;

  const _MyTeamTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMembers.value) {
        return const Center(child: LoaderWidget());
      }

      return MyRefreshIndicator(
        onRefresh: controller.fetchMyTeamMembers,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showInviteSheet(context),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: Text(LKey.teamInviteMember),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeAccentSolid(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: controller.teamMembers.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 60),
                        NoDataView(
                          title: LKey.teamNoMembers,
                          description: LKey.teamNoMembersDesc,
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: controller.teamMembers.length,
                      itemBuilder: (context, index) {
                        final member = controller.teamMembers[index];
                        return _TeamMemberCard(
                          access: member,
                          isOwnerView: true,
                          onRoleChanged: (role) {
                            controller.updateMemberRole(member.id!, role);
                          },
                          onRemove: () {
                            controller.removeMember(member.id!);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: scaffoldBackgroundColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _InviteMemberSheet(controller: controller),
    );
  }
}

// ─── Managed Accounts Tab ────────────────────────────────────────

class _ManagedAccountsTab extends StatelessWidget {
  final TeamController controller;

  const _ManagedAccountsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingManaged.value) {
        return const Center(child: LoaderWidget());
      }

      return MyRefreshIndicator(
        onRefresh: controller.fetchManagedAccounts,
        child: controller.managedAccounts.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  NoDataView(
                    title: LKey.teamNoManaged,
                    description: LKey.teamNoManagedDesc,
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.managedAccounts.length,
                itemBuilder: (context, index) {
                  final access = controller.managedAccounts[index];
                  return _ManagedAccountCard(
                    access: access,
                    onLeave: () {
                      controller.leaveTeam(access.id!);
                    },
                  );
                },
              ),
      );
    });
  }
}

// ─── Invites Tab ─────────────────────────────────────────────────

class _InvitesTab extends StatelessWidget {
  final TeamController controller;

  const _InvitesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingInvites.value) {
        return const Center(child: LoaderWidget());
      }

      return MyRefreshIndicator(
        onRefresh: controller.fetchTeamInvites,
        child: controller.pendingInvites.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  NoDataView(
                    title: LKey.teamNoInvites,
                    description: LKey.teamNoInvitesDesc,
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.pendingInvites.length,
                itemBuilder: (context, index) {
                  final invite = controller.pendingInvites[index];
                  return _InviteCard(
                    access: invite,
                    onAccept: () {
                      controller.respondToInvite(invite.id!, true);
                    },
                    onDecline: () {
                      controller.respondToInvite(invite.id!, false);
                    },
                  );
                },
              ),
      );
    });
  }
}

// ─── Team Member Card ────────────────────────────────────────────

class _TeamMemberCard extends StatelessWidget {
  final SharedAccess access;
  final bool isOwnerView;
  final Function(int role)? onRoleChanged;
  final VoidCallback? onRemove;

  const _TeamMemberCard({
    required this.access,
    this.isOwnerView = false,
    this.onRoleChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final user = access.member;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: CustomImage(
              image: user?.profilePhoto ?? '',
              size: const Size(44, 44),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user?.fullname ?? user?.username ?? '',
                        style: TextStyleCustom.outFitMedium500(fontSize: 14)
                            .copyWith(color: textDarkGrey(context)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user?.isVerify == 1) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified, size: 14, color: themeAccentSolid(context)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user?.username ?? ''}',
                  style: TextStyleCustom.outFitRegular400(fontSize: 12)
                      .copyWith(color: textLightGrey(context)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _RoleBadge(role: access.role),
                    if (access.isPending) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Pending',
                          style: TextStyleCustom.outFitRegular400(fontSize: 10)
                              .copyWith(color: Colors.orange),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isOwnerView)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: textLightGrey(context), size: 20),
              onSelected: (value) {
                if (value == 'admin') onRoleChanged?.call(1);
                if (value == 'editor') onRoleChanged?.call(2);
                if (value == 'viewer') onRoleChanged?.call(3);
                if (value == 'remove') onRemove?.call();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'admin', child: Text('Set as Admin')),
                const PopupMenuItem(value: 'editor', child: Text('Set as Editor')),
                const PopupMenuItem(value: 'viewer', child: Text('Set as Viewer')),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'remove',
                  child: Text(LKey.teamRemoveMember,
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Managed Account Card ────────────────────────────────────────

class _ManagedAccountCard extends StatelessWidget {
  final SharedAccess access;
  final VoidCallback onLeave;

  const _ManagedAccountCard({
    required this.access,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final owner = access.accountOwner;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: CustomImage(
              image: owner?.profilePhoto ?? '',
              size: const Size(44, 44),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        owner?.fullname ?? owner?.username ?? '',
                        style: TextStyleCustom.outFitMedium500(fontSize: 14)
                            .copyWith(color: textDarkGrey(context)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (owner?.isVerify == 1) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified, size: 14, color: themeAccentSolid(context)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${owner?.username ?? ''}',
                  style: TextStyleCustom.outFitRegular400(fontSize: 12)
                      .copyWith(color: textLightGrey(context)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _RoleBadge(role: access.role),
                    const SizedBox(width: 6),
                    _PermissionChips(permissions: access.permissions),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onLeave,
            child: Text(
              LKey.teamLeave,
              style: TextStyleCustom.outFitMedium500(fontSize: 12)
                  .copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Invite Card ─────────────────────────────────────────────────

class _InviteCard extends StatelessWidget {
  final SharedAccess access;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _InviteCard({
    required this.access,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final owner = access.accountOwner;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomImage(
                  image: owner?.profilePhoto ?? '',
                  size: const Size(40, 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owner?.fullname ?? owner?.username ?? '',
                      style: TextStyleCustom.outFitMedium500(fontSize: 14)
                          .copyWith(color: textDarkGrey(context)),
                    ),
                    Text(
                      'Invited you as ${access.roleLabel}',
                      style: TextStyleCustom.outFitRegular400(fontSize: 12)
                          .copyWith(color: textLightGrey(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: textLightGrey(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Decline',
                    style: TextStyleCustom.outFitMedium500(fontSize: 13)
                        .copyWith(color: textDarkGrey(context)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeAccentSolid(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Accept',
                    style: TextStyleCustom.outFitMedium500(fontSize: 13)
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Role Badge ──────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final int role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      1 => Colors.purple,
      2 => Colors.blue,
      _ => Colors.grey,
    };
    final label = switch (role) {
      1 => LKey.teamAdmin,
      2 => LKey.teamEditor,
      _ => LKey.teamViewer,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyleCustom.outFitMedium500(fontSize: 10)
            .copyWith(color: color),
      ),
    );
  }
}

// ─── Permission Chips ────────────────────────────────────────────

class _PermissionChips extends StatelessWidget {
  final Map<String, dynamic>? permissions;

  const _PermissionChips({this.permissions});

  @override
  Widget build(BuildContext context) {
    if (permissions == null) return const SizedBox.shrink();

    int activeCount =
        permissions!.values.where((v) => v == true).length;
    int totalCount = permissions!.length;

    return Text(
      '$activeCount/$totalCount permissions',
      style: TextStyleCustom.outFitRegular400(fontSize: 10)
          .copyWith(color: textLightGrey(context)),
    );
  }
}

// ─── Invite Member Sheet ─────────────────────────────────────────

class _InviteMemberSheet extends StatefulWidget {
  final TeamController controller;

  const _InviteMemberSheet({required this.controller});

  @override
  State<_InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<_InviteMemberSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;
  int _selectedRole = 2; // default: editor

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await UserService.instance
          .searchUsers(keyWord: query, limit: 10);
      setState(() => _searchResults = results);
    } catch (_) {}
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textLightGrey(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LKey.teamInviteMember,
                style: TextStyleCustom.outFitMedium500(fontSize: 18)
                    .copyWith(color: textDarkGrey(context)),
              ),
              const SizedBox(height: 12),
              // Role selector
              Text(
                LKey.teamSelectRole,
                style: TextStyleCustom.outFitRegular400(fontSize: 13)
                    .copyWith(color: textLightGrey(context)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RoleChip(
                    label: LKey.teamAdmin,
                    isSelected: _selectedRole == 1,
                    onTap: () => setState(() => _selectedRole = 1),
                  ),
                  const SizedBox(width: 8),
                  _RoleChip(
                    label: LKey.teamEditor,
                    isSelected: _selectedRole == 2,
                    onTap: () => setState(() => _selectedRole = 2),
                  ),
                  const SizedBox(width: 8),
                  _RoleChip(
                    label: LKey.teamViewer,
                    isSelected: _selectedRole == 3,
                    onTap: () => setState(() => _selectedRole = 3),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search
              TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: TextStyleCustom.outFitRegular400(fontSize: 14)
                    .copyWith(color: textDarkGrey(context)),
                decoration: InputDecoration(
                  hintText: 'Search username...',
                  hintStyle: TextStyleCustom.outFitRegular400(fontSize: 14)
                      .copyWith(color: textLightGrey(context)),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: bgMediumGrey(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              if (_isSearching)
                const Center(child: CircularProgressIndicator()),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomImage(
                          image: user.profilePhoto ?? '',
                          size: const Size(40, 40),
                        ),
                      ),
                      title: Text(
                        user.fullname ?? '',
                        style: TextStyleCustom.outFitMedium500(fontSize: 14)
                            .copyWith(color: textDarkGrey(context)),
                      ),
                      subtitle: Text(
                        '@${user.username ?? ''}',
                        style: TextStyleCustom.outFitRegular400(fontSize: 12)
                            .copyWith(color: textLightGrey(context)),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          widget.controller
                              .inviteTeamMember(user.id!, _selectedRole);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeAccentSolid(context),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Invite',
                          style: TextStyleCustom.outFitMedium500(fontSize: 12)
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Role Chip ───────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? themeAccentSolid(context)
              : bgMediumGrey(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyleCustom.outFitMedium500(fontSize: 13).copyWith(
            color: isSelected ? Colors.white : textDarkGrey(context),
          ),
        ),
      ),
    );
  }
}
