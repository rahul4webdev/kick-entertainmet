import 'package:shortzz/utilities/const_res.dart';

class WebService {
  static var user = _User();
  static var setting = _Setting();
  static var addPostStory = _AddPostStory();
  static var post = _Post();
  static var google = _Google();
  static var notification = _Notification();
  static var giftWallet = _GiftWallet();
  static var search = _Search();
  static var moderation = _Moderation();
  static var common = _Common();
  static var business = _Business();
  static var interest = _Interest();
  static var monetization = _Monetization();
  static var chat = _Chat();
  static var instagram = _Instagram();
  static var content = _Content();
  static var liveTV = _LiveTV();
  static var series = _Series();
  static var highlight = _Highlight();
  static var sticker = _Sticker();
  static var creator = _Creator();
  static var social = _Social();
  static var subscription = _Subscription();
  static var twoFa = _TwoFa();
  static var broadcast = _Broadcast();
  static var bank = _Bank();
  static var playlist = _Playlist();
  static var notes = _Notes();
  static var milestone = _Milestone();
  static var collab = _Collab();
  static var scheduledLive = _ScheduledLive();
  static var paidSeries = _PaidSeries();
  static var adRevenue = _AdRevenue();
  static var shop = _Shop();
  static var marketplace = _Marketplace();
  static var affiliate = _Affiliate();
  static var team = _Team();
  static var family = _Family();
  static var locationReview = _LocationReview();
  static var friendsMap = _FriendsMap();
  static var call = _Call();
  static var contentModeration = _ContentModeration();
  static var template = _Template();
  static var greenScreen = _GreenScreen();
  static var cart = _Cart();
  static var liveShopping = _LiveShopping();
  static var replays = _Replays();
  static var aiChat = _AiChat();
  static var aiSticker = _AiSticker();
  static var aiTranslation = _AiTranslation();
  static var aiContentIdeas = _AiContentIdeas();
  static var aiVideo = _AiVideo();
  static var aiVoice = _AiVoice();
  static var poll = _Poll();
  static var thread = _Thread();
  static var calendar = _Calendar();
  static var account = _Account();
  static var challenge = _Challenge();
  static var creatorInsights = _CreatorInsights();
  static var sharing = _Sharing();
  static var portfolio = _Portfolio();
  static var live = _Live();
  static var grievance = _Grievance();
  static var appeal = _Appeal();
}

class _Common {
  String ipApi = "http://ip-api.com/json/";
}

class _Moderation {
  String moderatorDeletePost = "${apiURL}moderator/moderator_deletePost";
  String moderatorUnFreezeUser = "${apiURL}moderator/moderator_unFreezeUser";
  String moderatorFreezeUser = "${apiURL}moderator/moderator_freezeUser";
  String moderatorDeleteStory = "${apiURL}moderator/moderator_deleteStory";
  String issueViolation = "${apiURL}moderator/issueViolation";
  String fetchPendingReports = "${apiURL}moderator/fetchPendingReports";
  String resolveReport = "${apiURL}moderator/resolveReport";
  String fetchUserViolations = "${apiURL}moderator/fetchUserViolations";
  String fetchModerationLog = "${apiURL}moderator/fetchModerationLog";
  String checkBannedWords = "${apiURL}moderator/checkBannedWords";
  String fetchModerationStats = "${apiURL}moderator/fetchModerationStats";
}

class _Notification {
  String fetchAdminNotifications = "${apiURL}misc/fetchAdminNotifications";
  String fetchActivityNotifications = "${apiURL}misc/fetchActivityNotifications";
  String pushNotificationToSingleUser = "${apiURL}misc/pushNotificationToSingleUser";
  String fetchNotificationsByCategory = "${apiURL}misc/fetchNotificationsByCategory";
  String markNotificationsAsRead = "${apiURL}misc/markNotificationsAsRead";
  String markAllNotificationsAsRead = "${apiURL}misc/markAllNotificationsAsRead";
  String fetchUnreadNotificationCount = "${apiURL}misc/fetchUnreadNotificationCount";
}

class _GiftWallet {
  String sendGift = "${apiURL}misc/sendGift";
  String fetchMyWithdrawalRequest = "${apiURL}misc/fetchMyWithdrawalRequest";
  String submitWithdrawalRequest = "${apiURL}misc/submitWithdrawalRequest";
  String buyCoins = "${apiURL}misc/buyCoins";
  String sendTip = "${apiURL}misc/sendTip";
  String fetchTipAmounts = "${apiURL}misc/fetchTipAmounts";
  String fetchCreatorTiers = "${apiURL}misc/fetchCreatorTiers";
  String fetchMyTierStatus = "${apiURL}misc/fetchMyTierStatus";
}

class _User {
  String loginInUser = "${apiURL}user/logInUser";
  String logInFakeUser = "${apiURL}user/logInFakeUser";

