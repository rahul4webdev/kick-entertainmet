import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/playlist_service.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/playlist/playlist_model.dart';
import 'package:shortzz/screen/playlist_screen/playlist_detail_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ProfilePlaylistsTab extends StatefulWidget {
  final int userId;
  final bool isMe;

  const ProfilePlaylistsTab({
    super.key,
    required this.userId,
    required this.isMe,
  });

  @override
  State<ProfilePlaylistsTab> createState() => _ProfilePlaylistsTabState();
}

class _ProfilePlaylistsTabState extends State<ProfilePlaylistsTab> {
  final RxList<PlaylistItem> playlists = <PlaylistItem>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
  }

  Future<void> _fetchPlaylists() async {
    isLoading.value = true;
    playlists.value =
        await PlaylistService.instance.fetchUserPlaylists(userId: widget.userId);
    isLoading.value = false;
  }

  void _showCreateSheet() {
    final nameC = TextEditingController();
    final descC = TextEditingController();
    final isPublic = true.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                LKey.createPlaylist.tr,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameC,
                decoration: InputDecoration(
                  labelText: LKey.playlistName.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descC,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: LKey.description.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => CheckboxListTile(
                    value: isPublic.value,
                    onChanged: (v) => isPublic.value = v ?? true,
                    title: Text(LKey.publicPlaylist.tr),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameC.text.trim().isEmpty) return;
                    final result = await PlaylistService.instance.createPlaylist(
                      name: nameC.text.trim(),
                      description: descC.text.trim().isEmpty
                          ? null
                          : descC.text.trim(),
                      isPublic: isPublic.value,
                    );
                    if (result != null) {
                      playlists.insert(0, result);
                      Get.back();
                    }
                  },
                  child: Text(LKey.createPlaylist.tr),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _deletePlaylist(PlaylistItem playlist) {
    Get.dialog(
      AlertDialog(
        title: Text(LKey.delete.tr),
        content: Text(LKey.deletePlaylistConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LKey.cancel.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await PlaylistService.instance
                  .deletePlaylist(playlistId: playlist.id!);
              playlists.removeWhere((p) => p.id == playlist.id);
            },
            child: Text(
              LKey.delete.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value && playlists.isEmpty) {
        return const LoaderWidget();
      }
      return RefreshIndicator(
        onRefresh: _fetchPlaylists,
        child: NoDataView(
          showShow: playlists.isEmpty,
          title: LKey.noPlaylists.tr,
          description: widget.isMe
              ? LKey.noPlaylistsDesc.tr
              : LKey.noPlaylistsOther.tr,
          child: ListView.builder(
            itemCount: playlists.length + (widget.isMe ? 1 : 0),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              if (widget.isMe && index == 0) {
                return _AddPlaylistTile(onTap: _showCreateSheet);
              }
              final playlist = playlists[widget.isMe ? index - 1 : index];
              return _PlaylistTile(
                playlist: playlist,
                isMe: widget.isMe,
                onTap: () => Get.to(
                    () => PlaylistDetailScreen(playlist: playlist)),
                onDelete: widget.isMe
                    ? () => _deletePlaylist(playlist)
                    : null,
              );
            },
          ),
        ),
      );
    });
  }
}

class _AddPlaylistTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPlaylistTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgLightGrey(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeAccentSolid(context).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: themeAccentSolid(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add,
                  color: themeAccentSolid(context), size: 28),
            ),
            const SizedBox(width: 14),
            Text(
              LKey.createPlaylist.tr,
              style: TextStyleCustom.outFitMedium500(
                fontSize: 15,
                color: themeAccentSolid(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final PlaylistItem playlist;
  final bool isMe;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _PlaylistTile({
    required this.playlist,
    required this.isMe,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: bgLightGrey(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 72,
                height: 72,
                child: playlist.coverThumbnail != null
                    ? Image.network(
                        playlist.coverThumbnail!.addBaseURL(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholderIcon(context),
                      )
                    : _placeholderIcon(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          playlist.name ?? '',
                          style: TextStyleCustom.outFitMedium500(
                            fontSize: 15,
                            color: textDarkGrey(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!playlist.isPublic)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.lock,
                              size: 14, color: textLightGrey(context)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.postCount ?? 0} ${LKey.videosCount.tr}',
                    style: TextStyleCustom.outFitLight300(
                      fontSize: 13,
                      color: textLightGrey(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isMe && onDelete != null)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: textLightGrey(context)),
                onSelected: (value) {
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      LKey.delete.tr,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon(BuildContext context) {
    return Container(
      color: bgGrey(context),
      child: Icon(Icons.playlist_play, color: textLightGrey(context), size: 30),
    );
  }
}
