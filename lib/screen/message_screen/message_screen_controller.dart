import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/note_service.dart';
import 'package:shortzz/common/service/chat/chat_api_service.dart';
import 'package:shortzz/common/service/chat/chat_events.dart';
import 'package:shortzz/common/service/chat/chat_socket_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/notes/user_note_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class MessageScreenController extends BaseController {
  List<String> chatCategories = [LKey.chats.tr, LKey.requests.tr];
  RxInt selectedChatCategory = 0.obs;
  PageController pageController = PageController();
  User? myUser = SessionManager.instance.getUser();
  RxList<ChatThread> chatsUsers = <ChatThread>[].obs;
  RxList<ChatThread> requestsUsers = <ChatThread>[].obs;
  final dashboardController = Get.find<DashboardScreenController>();
  dynamic Function(dynamic)? _conversationUpdateHandler;

  // Search filter for existing conversations
  RxString searchQuery = ''.obs;
  final TextEditingController searchTextController = TextEditingController();

  List<ChatThread> get filteredChats {
    if (searchQuery.value.isEmpty) return chatsUsers;
    final q = searchQuery.value.toLowerCase();
    return chatsUsers.where((thread) {
      final username = thread.chatUser?.username?.toLowerCase() ?? '';
      final fullname = thread.chatUser?.fullname?.toLowerCase() ?? '';
      return username.contains(q) || fullname.contains(q);
    }).toList();
  }

  List<ChatThread> get filteredRequests {
    if (searchQuery.value.isEmpty) return requestsUsers;
    final q = searchQuery.value.toLowerCase();
    return requestsUsers.where((thread) {
      final username = thread.chatUser?.username?.toLowerCase() ?? '';
      final fullname = thread.chatUser?.fullname?.toLowerCase() ?? '';
      return username.contains(q) || fullname.contains(q);
    }).toList();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  // Notes
  Rx<UserNote?> myNote = Rx<UserNote?>(null);
  RxList<UserNote> followerNotes = <UserNote>[].obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: selectedChatCategory.value);
    _fetchConversations();
    _listenToConversationUpdates();
    _fetchNotes();
  }

  @override
  void onClose() {
    ChatSocketService.instance.off(ChatEvents.sConversationUpdate, _conversationUpdateHandler);
    super.onClose();
  }

  void onPageChanged(int index) {
    selectedChatCategory.value = index;
  }

  Future<void> _fetchConversations() async {
    isLoading.value = true;
    final threads = await ChatApiService.instance.fetchConversations();
    isLoading.value = false;

    for (var thread in threads) {
      thread.bindChatUser();
      if (thread.chatType == ChatType.approved) {
        chatsUsers.add(thread);
      } else {
        requestsUsers.add(thread);
      }
    }

    _sortLists();
  }

  void _listenToConversationUpdates() {
    _conversationUpdateHandler = (dynamic data) {
      if (data is! Map) return;
      final thread = ChatThread.fromJson(Map<String, dynamic>.from(data));

      // Ignore events sent to us by mistake (stale Redis socket — server sends
      // both user perspectives and this device receives both due to stale entry)
      if (thread.userId == myUser?.id) return;

      // Remove from both lists (match by conversationId for accuracy)
      chatsUsers.removeWhere((u) => u.conversationId == thread.conversationId);
      requestsUsers.removeWhere((u) => u.conversationId == thread.conversationId);

      // If deleted, don't re-add
      if (thread.isDeleted == true) {
        _sortLists();
        return;
      }

      thread.bindChatUser();

      if (thread.chatType == ChatType.approved) {
        chatsUsers.add(thread);
      } else {
        requestsUsers.add(thread);
      }

      _sortLists();
    };
    ChatSocketService.instance.on(ChatEvents.sConversationUpdate, _conversationUpdateHandler!);
  }

  void _sortLists() {
    chatsUsers.sort((a, b) => (b.id ?? '0').compareTo(a.id ?? '0'));
    requestsUsers.sort((a, b) => (b.id ?? '0').compareTo(a.id ?? '0'));
  }

  void onLongPress(ChatThread chatConversation) {
    Get.bottomSheet(ConfirmationSheet(
      title: LKey.deleteChatUserTitle.trParams({'user_name': chatConversation.chatUser?.username ?? ''}),
      description: LKey.deleteChatUserDescription.tr,
      onTap: () async {
        showLoader();
        ChatSocketService.instance.emit(ChatEvents.cDeleteConversation, {
          'conversation_id': chatConversation.conversationId,
        });
        // Remove locally immediately
        chatsUsers.removeWhere((u) => u.userId == chatConversation.userId);
        requestsUsers.removeWhere((u) => u.userId == chatConversation.userId);
        stopLoader();
      },
    ));
  }

  Future<void> _fetchNotes() async {
    final results = await Future.wait([
      NoteService.instance.fetchMyNote(),
      NoteService.instance.fetchFollowerNotes(),
    ]);
    myNote.value = results[0] as UserNote?;
    final allNotes = results[1] as List<UserNote>;
    // Exclude my own note from follower notes
    final myId = SessionManager.instance.getUserID();
    followerNotes.value = allNotes.where((n) => n.userId != myId).toList();
  }

  void onMyNoteTap() {
    if (myNote.value != null) {
      // Show options: view or delete
      Get.bottomSheet(ConfirmationSheet(
        title: LKey.deleteNote.tr,
        description: LKey.deleteNoteConfirm.tr,
        onTap: () async {
          await NoteService.instance.deleteNote();
          myNote.value = null;
        },
      ));
    } else {
      _showNoteComposer();
    }
  }

  void _showNoteComposer() {
    final textController = TextEditingController();
    String selectedEmoji = '💬';
    final emojis = ['💬', '😍', '🔥', '😂', '😢', '🤔', '🎉', '💯', '👋', '✨'];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: scaffoldBackgroundColor(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textLightGrey(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(LKey.shareANote.tr,
                      style: TextStyleCustom.unboundedSemiBold600(
                          fontSize: 18, color: textDarkGrey(context))),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: emojis.map((e) {
                      final isSelected = selectedEmoji == e;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedEmoji = e),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? themeAccentSolid(context).withValues(alpha: 0.2)
                                : null,
                            border: isSelected
                                ? Border.all(color: themeAccentSolid(context), width: 2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(e, style: const TextStyle(fontSize: 22)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    maxLength: 60,
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 15, color: textDarkGrey(context)),
                    decoration: InputDecoration(
                      hintText: LKey.whatsOnYourMind.tr,
                      hintStyle: TextStyleCustom.outFitRegular400(
                          fontSize: 15, color: textLightGrey(context)),
                      filled: true,
                      fillColor: bgMediumGrey(context),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final text = textController.text.trim();
                        if (text.isEmpty) return;
                        Get.back();
                        final result = await NoteService.instance.createNote(
                          content: text,
                          emoji: selectedEmoji,
                        );
                        if (result['status'] == true && result['data'] != null) {
                          myNote.value = UserNote.fromJson(
                              Map<String, dynamic>.from(result['data']));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeAccentSolid(context),
                        foregroundColor: whitePure(context),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(LKey.share.tr,
                          style: TextStyleCustom.outFitMedium500(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