  // Custom Auth
  String registerUser = "${apiURL}user/registerUser";
  String loginWithEmail = "${apiURL}user/loginWithEmail";
  String loginWithGoogle = "${apiURL}user/loginWithGoogle";
  String loginWithApple = "${apiURL}user/loginWithApple";
  String verifyEmail = "${apiURL}user/verifyEmail";
  String resendVerificationCode = "${apiURL}user/resendVerificationCode";
  String forgotPassword = "${apiURL}user/forgotPassword";
  String verifyResetCode = "${apiURL}user/verifyResetCode";
  String resetPassword = "${apiURL}user/resetPassword";
  String deleteMyAccount = "${apiURL}user/deleteMyAccount";
  String logOutUser = "${apiURL}user/logOutUser";
  String fetchUserDetails = "${apiURL}user/fetchUserDetails";
  String updateUserDetails = "${apiURL}user/updateUserDetails";
  String checkUsernameAvailability = "${apiURL}user/checkUsernameAvailability";
  String fetchLoginSessions = "${apiURL}user/fetchLoginSessions";
  String logOutSession = "${apiURL}user/logOutSession";
  String requestDataDownload = "${apiURL}user/requestDataDownload";
  String fetchDataDownloadRequests = "${apiURL}user/fetchDataDownloadRequests";
  String downloadMyData = "${apiURL}user/downloadMyData";
  String addUserLink = "${apiURL}user/addUserLink";
  String editeUserLink = "${apiURL}user/editeUserLink";
  String deleteUserLink = "${apiURL}user/deleteUserLink";
  String searchUsers = "${apiURL}user/searchUsers";
  String fetchMyFollowers = "${apiURL}user/fetchMyFollowers";
  String fetchUserFollowers = "${apiURL}user/fetchUserFollowers";
  String fetchUserFollowings = "${apiURL}user/fetchUserFollowings";
  String fetchMyFollowings = "${apiURL}user/fetchMyFollowings";
  String followUser = "${apiURL}user/followUser";
  String unFollowUser = "${apiURL}user/unFollowUser";
  String blockUser = "${apiURL}user/blockUser";
  String unBlockUser = "${apiURL}user/unBlockUser";
  String reportUser = "${apiURL}misc/reportUser";
  String fetchMyBlockedUsers = "${apiURL}user/fetchMyBlockedUsers";
  String muteUser = "${apiURL}user/muteUser";
  String unMuteUser = "${apiURL}user/unMuteUser";
  String fetchMyMutedUsers = "${apiURL}user/fetchMyMutedUsers";
  String restrictUser = "${apiURL}user/restrictUser";
  String unrestrictUser = "${apiURL}user/unrestrictUser";
  String fetchMyRestrictedUsers = "${apiURL}user/fetchMyRestrictedUsers";
  String addToFavorites = "${apiURL}user/addToFavorites";
  String removeFromFavorites = "${apiURL}user/removeFromFavorites";
  String fetchMyFavorites = "${apiURL}user/fetchMyFavorites";
  String addHiddenWord = "${apiURL}user/addHiddenWord";
  String removeHiddenWord = "${apiURL}user/removeHiddenWord";
  String fetchHiddenWords = "${apiURL}user/fetchHiddenWords";
  String addCloseFriend = "${apiURL}user/addCloseFriend";
  String removeCloseFriend = "${apiURL}user/removeCloseFriend";
  String fetchMyCloseFriends = "${apiURL}user/fetchMyCloseFriends";
  String updateLastUsedAt = "${apiURL}user/updateLastUsedAt";
  String fetchFollowRequests = "${apiURL}user/fetchFollowRequests";
  String acceptFollowRequest = "${apiURL}user/acceptFollowRequest";
  String rejectFollowRequest = "${apiURL}user/rejectFollowRequest";
}

class _AddPostStory {
  String addPostFeedText = "${apiURL}post/addPost_Feed_Text";
  String searchHashtags = "${apiURL}post/searchHashtags";
  String addPostFeedImage = "${apiURL}post/addPost_Feed_Image";
  String addPostFeedVideo = "${apiURL}post/addPost_Feed_Video";
  String addPostReel = "${apiURL}post/addPost_Reel";
}

class _Post {
  String fetchPostsDiscover = "${apiURL}post/fetchPostsDiscover";
  String fetchPostById = "${apiURL}post/fetchPostById";
  String fetchPostsByLocation = "${apiURL}post/fetchPostsByLocation";
  String fetchPostsNearBy = "${apiURL}post/fetchPostsNearBy";
  String fetchPostsFollowing = "${apiURL}post/fetchPostsFollowing";
  String fetchPostsFavorites = "${apiURL}post/fetchPostsFavorites";
  String fetchReelPostsByMusic = "${apiURL}post/fetchReelPostsByMusic";
  String fetchUserPosts = "${apiURL}post/fetchUserPosts";
  String fetchPostsByHashtag = "${apiURL}post/fetchPostsByHashtag";
  String fetchSavedPosts = "${apiURL}post/fetchSavedPosts";
  String deletePost = "${apiURL}post/deletePost";
  String increaseShareCount = "${apiURL}post/increaseShareCount";
  String increaseViewsCount = "${apiURL}post/increaseViewsCount";
  String pinPost = "${apiURL}post/pinPost";
  String unpinPost = "${apiURL}post/unpinPost";
  String updatePostCaptions = "${apiURL}post/updatePostCaptions";
  String fetchScheduledPosts = "${apiURL}post/fetchScheduledPosts";
  String cancelScheduledPost = "${apiURL}post/cancelScheduledPost";
  String markNotInterested = "${apiURL}post/markNotInterested";
  String undoNotInterested = "${apiURL}post/undoNotInterested";
  String generateEmbedCode = "${apiURL}post/generateEmbedCode";

