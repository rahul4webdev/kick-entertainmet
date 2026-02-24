import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/collection/collection_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SaveCollectionPicker extends StatefulWidget {
  final int postId;
  final VoidCallback onSaved;

  const SaveCollectionPicker({
    super.key,
    required this.postId,
    required this.onSaved,
  });

  static Future<void> show({
    required int postId,
    required VoidCallback onSaved,
  }) {
    return showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveCollectionPicker(postId: postId, onSaved: onSaved),
    );
  }

  @override
  State<SaveCollectionPicker> createState() => _SaveCollectionPickerState();
}

class _SaveCollectionPickerState extends State<SaveCollectionPicker> {
  List<SaveCollection> _collections = [];
  bool _isLoading = true;
  bool _isSaving = false;
  final _newCollectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCollections();
  }

  @override
  void dispose() {
    _newCollectionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCollections() async {
    final data = await PostService.instance.fetchCollections();
    if (data != null && mounted) {
      setState(() {
        _collections = data.collections;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToCollection(int? collectionId) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await PostService.instance
        .savePost(postId: widget.postId, collectionId: collectionId);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _createAndSave() async {
    final name = _newCollectionController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isSaving = true);
    final result = await PostService.instance.createCollection(name: name);
    if (result.status == true) {
      await _fetchCollections();
      final newCollection =
          _collections.where((c) => c.name == name).firstOrNull;
      await _saveToCollection(newCollection?.id);
    } else {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textLightGrey(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              LKey.saveToCollection.tr,
              style: TextStyleCustom.unboundedSemiBold600(
                  fontSize: 16, color: textDarkGrey(context)),
            ),
          ),
          const Divider(height: 1),
          // Quick save (no collection)
          ListTile(
            leading: Icon(Icons.bookmark_add_outlined,
                color: themeAccentSolid(context)),
            title: Text(LKey.quickSave.tr,
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 14, color: textDarkGrey(context))),
            subtitle: Text(LKey.saveWithoutCollection.tr,
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 12, color: textLightGrey(context))),
            onTap: _isSaving ? null : () => _saveToCollection(null),
          ),
          const Divider(height: 1),
          // Create new collection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCollectionController,
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 14, color: textDarkGrey(context)),
                    decoration: InputDecoration(
                      hintText: LKey.newCollectionName.tr,
                      hintStyle: TextStyleCustom.outFitRegular400(
                          fontSize: 14, color: textLightGrey(context)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isSaving ? null : _createAndSave,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: themeAccentSolid(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(LKey.create.tr,
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 13, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Collections list
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _collections.length,
                itemBuilder: (context, index) {
                  final collection = _collections[index];
                  return ListTile(
                    leading: Icon(
                      collection.isDefault
                          ? Icons.bookmark
                          : Icons.folder_outlined,
                      color: themeAccentSolid(context),
                    ),
                    title: Text(
                      collection.name ?? '',
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 14, color: textDarkGrey(context)),
                    ),
                    trailing: Text(
                      '${collection.postCount}',
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 12, color: textLightGrey(context)),
                    ),
                    onTap:
                        _isSaving ? null : () => _saveToCollection(collection.id),
                  );
                },
              ),
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
