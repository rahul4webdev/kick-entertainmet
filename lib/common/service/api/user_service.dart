import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/controller/firebase_firestore_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/hidden_words_model.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/user_model/block_user_model.dart';
import 'package:shortzz/model/user_model/muted_user_model.dart';
import 'package:shortzz/model/user_model/restricted_user_model.dart';
import 'package:shortzz/model/user_model/favorite_user_model.dart';
import 'package:shortzz/model/user_model/follower_model.dart';
import 'package:shortzz/model/user_model/following_model.dart';
import 'package:shortzz/model/user_model/links_model.dart';
import 'package:shortzz/model/user_model/follow_request_model.dart';
import 'package:shortzz/model/user_model/interest_model.dart';
import 'package:shortzz/model/user_model/profile_category_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/model/user_model/users_model.dart';
import 'package:shortzz/screen/edit_profile_screen/widget/add_edit_link_sheet.dart';
import 'package:shortzz/utilities/app_res.dart';

class LoginResult {
  final User? user;
  final bool requireTotp;
  final String? temp2faToken;

  LoginResult({this.user, this.requireTotp = false, this.temp2faToken});
}

enum LoginMethod {
  email,
  google,
  apple;

  String title() {
    switch (this) {
      case LoginMethod.email:
        return 'email';
      case LoginMethod.google:
        return 'google';
      case LoginMethod.apple:
        return 'apple';
    }
  }
}

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  Future<LoginResult> logInUser({
    String? fullName,
    required String identity,
    String? deviceToken,
    required LoginMethod loginMethod,
  }) async {
    Map<String, dynamic> rawJson = await ApiService.instance.call(
        url: WebService.user.loginInUser,
        param: {
          Params.fullname: fullName,
          Params.identity: identity,
          Params.deviceToken: deviceToken,
          Params.device: Platform.isAndroid ? 0 : 1,
          Params.loginMethod: loginMethod.title(),
          Params.deviceId: SessionManager.instance.getDeviceId(),
        },
        fromJson: (json) => json);

    // Check for 2FA requirement
    final data = rawJson['data'];
    if (data is Map<String, dynamic> && data['require_totp'] == true) {
      return LoginResult(
        requireTotp: true,
        temp2faToken: data['temp_2fa_token'],
      );
    }

    UserModel model = UserModel.fromJson(rawJson);
    if (model.status == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        SessionManager.instance.setUser(model.data);
        SessionManager.instance.setAuthToken(model.data?.token);
      });
    }
    return LoginResult(user: model.data);
  }

  Future<LoginResult> logInFakeUser({
    required String identity,
    required String? password,
    String? deviceToken,
    required LoginMethod loginMethod,
  }) async {
    Map<String, dynamic> rawJson = await ApiService.instance.call(
        url: WebService.user.logInFakeUser,
        param: {
          Params.identity: identity,
          Params.password: password,
          Params.deviceToken: deviceToken,
          Params.device: Platform.isAndroid ? 0 : 1,
          Params.loginMethod: loginMethod.title(),
          Params.deviceId: SessionManager.instance.getDeviceId(),
        },
        fromJson: (json) => json);

    // Check for 2FA requirement
    final data = rawJson['data'];
    if (data is Map<String, dynamic> && data['require_totp'] == true) {
      return LoginResult(
        requireTotp: true,
        temp2faToken: data['temp_2fa_token'],
      );
    }

    UserModel model = UserModel.fromJson(rawJson);
    if (model.status == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        SessionManager.instance.setUser(model.data);
        SessionManager.instance.setAuthToken(model.data?.token);
      });
    } else {
      BaseController.share.stopLoader();
      BaseController.share.showSnackBar(model.message);
    }
    return LoginResult(user: model.data);
  }

  // ===================== CUSTOM AUTH METHODS =====================

  /// Register with email and password (custom auth).
  Future<Map<String, dynamic>> registerWithEmail({
    required String fullname,
    required String email,
    required String password,
    required String dateOfBirth,
    String? deviceToken,
  }) async {
    Map<String, dynamic> rawJson = await ApiService.instance.call(
      url: WebService.user.registerUser,
      param: {
        Params.fullname: fullname,
        Params.email: email,
        Params.password: password,
        Params.dateOfBirth: dateOfBirth,
        Params.termsAccepted: '1',
        Params.deviceToken: deviceToken,
        Params.device: Platform.isAndroid ? 0 : 1,
        Params.deviceId: SessionManager.instance.getDeviceId(),
      },
      fromJson: (json) => json,
    );

    final data = rawJson['data'];

    // Check if email verification is required
    if (data is Map<String, dynamic> &&
        data['require_email_verification'] == true) {
      return {
        'requireEmailVerification': true,
        'userId': data['user_id'],
        'email': data['email'],
      };
    }

    // Check for 2FA requirement
    if (data is Map<String, dynamic> && data['require_totp'] == true) {
      return {
        'requireTotp': true,
        'temp2faToken': data['temp_2fa_token'],
      };
    }

    UserModel model = UserModel.fromJson(rawJson);
    if (model.status == true) {
      SessionManager.instance.setUser(model.data);
      SessionManager.instance.setAuthToken(model.data?.token);
      return {'user': model.data};
    } else {
      return {'error': model.message ?? 'Registration failed'};
    }
  }

  /// Login with email and password (custom auth).
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
    String? deviceToken,
  }) async {
    Map<String, dynamic> rawJson = await ApiService.instance.call(
      url: WebService.user.loginWithEmail,
      param: {
        Params.email: email,
        Params.password: password,
        Params.deviceToken: deviceToken,
        Params.device: Platform.isAndroid ? 0 : 1,
        Params.deviceId: SessionManager.instance.getDeviceId(),
      },
      fromJson: (json) => json,
    );

    final data = rawJson['data'];

    // Check if email verification is required
    if (data is Map<String, dynamic> &&
        data['require_email_verification'] == true) {
      return {
        'requireEmailVerification': true,
        'userId': data['user_id'],
        'email': data['email'],
      };
    }

    // Check for 2FA requirement
    if (data is Map<String, dynamic> && data['require_totp'] == true) {
      return {
        'requireTotp': true,
        'temp2faToken': data['temp_2fa_token'],
        'userId': data['user_id'],
      };
    }

    UserModel model = UserModel.fromJson(rawJson);
    if (model.status == true) {
      SessionManager.instance.setUser(model.data);
      SessionManager.instance.setAuthToken(model.data?.token);
      return {'user': model.data};
    } else {
      return {'error': rawJson['message'] ?? 'Login failed'};
    }
  }

  /// Login with Google ID token (custom auth).
  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
    String? deviceToken,
  }) async {
    Map<String, dynamic> rawJson = await ApiService.instance.call(
      url: WebService.user.loginWithGoogle,
      param: {
        Params.idToken: idToken,
        Params.deviceToken: deviceToken,
        Params.device: Platform.isAndroid ? 0 : 1,
        Params.deviceId: SessionManager.instance.getDeviceId(),
      },
      fromJson: (json) => json,
    );

    final data = rawJson['data'];

    // Check for 2FA requirement
    if (data is Map<String, dynamic> && data['require_totp'] == true) {
      return {
        'requireTotp': true,
        'temp2faToken': data['temp_2fa_token'],
        'userId': data['user_id'],
      };
    }

    UserModel model = UserModel.fromJson(rawJson);
    if (model.status == true) {
      SessionManager.instance.setUser(model.data);
      SessionManager.instance.setAuthToken(model.data?.token);
      return {'user': model.data, 'newRegister': model.data?.newRegister};
    } else {
      return {'error': rawJson['message'] ?? 'Google login failed'};
    }
  }

  /// Login with Apple identity token (custom auth).
  Future<Map<String, dynamic>> loginWithApple({
    required String identityToken,
    required String authorizationCode,
    String? fullname,
    String? deviceToken,
  }) async {
    Map<String, dynamic> rawJson = await ApiService.instance.call(
      url: WebService.user.loginWithApple,
      param: {
        Params.identityToken: identityToken,
        Params.authorizationCode: authorizationCode,
        if (fullname != null) Params.fullname: fullname,
        Params.deviceToken: deviceToken,
        Params.device: Platform.isAndroid ? 0 : 1,
        Params.deviceId: SessionManager.instance.getDeviceId(),
      },
      fromJson: (json) => json,
    );

    final data = rawJson['data'];

    // Check for 2FA requirement
    if (data is Map<String, dynamic> && data['require_totp'] == true) {
      return {
        'requireTotp': true,
        'temp2faToken': data['temp_2fa_token'],
        'userId': data['user_id'],
      };
    }

    UserModel model = UserModel.fromJson(rawJson);
    if (model.status == true) {
      SessionManager.instance.setUser(model.data);
      SessionManager.instance.setAuthToken(model.data?.token);
      return {'user': model.data, 'newRegister': model.data?.newRegister};
    } else {
      return {'error': rawJson['message'] ?? 'Apple login failed'};
    }
  }

  /// Verify email with OTP code.
  Future<Map<String, dynamic>> verifyEmail({
    required int userId,
    required String code,
    String? deviceToken,
  }) async {
    Map<String, dynamic> rawJson = await ApiService.instance.call(
      url: WebService.user.verifyEmail,
      param: {
        Params.userId: userId,
        Params.code: code,
        Params.deviceToken: deviceToken,
        Params.device: Platform.isAndroid ? 0 : 1,
      },
      fromJson: (json) => json,
    );

    final data = rawJson['data'];

    // Check for 2FA requirement
    if (data is Map<String, dynamic> && data['require_totp'] == true) {
      return {
        'requireTotp': true,
        'temp2faToken': data['temp_2fa_token'],
        'userId': data['user_id'],
      };
    }

    UserModel model = UserModel.fromJson(rawJson);
    if (model.status == true) {
      SessionManager.instance.setUser(model.data);
      SessionManager.instance.setAuthToken(model.data?.token);
      return {'user': model.data};
    } else {
      return {'error': rawJson['message'] ?? 'Verification failed'};
    }
  }

  /// Resend email verification code.
  Future<StatusModel> resendVerificationCode({required int userId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.user.resendVerificationCode,
      param: {Params.userId: userId},
      fromJson: StatusModel.fromJson,
    );
    return response;
  }

  /// Request password reset (sends OTP to email).
  Future<StatusModel> forgotPassword({required String email}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.user.forgotPassword,
      param: {Params.email: email},
      fromJson: StatusModel.fromJson,
    );
    return response;
  }

  /// Verify password reset code.
  Future<StatusModel> verifyResetCode({
    required String email,
    required String code,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.user.verifyResetCode,
      param: {
        Params.email: email,
        Params.code: code,
      },
      fromJson: StatusModel.fromJson,
    );
    return response;
  }

  /// Reset password with verified code.
  Future<StatusModel> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.user.resetPassword,
      param: {
        Params.email: email,
        Params.code: code,
        Params.newPassword: newPassword,
      },
      fromJson: StatusModel.fromJson,
    );
    return response;
  }

  // ===================== END CUSTOM AUTH METHODS =====================

  Future<StatusModel> deleteMyAccount() async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.user.deleteMyAccount, fromJson: StatusModel.fromJson);
    return response;
  }

  Future<StatusModel> logoutUser() async {
    StatusModel response = await ApiService.instance
        .call(url: WebService.user.logOutUser, fromJson: StatusModel.fromJson);
    return response;
  }

  Future<User?> fetchUserDetails({int? userId, Function()? onError}) async {
    UserModel userModel = await ApiService.instance.call(
        url: WebService.user.fetchUserDetails,
        param: {Params.userId: userId ?? SessionManager.instance.getUserID()},
        fromJson: UserModel.fromJson,
        onError: onError);
    if (userModel.status == true &&
        userId == SessionManager.instance.getUserID()) {
      SessionManager.instance.setUser(userModel.data);
    }
    return userModel.data;
  }

  Future<User?> updateUserDetails(
      {XFile? profilePhoto,
      String? fullname,
      String? userName,
      String? bio,
      String? email,
      String? phoneNumber,
      int? mobileCountryCode,
      String? countryCode,
      String? country,
      String? appLanguage,
      bool? showMyFollowing,
      bool? receiveMessage,
      bool? notifyPostLike,
      bool? notifyPostComment,
      bool? notifyFollow,
      bool? notifyMention,
      bool? notifyGiftReceived,
      bool? notifyChat,
      List<int>? savedMusicIds,
      double? lat,
      double? lon,
      String? whoCanSeePost,
      String? appLastUsed,
      String? region,
      String? regionName,
      String? timezone,
      int? isVerify,
      bool? isPrivate,
      bool? hideOthersLikeCount,
      bool? commentApprovalEnabled,
      bool? quietModeEnabled,
      String? quietModeUntil,
      String? quietModeAutoReply,
      int? sensitiveContentLevel,
      String? pronouns,
      String? interestIds}) async {
    UserModel userModel = await ApiService.instance.multiPartCallApi(
        url: WebService.user.updateUserDetails,
        filesMap: {
          Params.profilePhoto: [profilePhoto]
        },
        param: {
          Params.fullname: fullname,
          Params.username: userName,
          Params.bio: bio,
          Params.userEmail: email,
          Params.userMobileNo: phoneNumber,
          Params.country: country,
          Params.countryCode: countryCode,
          Params.whoCanViewPost: whoCanSeePost,
          Params.mobileCountryCode: mobileCountryCode,
          if (isVerify != null) Params.isVerify: isVerify,
          if (receiveMessage != null)
            Params.receiveMessage: receiveMessage ? 1 : 0,
          if (showMyFollowing != null)
            Params.showMyFollowing: showMyFollowing ? 1 : 0,
          if (notifyPostLike != null)
            Params.notifyPostLike: notifyPostLike ? 1 : 0,
          if (notifyPostComment != null)
            Params.notifyPostComment: notifyPostComment ? 1 : 0,
          if (notifyFollow != null) Params.notifyFollow: notifyFollow ? 1 : 0,
          if (notifyMention != null)
            Params.notifyMention: notifyMention ? 1 : 0,
          if (notifyGiftReceived != null)
            Params.notifyGiftReceived: notifyGiftReceived ? 1 : 0,
          if (notifyChat != null) Params.notifyChat: notifyChat ? 1 : 0,
          if (savedMusicIds != null)
            Params.savedMusicIds: savedMusicIds.join(','),
          if (appLanguage != null) Params.appLanguage: appLanguage,
          if (lat != null) Params.lat: lat,
          if (lon != null) Params.lon: lon,
          if (appLastUsed != null) Params.appLastUsedAt: appLastUsed,
          if (region != null) Params.region: region,
          if (regionName != null) Params.regionName: regionName,
          if (timezone != null) Params.timezone: timezone,
          if (isPrivate != null) Params.isPrivate: isPrivate ? 1 : 0,
          if (hideOthersLikeCount != null)
            'hide_others_like_count': hideOthersLikeCount ? 1 : 0,
          if (commentApprovalEnabled != null)
            'comment_approval_enabled': commentApprovalEnabled ? 1 : 0,
          if (quietModeEnabled != null)
            'quiet_mode_enabled': quietModeEnabled ? 1 : 0,
          if (quietModeUntil != null) 'quiet_mode_until': quietModeUntil,
          if (quietModeAutoReply != null)
            'quiet_mode_auto_reply': quietModeAutoReply,
          if (sensitiveContentLevel != null)
            'sensitive_content_level': sensitiveContentLevel,
          if (pronouns != null) 'pronouns': pronouns,
          if (interestIds != null) Params.interestIds: interestIds,
        },
        fromJson: UserModel.fromJson);
    if (userModel.status == true) {
      SessionManager.instance.setUser(userModel.data);
      FirebaseFirestoreController.instance.updateUser(userModel.data);
    }
    return userModel.data;
  }

  Future<StatusModel> checkUsernameAvailability(
      {required String userName}) async {
    return await ApiService.instance.call(
        url: WebService.user.checkUsernameAvailability,
        param: {Params.username: userName},
        fromJson: StatusModel.fromJson);
  }

  Future<LinksModel> addEditDeleteUserLink(
      {String? title,
      String? urlLink,
      int? linkId,
      required LinkType linkType}) async {
    String url;

    switch (linkType) {
      case LinkType.add:
        url = WebService.user.addUserLink;
      case LinkType.edit:
        url = WebService.user.editeUserLink;
      case LinkType.delete:
        url = WebService.user.deleteUserLink;
    }

    LinksModel model = await ApiService.instance.call(
        url: url,
        fromJson: LinksModel.fromJson,
        param: {
          Params.linkId: linkId,
          Params.title: title,
          Params.url: urlLink
        });
    return model;
  }

  Future<List<User>> searchUsers(
      {int? lastItemId, String keyWord = '', required int limit}) async {
    UsersModel model = await ApiService.instance.call(
        url: WebService.user.searchUsers,
        param: {
          if (lastItemId != null) Params.lastItemId: lastItemId,
          Params.limit: limit,
          if (keyWord.isNotEmpty) Params.keyword: keyWord,
        },
        fromJson: UsersModel.fromJson);
    return model.data ?? [];
  }

  Future<List<Follower>> fetchMyFollowers(
      {required int lastItemId, required int? userId}) async {
    bool isMe = userId == SessionManager.instance.getUserID();
    String url = isMe
        ? WebService.user.fetchMyFollowers
        : WebService.user.fetchUserFollowers;

    FollowerModel model = await ApiService.instance.call(
        url: url,
        param: {
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != -1) Params.lastItemId: lastItemId,
          if (!isMe) Params.userId: userId,
        },
        fromJson: FollowerModel.fromJson);
    return model.data ?? [];
  }

  Future<List<Following>> fetchMyFollowing(
      {required int lastItemId, required int? userId}) async {
    bool isMe = userId == SessionManager.instance.getUserID();
    String url = isMe
        ? WebService.user.fetchMyFollowings
        : WebService.user.fetchUserFollowings;

    FollowingModel model = await ApiService.instance.call(
        url: url,
        param: {
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != -1) Params.lastItemId: lastItemId,
          if (!isMe) Params.userId: userId,
        },
        fromJson: FollowingModel.fromJson);
    return model.data ?? [];
  }

  Future<StatusModel> followUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
      url: WebService.user.followUser,
      param: {Params.userId: userId},
      fromJson: StatusModel.fromJson,
    );
    return model;
  }

  Future<StatusModel> unFollowUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
      url: WebService.user.unFollowUser,
      param: {Params.userId: userId},
      fromJson: StatusModel.fromJson,
    );
    return model;
  }

  Future<StatusModel> unBlockUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.unBlockUser,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);

    return model;
  }

  Future<StatusModel> blockUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.blockUser,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> reportPost(
      {required int userId,
      required String reason,
      required String description}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.reportUser,
        param: {
          Params.userId: userId,
          Params.reason: reason,
          Params.description: description,
        },
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<BlockUsers>> fetchMyBlockedUsers() async {
    BlockUserModel response = await ApiService.instance.call(
      url: WebService.user.fetchMyBlockedUsers,
      fromJson: BlockUserModel.fromJson,
    );
    return response.data ?? [];
  }

  Future<void> updateLastUsedAt() async {
    await ApiService.instance.call(url: WebService.user.updateLastUsedAt);
  }

  // Mute
  Future<StatusModel> muteUser({
    required int userId,
    bool mutePosts = true,
    bool muteStories = true,
  }) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.muteUser,
        param: {
          Params.userId: userId,
          'mute_posts': mutePosts,
          'mute_stories': muteStories,
        },
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> unMuteUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.unMuteUser,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<MutedUsers>> fetchMyMutedUsers() async {
    MutedUsersModel response = await ApiService.instance.call(
      url: WebService.user.fetchMyMutedUsers,
      fromJson: MutedUsersModel.fromJson,
    );
    return response.data ?? [];
  }

  // Restrict
  Future<StatusModel> restrictUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.restrictUser,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> unrestrictUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.unrestrictUser,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<RestrictedUsers>> fetchMyRestrictedUsers() async {
    RestrictedUsersModel response = await ApiService.instance.call(
      url: WebService.user.fetchMyRestrictedUsers,
      fromJson: RestrictedUsersModel.fromJson,
    );
    return response.data ?? [];
  }

  Future<StatusModel> addToFavorites({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.addToFavorites,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> removeFromFavorites({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.removeFromFavorites,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<FavoriteUser>> fetchMyFavorites() async {
    FavoriteUsersModel response = await ApiService.instance.call(
      url: WebService.user.fetchMyFavorites,
      fromJson: FavoriteUsersModel.fromJson,
    );
    return response.data ?? [];
  }

  // Close Friends (reuses FavoriteUser model — same structure)
  Future<StatusModel> addCloseFriend({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.addCloseFriend,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> removeCloseFriend({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.removeCloseFriend,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<FavoriteUser>> fetchMyCloseFriends() async {
    FavoriteUsersModel response = await ApiService.instance.call(
      url: WebService.user.fetchMyCloseFriends,
      fromJson: FavoriteUsersModel.fromJson,
    );
    return response.data ?? [];
  }

  Future<StatusModel> addHiddenWord({required String word}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.addHiddenWord,
        param: {'word': word},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> removeHiddenWord({required String word}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.removeHiddenWord,
        param: {'word': word},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<String>> fetchHiddenWords() async {
    HiddenWordsModel response = await ApiService.instance.call(
      url: WebService.user.fetchHiddenWords,
      fromJson: HiddenWordsModel.fromJson,
    );
    return response.data ?? [];
  }

  // Follow Requests
  Future<List<FollowRequest>> fetchFollowRequests({int? lastItemId}) async {
    FollowRequestListModel model = await ApiService.instance.call(
        url: WebService.user.fetchFollowRequests,
        param: {
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != null) Params.lastItemId: lastItemId,
        },
        fromJson: FollowRequestListModel.fromJson);
    return model.data ?? [];
  }

  Future<StatusModel> acceptFollowRequest({required int requestId}) async {
    return await ApiService.instance.call(
        url: WebService.user.acceptFollowRequest,
        param: {Params.requestId: requestId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> rejectFollowRequest({required int requestId}) async {
    return await ApiService.instance.call(
        url: WebService.user.rejectFollowRequest,
        param: {Params.requestId: requestId},
        fromJson: StatusModel.fromJson);
  }

  // Business Account
  Future<List<ProfileCategory>> fetchProfileCategories(
      {required int accountType}) async {
    ProfileCategoryListModel model = await ApiService.instance.call(
        url: WebService.business.fetchProfileCategories,
        param: {Params.accountType: accountType},
        fromJson: ProfileCategoryListModel.fromJson);
    return model.data ?? [];
  }

  Future<List<ProfileSubCategory>> fetchProfileSubCategories(
      {required int categoryId}) async {
    ProfileSubCategoryListModel model = await ApiService.instance.call(
        url: WebService.business.fetchProfileSubCategories,
        param: {Params.categoryId: categoryId},
        fromJson: ProfileSubCategoryListModel.fromJson);
    return model.data ?? [];
  }

  Future<StatusModel> convertToBusinessAccount({
    required int accountType,
    required int profileCategoryId,
    int? profileSubCategoryId,
  }) async {
    return await ApiService.instance.call(
        url: WebService.business.convertToBusinessAccount,
        param: {
          Params.accountType: accountType,
          Params.profileCategoryId: profileCategoryId,
          if (profileSubCategoryId != null)
            Params.profileSubCategoryId: profileSubCategoryId,
        },
        fromJson: StatusModel.fromJson);
  }

  Future<UserModel> fetchMyBusinessStatus() async {
    return await ApiService.instance.call(
        url: WebService.business.fetchMyBusinessStatus,
        fromJson: UserModel.fromJson);
  }

  Future<StatusModel> revertToPersonalAccount() async {
    return await ApiService.instance.call(
        url: WebService.business.revertToPersonalAccount,
        fromJson: StatusModel.fromJson);
  }

  // Interests
  Future<List<Interest>> fetchInterests() async {
    InterestListModel model = await ApiService.instance.call(
        url: WebService.interest.fetchInterests,
        fromJson: InterestListModel.fromJson);
    return model.data ?? [];
  }

  Future<StatusModel> updateMyInterests(
      {required List<int> interestIds}) async {
    return await ApiService.instance.call(
        url: WebService.interest.updateMyInterests,
        param: {Params.interestIds: interestIds.join(',')},
        fromJson: StatusModel.fromJson);
  }

  // Feed Preferences
  Future<Map<int, int>> fetchFeedPreferences() async {
    final response = await ApiService.instance.call<Map<String, dynamic>>(
        url: WebService.interest.fetchFeedPreferences,
        fromJson: (json) => json);
    final data = response['data'];
    if (data is Map) {
      return data.map((key, value) => MapEntry(int.parse(key.toString()), (value as num).toInt()));
    }
    return {};
  }

  Future<StatusModel> updateFeedPreference(
      {required int interestId, required int weight}) async {
    return await ApiService.instance.call(
        url: WebService.interest.updateFeedPreference,
        param: {'interest_id': interestId, 'weight': weight},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> resetFeed() async {
    return await ApiService.instance.call(
        url: WebService.interest.resetFeed,
        fromJson: StatusModel.fromJson);
  }

  Future<List<Map<String, dynamic>>> fetchMyKeywordFilters() async {
    final response = await ApiService.instance.call<Map<String, dynamic>>(
        url: WebService.interest.fetchMyKeywordFilters,
        fromJson: (json) => json);
    final data = response['data'];
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<StatusModel> addKeywordFilter({required String keyword}) async {
    return await ApiService.instance.call(
        url: WebService.interest.addKeywordFilter,
        param: {'keyword': keyword},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> removeKeywordFilter({required int keywordId}) async {
    return await ApiService.instance.call(
        url: WebService.interest.removeKeywordFilter,
        param: {'keyword_id': keywordId},
        fromJson: StatusModel.fromJson);
  }

  // Login Activity
  Future<List<Map<String, dynamic>>> fetchLoginSessions() async {
    final response = await ApiService.instance.call<Map<String, dynamic>>(
        url: WebService.user.fetchLoginSessions,
        fromJson: (json) => json);
    final data = response['data'];
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<StatusModel> logOutSession({required int sessionId}) async {
    return await ApiService.instance.call(
        url: WebService.user.logOutSession,
        param: {'session_id': sessionId},
        fromJson: StatusModel.fromJson);
  }

  // Data Download
  Future<StatusModel> requestDataDownload() async {
    return await ApiService.instance.call(
        url: WebService.user.requestDataDownload,
        fromJson: StatusModel.fromJson);
  }

  Future<List<Map<String, dynamic>>> fetchDataDownloadRequests() async {
    final response = await ApiService.instance.call<Map<String, dynamic>>(
        url: WebService.user.fetchDataDownloadRequests,
        fromJson: (json) => json);
    final data = response['data'];
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}