  // Q&A
  String askQuestion = "${apiURL}post/askQuestion";
  String answerQuestion = "${apiURL}post/answerQuestion";
  String deleteQuestion = "${apiURL}post/deleteQuestion";
  String toggleHideQuestion = "${apiURL}post/toggleHideQuestion";
  String togglePinQuestion = "${apiURL}post/togglePinQuestion";
  String likeQuestion = "${apiURL}post/likeQuestion";
  String fetchQuestions = "${apiURL}post/fetchQuestions";

  String likePost = "${apiURL}post/likePost";
  String disLikePost = "${apiURL}post/disLikePost";
  String savePost = "${apiURL}post/savePost";
  String unSavePost = "${apiURL}post/unSavePost";
  String fetchCollections = "${apiURL}post/fetchCollections";
  String createCollection = "${apiURL}post/createCollection";
  String editCollection = "${apiURL}post/editCollection";
  String deleteCollection = "${apiURL}post/deleteCollection";
  String movePostToCollection = "${apiURL}post/movePostToCollection";
  String fetchCollectionPosts = "${apiURL}post/fetchCollectionPosts";
  String shareCollection = "${apiURL}post/shareCollection";
  String respondCollectionInvite = "${apiURL}post/respondCollectionInvite";
  String fetchCollectionInvites = "${apiURL}post/fetchCollectionInvites";
  String fetchCollectionMembers = "${apiURL}post/fetchCollectionMembers";
  String removeCollectionMember = "${apiURL}post/removeCollectionMember";
  String leaveCollection = "${apiURL}post/leaveCollection";
  String savePostToSharedCollection = "${apiURL}post/savePostToSharedCollection";
  String fetchSharedCollections = "${apiURL}post/fetchSharedCollections";
  String fetchDuetsOfPost = "${apiURL}post/fetchDuetsOfPost";
  String fetchDuetCount = "${apiURL}post/fetchDuetCount";
  String fetchStitchesOfPost = "${apiURL}post/fetchStitchesOfPost";
  String reportPost = "${apiURL}misc/reportPost";
  String addPostComment = "${apiURL}post/addPostComment";
  String likeComment = "${apiURL}post/likeComment";
  String fetchPostComments = "${apiURL}post/fetchPostComments";
  String fetchPostCommentReplies = "${apiURL}post/fetchPostCommentReplies";
  String fetchVideoRepliesForComment = "${apiURL}post/fetchVideoRepliesForComment";
  String deleteComment = "${apiURL}post/deleteComment";
  String deleteCommentReply = "${apiURL}post/deleteCommentReply";
  String pinComment = "${apiURL}post/pinComment";
  String unPinComment = "${apiURL}post/unPinComment";
  String disLikeComment = "${apiURL}post/disLikeComment";
  String replyToComment = "${apiURL}post/replyToComment";
  String fetchPendingComments = "${apiURL}post/fetchPendingComments";
  String approveComment = "${apiURL}post/approveComment";
  String rejectComment = "${apiURL}post/rejectComment";
  String creatorLikeComment = "${apiURL}post/creatorLikeComment";
  String creatorUnlikeComment = "${apiURL}post/creatorUnlikeComment";
  String fetchTopComments = "${apiURL}post/fetchTopComments";
  String fetchMusicExplore = "${apiURL}post/fetchMusicExplore";
  String fetchMusicByCategories = "${apiURL}post/fetchMusicByCategories";
  String fetchSavedMusics = "${apiURL}post/fetchSavedMusics";
  String serchMusic = "${apiURL}post/serchMusic";
  String createStory = "${apiURL}post/createStory";
  String viewStory = "${apiURL}post/viewStory";
  String deleteStory = "${apiURL}post/deleteStory";
  String addUserMusic = "${apiURL}post/addUserMusic";
  String fetchStory = "${apiURL}post/fetchStory";
  String fetchStoryByID = "${apiURL}post/fetchStoryByID";
  String fetchExplorePageData = "${apiURL}post/fetchExplorePageData";
  String fetchEnhancedExplore = "${apiURL}post/fetchEnhancedExplore";
  String fetchTrendingPosts = "${apiURL}post/fetchTrendingPosts";
  String fetchSubscriberOnlyPosts = "${apiURL}post/fetchSubscriberOnlyPosts";
}

class _Setting {
  String fetchSettings = "${apiURL}settings/fetchSettings";
  String uploadFileGivePath = "${apiURL}settings/uploadFileGivePath";
  String deleteFile = "${apiURL}settings/deleteFile";
}

class _Google {
  String get searchTextByPlace {
    return "https://places.googleapis.com/v1/places:searchText?fields=*";
  }

  String searchNearByPlace(double lat, double lon) {
    return 'https://places.googleapis.com/v1/places:searchNearby?fields=*';
  }
}

class _Search {
  String searchPosts = "${apiURL}post/searchPosts";
  String searchPostsFTS = "${apiURL}post/searchPostsFTS";
}

