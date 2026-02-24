import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/account_service.dart';
import 'package:shortzz/common/service/chat/chat_socket_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/auth_screen/login_screen.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class AccountSwitcherSheet extends StatefulWidget {
  const AccountSwitcherSheet({super.key});

  @override
  State<AccountSwitcherSheet> createState() => _AccountSwitcherSheetState();
}

class _AccountSwitcherSheetState extends State<AccountSwitcherSheet> {
  List<AccountSession> sessions = [];
  int? currentUserId;
  bool isSwitching = false;

  @override
  void initState() {
    super.initState();
    sessions = SessionManager.instance.getAccountSessions();
    currentUserId = SessionManager.instance.getUserID();
  }

  Future<void> _switchToAccount(AccountSession session) async {
    if (session.userId == currentUserId || isSwitching) return;

    setState(() => isSwitching = true);

    final result = await AccountService.instance.switchAccount(
      targetUserId: session.userId,
    );

    if (result.status && result.user != null && result.authToken != null) {
      // Disconnect chat socket
      ChatSocketService.instance.disconnect();

      // Delete all GetX controllers
      Get.deleteAll(force: true);

      // Update session
      SessionManager.instance.setUser(result.user);
      SessionManager.instance.setAuthToken(
        Token(authToken: result.authToken),
      );
      SessionManager.instance.setLogin(true);

      // Update local account session with fresh token
      SessionManager.instance.addAccountSession(
        userId: result.user!.id!.toInt(),
        authToken: result.authToken!,
        fullname: result.user!.fullname ?? '',
        username: result.user!.username ?? '',
        profilePhoto: result.user!.profilePhoto,
      );

      // Navigate to dashboard
      Get.offAll(() => DashboardScreen(myUser: result.user));
    } else {
      setState(() => isSwitching = false);
      Get.snackbar('Error', result.message ?? 'Failed to switch account',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _removeAccount(AccountSession session) async {
    if (session.userId == currentUserId) return;

    await AccountService.instance.removeAccountFromDevice(
      targetUserId: session.userId,
    );
    SessionManager.instance.removeAccountSession(session.userId);
    setState(() {
      sessions = SessionManager.instance.getAccountSessions();
    });
  }

  void _addAnotherAccount() {
    Get.back();
    Get.to(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: double.infinity,
          decoration: ShapeDecoration(
            shape: const SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.vertical(
                top: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
              ),
            ),
            color: whitePure(context),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 1,
                      width: 100,
                      color: bgGrey(context),
                      margin: const EdgeInsets.only(top: 10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Switch Account',
                        style: TextStyleCustom.unboundedMedium500(
                          color: textDarkGrey(context),
                          fontSize: 15,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        child: Icon(Icons.close_rounded,
                            color: textDarkGrey(context), size: 25),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isSwitching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CupertinoActivityIndicator()),
                    )
                  else ...[
                    ...sessions.map((session) {
                      final isCurrent = session.userId == currentUserId;
                      return _AccountTile(
                        session: session,
                        isCurrent: isCurrent,
                        onTap: () => _switchToAccount(session),
                        onRemove:
                            isCurrent ? null : () => _removeAccount(session),
                      );
                    }),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _addAnotherAccount,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: textLightGrey(context),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(Icons.add,
                                  color: textDarkGrey(context), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Add another account',
                              style: TextStyleCustom.outFitMedium500(
                                fontSize: 14,
                                color: textDarkGrey(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  final AccountSession session;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _AccountTile({
    required this.session,
    required this.isCurrent,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CustomImage(
              size: const Size(44, 44),
              image: session.profilePhoto?.addBaseURL(),
              fullName: session.fullname,
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
                          session.fullname,
                          style: TextStyleCustom.outFitMedium500(
                            fontSize: 14,
                            color: textDarkGrey(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeAccentSolid(context)
                                .withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Current',
                            style: TextStyleCustom.outFitRegular400(
                              fontSize: 10,
                              color: themeAccentSolid(context),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${session.username}',
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 12,
                      color: textLightGrey(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.close,
                    size: 18, color: textLightGrey(context)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );
  }
}