class _Business {
  String fetchProfileCategories = "${apiURL}business/fetchProfileCategories";
  String fetchProfileSubCategories =
      "${apiURL}business/fetchProfileSubCategories";
  String convertToBusinessAccount =
      "${apiURL}business/convertToBusinessAccount";
  String fetchMyBusinessStatus = "${apiURL}business/fetchMyBusinessStatus";
  String revertToPersonalAccount =
      "${apiURL}business/revertToPersonalAccount";
}

class _Interest {
  String fetchInterests = "${apiURL}interest/fetchInterests";
  String updateMyInterests = "${apiURL}interest/updateMyInterests";
  String fetchFeedPreferences = "${apiURL}interest/fetchFeedPreferences";
  String updateFeedPreference = "${apiURL}interest/updateFeedPreference";
  String resetFeed = "${apiURL}interest/resetFeed";
  String fetchMyKeywordFilters = "${apiURL}interest/fetchMyKeywordFilters";
  String addKeywordFilter = "${apiURL}interest/addKeywordFilter";
  String removeKeywordFilter = "${apiURL}interest/removeKeywordFilter";
}

class _Monetization {
  String fetchMonetizationStatus =
      "${apiURL}monetization/fetchMonetizationStatus";
  String applyForMonetization =
      "${apiURL}monetization/applyForMonetization";
  String submitKycDocument = "${apiURL}monetization/submitKycDocument";
  String fetchEarningsSummary =
      "${apiURL}monetization/fetchEarningsSummary";
  String fetchTransactionHistory =
      "${apiURL}monetization/fetchTransactionHistory";
  String claimRewardedAd = "${apiURL}monetization/claimRewardedAd";
}

class _Chat {
  static const _base = 'http://168.231.123.230:3002';
  String socketUrl = _base;
  String conversations = '$_base/api/chat/conversations';
  String messages(String convId) => '$_base/api/chat/conversations/$convId/messages';
  String chatUser(int userId) => '$_base/api/chat/user/$userId';
  String broadcastMessages(int channelId) => '$_base/api/chat/broadcast/$channelId/messages';
  String broadcastUnread = '$_base/api/chat/broadcast/unread';
  String scheduledMessages(String convId) => '$_base/api/chat/scheduled/$convId';
  String cancelScheduled(String id) => '$_base/api/chat/scheduled/$id';
  String searchMessages(String convId, String query) => '$_base/api/chat/conversations/$convId/search?q=$query';
  String mediaMessages(String convId, {String type = 'all'}) => '$_base/api/chat/conversations/$convId/media?type=$type';
  String pinnedMessages(String convId) => '$_base/api/chat/conversations/$convId/pinned';
  String starred = '$_base/api/chat/starred';
  String starredInConversation(String convId) => '$_base/api/chat/conversations/$convId/starred';
  String archivedConversations = '$_base/api/chat/conversations?archived=true';
  String groups = '$_base/api/chat/groups';
  String groupInfo(String groupId) => '$_base/api/chat/groups/$groupId';
  String exportChat(String convId) => '$_base/api/chat/conversations/$convId/export';
  String exports = '$_base/api/chat/exports';
}

class _Live {
  static const _base = 'http://168.231.123.230:3002';
  String active = '$_base/api/live/active';
  String room(String roomId) => '$_base/api/live/$roomId';
  String users(String roomId) => '$_base/api/live/$roomId/users';
  String comments(String roomId, {int limit = 50, int? before}) {
    String url = '$_base/api/live/$roomId/comments?limit=$limit';
    if (before != null) url += '&before=$before';
    return url;
  }
  String poll(String roomId) => '$_base/api/live/$roomId/poll';
  String questions(String roomId, {int limit = 50}) => '$_base/api/live/$roomId/questions?limit=$limit';
  String dummy = '$_base/api/live/dummy';
  String deleteDummy(String roomId) => '$_base/api/live/dummy/$roomId';
}

class _Broadcast {
  String createChannel = "${apiURL}broadcast/createChannel";
  String updateChannel = "${apiURL}broadcast/updateChannel";
  String deleteChannel = "${apiURL}broadcast/deleteChannel";
  String joinChannel = "${apiURL}broadcast/joinChannel";
  String leaveChannel = "${apiURL}broadcast/leaveChannel";
  String toggleMute = "${apiURL}broadcast/toggleMute";
  String fetchMyChannels = "${apiURL}broadcast/fetchMyChannels";
  String fetchUserChannels = "${apiURL}broadcast/fetchUserChannels";
  String fetchChannelDetails = "${apiURL}broadcast/fetchChannelDetails";
  String fetchChannelMembers = "${apiURL}broadcast/fetchChannelMembers";
  String searchChannels = "${apiURL}broadcast/searchChannels";
}

class _Instagram {
  String connect = "${apiURL}instagram/connect";
  String disconnect = "${apiURL}instagram/disconnect";
  String fetchMedia = "${apiURL}instagram/fetchMedia";
  String importVideo = "${apiURL}instagram/importVideo";
  String importBulk = "${apiURL}instagram/importBulk";
  String getConnectionStatus = "${apiURL}instagram/getConnectionStatus";
  String toggleAutoSync = "${apiURL}instagram/toggleAutoSync";
  String getImportHistory = "${apiURL}instagram/getImportHistory";
}

class _Content {
  String fetchContentByType = "${apiURL}content/fetchContentByType";
  String fetchContentGenres = "${apiURL}content/fetchContentGenres";
  String fetchContentLanguages = "${apiURL}content/fetchContentLanguages";
  String fetchLinkedPost = "${apiURL}content/fetchLinkedPost";
  String addPostMusicVideo = "${apiURL}content/addPost_MusicVideo";
  String addPostTrailer = "${apiURL}content/addPost_Trailer";
  String addPostNews = "${apiURL}content/addPost_News";
}

class _LiveTV {
  String fetchLiveChannels = "${apiURL}livetv/fetchLiveChannels";
  String addLiveChannel = "${apiURL}livetv/addLiveChannel";
  String updateLiveChannel = "${apiURL}livetv/updateLiveChannel";
  String deleteLiveChannel = "${apiURL}livetv/deleteLiveChannel";
}

class _ScheduledLive {
  String create = "${apiURL}scheduledLive/create";
  String fetch = "${apiURL}scheduledLive/fetch";
  String fetchMine = "${apiURL}scheduledLive/fetchMine";
  String toggleReminder = "${apiURL}scheduledLive/toggleReminder";
  String cancel = "${apiURL}scheduledLive/cancel";
  String update = "${apiURL}scheduledLive/update";
}

class _Series {
  String fetchSeries = "${apiURL}series/fetchSeries";
  String fetchSeriesEpisodes = "${apiURL}series/fetchSeriesEpisodes";
  String createSeries = "${apiURL}series/createSeries";
}

class _PaidSeries {
  String create = "${apiURL}paidSeries/create";
  String update = "${apiURL}paidSeries/update";
  String delete = "${apiURL}paidSeries/delete";
  String addVideo = "${apiURL}paidSeries/addVideo";
  String removeVideo = "${apiURL}paidSeries/removeVideo";
  String reorderVideos = "${apiURL}paidSeries/reorderVideos";
  String fetch = "${apiURL}paidSeries/fetch";
  String fetchMine = "${apiURL}paidSeries/fetchMine";
  String fetchVideos = "${apiURL}paidSeries/fetchVideos";
  String purchase = "${apiURL}paidSeries/purchase";
  String fetchMyPurchases = "${apiURL}paidSeries/fetchMyPurchases";
}

class _AdRevenue {
  String fetchAdRevenueStatus = "${apiURL}adRevenue/fetchAdRevenueStatus";
  String enrollInAdRevenueShare = "${apiURL}adRevenue/enrollInAdRevenueShare";
  String fetchAdRevenueSummary = "${apiURL}adRevenue/fetchAdRevenueSummary";
  String logAdImpression = "${apiURL}adRevenue/logAdImpression";
}

class _Shop {
  String fetchProducts = "${apiURL}products/fetch";
  String fetchMyProducts = "${apiURL}products/fetchMine";
  String fetchProductById = "${apiURL}products/fetchById";
  String createProduct = "${apiURL}products/create";
  String updateProduct = "${apiURL}products/update";
  String deleteProduct = "${apiURL}products/delete";
  String purchaseProduct = "${apiURL}products/purchase";
  String fetchMyOrders = "${apiURL}products/fetchMyOrders";
  String fetchSellerOrders = "${apiURL}products/fetchSellerOrders";
  String updateOrderStatus = "${apiURL}products/updateOrderStatus";
  String submitReview = "${apiURL}products/submitReview";
  String fetchReviews = "${apiURL}products/fetchReviews";
  String fetchCategories = "${apiURL}products/fetchCategories";
  String tagProducts = "${apiURL}products/tagProducts";
  String untagProduct = "${apiURL}products/untagProduct";
  String fetchPostProductTags = "${apiURL}products/fetchPostProductTags";
  String searchProducts = "${apiURL}products/searchProducts";
  String fetchFeaturedProducts = "${apiURL}products/fetchFeaturedProducts";
  String fetchProductTagsInReel = "${apiURL}products/fetchProductTagsInReel";
  String tagProductsEnhanced = "${apiURL}products/tagProductsEnhanced";
  String fetchSellerProducts = "${apiURL}products/fetchSellerProducts";
}

class _Highlight {
  String createHighlight = "${apiURL}highlight/createHighlight";
  String fetchHighlights = "${apiURL}highlight/fetchHighlights";
  String fetchHighlightById = "${apiURL}highlight/fetchHighlightById";
  String updateHighlight = "${apiURL}highlight/updateHighlight";
  String deleteHighlight = "${apiURL}highlight/deleteHighlight";
  String addStoryToHighlight = "${apiURL}highlight/addStoryToHighlight";
  String removeHighlightItem = "${apiURL}highlight/removeHighlightItem";
  String reorderHighlights = "${apiURL}highlight/reorderHighlights";
}

class _Creator {
  String fetchCreatorDashboard = "${apiURL}creator/fetchCreatorDashboard";
  String fetchPostAnalytics = "${apiURL}creator/fetchPostAnalytics";
  String fetchAudienceInsights = "${apiURL}creator/fetchAudienceInsights";
  String fetchSearchInsights = "${apiURL}creator/fetchSearchInsights";
}

class _Social {
  String repostPost = "${apiURL}social/repostPost";
  String undoRepost = "${apiURL}social/undoRepost";
  String fetchUserReposts = "${apiURL}social/fetchUserReposts";
  String fetchTrendingHashtags = "${apiURL}social/fetchTrendingHashtags";
  String fetchUsersOnlineStatus = "${apiURL}social/fetchUsersOnlineStatus";
  String reactToComment = "${apiURL}social/reactToComment";
  String fetchCommentReactions = "${apiURL}social/fetchCommentReactions";
}

class _Sticker {
  String voteOnPoll = "${apiURL}sticker/voteOnPoll";
  String fetchPollResults = "${apiURL}sticker/fetchPollResults";
  String submitQuestionResponse = "${apiURL}sticker/submitQuestionResponse";
  String fetchQuestionResponses = "${apiURL}sticker/fetchQuestionResponses";
  String answerQuiz = "${apiURL}sticker/answerQuiz";
  String fetchQuizResults = "${apiURL}sticker/fetchQuizResults";
  String submitSlider = "${apiURL}sticker/submitSlider";
  String fetchSliderResults = "${apiURL}sticker/fetchSliderResults";
  String subscribeCountdown = "${apiURL}sticker/subscribeCountdown";
  String unsubscribeCountdown = "${apiURL}sticker/unsubscribeCountdown";
  String fetchCountdownInfo = "${apiURL}sticker/fetchCountdownInfo";
  String createAddYoursChain = "${apiURL}sticker/createAddYoursChain";
  String participateInChain = "${apiURL}sticker/participateInChain";
  String fetchChainInfo = "${apiURL}sticker/fetchChainInfo";
}

class _Subscription {
  String enableSubscriptions = "${apiURL}subscription/enableSubscriptions";
  String disableSubscriptions = "${apiURL}subscription/disableSubscriptions";
  String createTier = "${apiURL}subscription/createTier";
  String updateTier = "${apiURL}subscription/updateTier";
  String deleteTier = "${apiURL}subscription/deleteTier";
  String fetchTiers = "${apiURL}subscription/fetchTiers";
  String subscribe = "${apiURL}subscription/subscribe";
  String cancelSubscription = "${apiURL}subscription/cancelSubscription";
  String fetchMySubscriptions = "${apiURL}subscription/fetchMySubscriptions";
  String fetchMySubscribers = "${apiURL}subscription/fetchMySubscribers";
  String checkSubscription = "${apiURL}subscription/checkSubscription";
}

class _TwoFa {
  String verifyTOTP = "${apiURL}2fa/verifyTOTP";
  String verifyBackupCode = "${apiURL}2fa/verifyBackupCode";
  String setup = "${apiURL}2fa/setup";
  String confirm = "${apiURL}2fa/confirm";
  String disable = "${apiURL}2fa/disable";
  String regenerateBackupCodes = "${apiURL}2fa/regenerateBackupCodes";
  String status = "${apiURL}2fa/status";
}

class _Bank {
  String fetchBankAccounts = "${apiURL}bank/fetchBankAccounts";
  String addBankAccount = "${apiURL}bank/addBankAccount";
  String updateBankAccount = "${apiURL}bank/updateBankAccount";
  String deleteBankAccount = "${apiURL}bank/deleteBankAccount";
  String setDefaultBankAccount = "${apiURL}bank/setDefaultBankAccount";
}

class _Playlist {
  String fetchUserPlaylists = "${apiURL}playlist/fetchUserPlaylists";
  String createPlaylist = "${apiURL}playlist/createPlaylist";
  String updatePlaylist = "${apiURL}playlist/updatePlaylist";
  String deletePlaylist = "${apiURL}playlist/deletePlaylist";
  String addPostToPlaylist = "${apiURL}playlist/addPostToPlaylist";
  String removePostFromPlaylist = "${apiURL}playlist/removePostFromPlaylist";
  String fetchPlaylistPosts = "${apiURL}playlist/fetchPlaylistPosts";
  String reorderPlaylistPosts = "${apiURL}playlist/reorderPlaylistPosts";
}

class _Notes {
  String createNote = "${apiURL}notes/createNote";
  String fetchMyNote = "${apiURL}notes/fetchMyNote";
  String fetchFollowerNotes = "${apiURL}notes/fetchFollowerNotes";
  String deleteNote = "${apiURL}notes/deleteNote";
}

class _Milestone {
  String fetchMyMilestones = "${apiURL}milestone/fetchMyMilestones";
  String checkMilestones = "${apiURL}milestone/checkMilestones";
  String markMilestoneSeen = "${apiURL}milestone/markMilestoneSeen";
  String markMilestoneShared = "${apiURL}milestone/markMilestoneShared";
}

class _Collab {
  String inviteCollaborator = "${apiURL}collab/inviteCollaborator";
  String respondToInvite = "${apiURL}collab/respondToInvite";
  String fetchPendingInvites = "${apiURL}collab/fetchPendingInvites";
  String fetchPostCollaborators = "${apiURL}collab/fetchPostCollaborators";
  String removeCollaborator = "${apiURL}collab/removeCollaborator";
}

class _Marketplace {
  String createCampaign = "${apiURL}marketplace/createCampaign";
  String updateCampaign = "${apiURL}marketplace/updateCampaign";
  String deleteCampaign = "${apiURL}marketplace/deleteCampaign";
  String fetchCampaigns = "${apiURL}marketplace/fetchCampaigns";
  String fetchMyCampaigns = "${apiURL}marketplace/fetchMyCampaigns";
  String fetchCampaignById = "${apiURL}marketplace/fetchCampaignById";
  String applyToCampaign = "${apiURL}marketplace/applyToCampaign";
  String inviteCreator = "${apiURL}marketplace/inviteCreator";
  String respondToProposal = "${apiURL}marketplace/respondToProposal";
  String completeProposal = "${apiURL}marketplace/completeProposal";
  String fetchMyProposals = "${apiURL}marketplace/fetchMyProposals";
  String fetchCampaignProposals = "${apiURL}marketplace/fetchCampaignProposals";
}

class _Affiliate {
  String fetchProducts = "${apiURL}affiliate/fetchProducts";
  String createLink = "${apiURL}affiliate/createLink";
  String removeLink = "${apiURL}affiliate/removeLink";
  String fetchMyLinks = "${apiURL}affiliate/fetchMyLinks";
  String fetchEarnings = "${apiURL}affiliate/fetchEarnings";
  String fetchDashboard = "${apiURL}affiliate/fetchDashboard";
  String trackClick = "${apiURL}affiliate/trackClick";
}

class _Team {
  String invite = "${apiURL}team/invite";
  String respond = "${apiURL}team/respond";
  String fetchMembers = "${apiURL}team/fetchMembers";
  String fetchManagedAccounts = "${apiURL}team/fetchManagedAccounts";
  String fetchInvites = "${apiURL}team/fetchInvites";
  String updateMember = "${apiURL}team/updateMember";
  String removeMember = "${apiURL}team/removeMember";
  String leave = "${apiURL}team/leave";
}

class _Family {
  String generateCode = "${apiURL}family/generateCode";
  String linkWithCode = "${apiURL}family/linkWithCode";
  String unlink = "${apiURL}family/unlink";
  String updateControls = "${apiURL}family/updateControls";
  String fetchLinkedAccounts = "${apiURL}family/fetchLinkedAccounts";
  String fetchMyControls = "${apiURL}family/fetchMyControls";
  String fetchActivityReport = "${apiURL}family/fetchActivityReport";
}

class _LocationReview {
  String submit = "${apiURL}locationReview/submit";
  String fetch = "${apiURL}locationReview/fetch";
  String fetchMy = "${apiURL}locationReview/fetchMy";
  String delete = "${apiURL}locationReview/delete";
}

class _FriendsMap {
  String updateLocation = "${apiURL}friendsMap/updateLocation";
  String toggleSharing = "${apiURL}friendsMap/toggleSharing";
  String fetchMyStatus = "${apiURL}friendsMap/fetchMyStatus";
  String fetchFriendsLocations = "${apiURL}friendsMap/fetchFriendsLocations";
}

class _Call {
  String initiateCall = "${apiURL}call/initiateCall";
  String answerCall = "${apiURL}call/answerCall";
  String endCall = "${apiURL}call/endCall";
  String rejectCall = "${apiURL}call/rejectCall";
  String fetchCallHistory = "${apiURL}call/fetchCallHistory";
  String generateLiveKitToken = "${apiURL}call/generateLiveKitToken";
}

class _ContentModeration {
  String check = "${apiURL}contentModeration/check";
}

class _Template {
  String fetchTemplates = "${apiURL}template/fetchTemplates";
  String fetchTemplateById = "${apiURL}template/fetchTemplateById";
  String incrementTemplateUse = "${apiURL}template/incrementTemplateUse";
  String createUserTemplate = "${apiURL}template/createUserTemplate";
  String fetchTrendingTemplates = "${apiURL}template/fetchTrendingTemplates";
  String likeTemplate = "${apiURL}template/likeTemplate";
  String fetchTemplateUsages = "${apiURL}template/fetchTemplateUsages";
}

class _GreenScreen {
  String fetchBackgrounds = "${apiURL}greenScreen/fetchBackgrounds";
}

class _Cart {
  String fetchCart = "${apiURL}cart/fetch";
  String addToCart = "${apiURL}cart/add";
  String updateCartItem = "${apiURL}cart/update";
  String removeFromCart = "${apiURL}cart/remove";
  String clearCart = "${apiURL}cart/clear";
  String checkout = "${apiURL}cart/checkout";
  String fetchAddresses = "${apiURL}cart/fetchAddresses";
  String addAddress = "${apiURL}cart/addAddress";
  String editAddress = "${apiURL}cart/editAddress";
  String deleteAddress = "${apiURL}cart/deleteAddress";
}

class _LiveShopping {
  String addProduct = "${apiURL}liveShopping/addProduct";
  String removeProduct = "${apiURL}liveShopping/removeProduct";
  String fetchProducts = "${apiURL}liveShopping/fetchProducts";
  String pinProduct = "${apiURL}liveShopping/pinProduct";
  String unpinProduct = "${apiURL}liveShopping/unpinProduct";
  String addToCart = "${apiURL}liveShopping/addToCart";
  String salesMetrics = "${apiURL}liveShopping/salesMetrics";
}

class _Replays {
  String saveReplay = "${apiURL}replays/save";
  String fetchMyReplays = "${apiURL}replays/fetchMine";
  String fetchUserReplays = "${apiURL}replays/fetchUser";
  String deleteReplay = "${apiURL}replays/delete";
  String updateReplay = "${apiURL}replays/update";
  String viewReplay = "${apiURL}replays/view";
}

class _AiChat {
  String sendMessage = "${apiURL}aiChat/sendMessage";
  String fetchHistory = "${apiURL}aiChat/fetchHistory";
  String fetchSessions = "${apiURL}aiChat/fetchSessions";
  String clearHistory = "${apiURL}aiChat/clearHistory";
  String botInfo = "${apiURL}aiChat/botInfo";
}

class _AiSticker {
  String generate = "${apiURL}aiSticker/generate";
  String fetchMine = "${apiURL}aiSticker/fetchMine";
  String fetchPublic = "${apiURL}aiSticker/fetchPublic";
  String incrementUse = "${apiURL}aiSticker/incrementUse";
  String deleteSticker = "${apiURL}aiSticker/delete";
}

class _AiTranslation {
  String translateText = "${apiURL}aiTranslation/translateText";
  String translateCaptions = "${apiURL}aiTranslation/translateCaptions";
}

class _AiContentIdeas {
  String generateIdeas = "${apiURL}aiContentIdeas/generateIdeas";
  String fetchTrendingTopics = "${apiURL}aiContentIdeas/fetchTrendingTopics";
}

class _AiVideo {
  String generateFromText = "${apiURL}aiVideo/generateFromText";
  String generateFromImage = "${apiURL}aiVideo/generateFromImage";
}

class _AiVoice {
  String enhanceAudio = "${apiURL}aiVoice/enhanceAudio";
  String enhanceVideo = "${apiURL}aiVoice/enhanceVideo";
  String transcribeAudio = "${apiURL}aiVoice/transcribeAudio";
}

class _Poll {
  String createPollPost = "${apiURL}poll/createPollPost";
  String voteOnPoll = "${apiURL}poll/voteOnPoll";
  String fetchPollResults = "${apiURL}poll/fetchPollResults";
  String closePoll = "${apiURL}poll/closePoll";
}

class _Thread {
  String createThread = "${apiURL}thread/createThread";
  String addToThread = "${apiURL}thread/addToThread";
  String fetchThread = "${apiURL}thread/fetchThread";
  String quoteRepost = "${apiURL}thread/quoteRepost";
}

class _Calendar {
  String fetchCalendarEvents = "${apiURL}calendar/fetchCalendarEvents";
  String fetchBestTimeToPost = "${apiURL}calendar/fetchBestTimeToPost";
  String updateDraftDate = "${apiURL}calendar/updateDraftDate";
  String bulkSchedule = "${apiURL}calendar/bulkSchedule";
}

class _Account {
  String fetchDeviceAccounts = "${apiURL}account/fetchDeviceAccounts";
  String switchAccount = "${apiURL}account/switchAccount";
  String removeAccountFromDevice = "${apiURL}account/removeAccountFromDevice";
}

class _Challenge {
  String createChallenge = "${apiURL}challenge/createChallenge";
  String fetchChallenges = "${apiURL}challenge/fetchChallenges";
  String fetchChallengeById = "${apiURL}challenge/fetchChallengeById";
  String enterChallenge = "${apiURL}challenge/enterChallenge";
  String fetchEntries = "${apiURL}challenge/fetchEntries";
  String fetchLeaderboard = "${apiURL}challenge/fetchLeaderboard";
  String endChallenge = "${apiURL}challenge/endChallenge";
  String awardPrizes = "${apiURL}challenge/awardPrizes";
}

class _CreatorInsights {
  String generateInsights = "${apiURL}creatorInsights/generateInsights";
  String fetchInsights = "${apiURL}creatorInsights/fetchInsights";
  String markInsightRead = "${apiURL}creatorInsights/markInsightRead";
  String fetchTrendingTopics = "${apiURL}creatorInsights/fetchTrendingTopics";
}

class _Sharing {
  String generateShareableCard = "${apiURL}sharing/generateShareableCard";
}

class _Portfolio {
  String createOrUpdate = "${apiURL}portfolio/createOrUpdate";
  String fetchMine = "${apiURL}portfolio/fetchMine";
  String addSection = "${apiURL}portfolio/addSection";
  String updateSection = "${apiURL}portfolio/updateSection";
  String removeSection = "${apiURL}portfolio/removeSection";
  String reorderSections = "${apiURL}portfolio/reorderSections";
}

class _Grievance {
  String submit = "${apiURL}grievance/submit";
  String list = "${apiURL}grievance/list";
  String detail = "${apiURL}grievance/detail";
  String respond = "${apiURL}grievance/respond";
  String groInfo = "${apiURL}grievance/gro-info";
}

class _Appeal {
  String submit = "${apiURL}appeal/submit";
  String list = "${apiURL}appeal/list";
  String detail = "${apiURL}appeal/detail";
}
