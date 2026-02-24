import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/content_upload_screen/content_upload_controller.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ContentUploadScreen extends StatelessWidget {
  final ContentUploadType uploadType;

  const ContentUploadScreen({super.key, required this.uploadType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ContentUploadController(uploadType),
      tag: uploadType.name,
    );

    return Scaffold(
      backgroundColor: blackPure(context),
      appBar: AppBar(
        backgroundColor: blackPure(context),
        title: Text(
          'Upload ${controller.uploadTypeLabel}',
          style: TextStyle(color: whitePure(context), fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(color: whitePure(context)),
      ),
      body: Obx(() {
        if (!controller.isAccountAllowed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: textLightGrey(context)),
                  const SizedBox(height: 16),
                  Text(
                    'Account Not Eligible',
                    style: TextStyle(color: whitePure(context), fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    uploadType == ContentUploadType.news
                        ? 'Only News & Media accounts can upload news content.'
                        : 'Only Production House accounts can upload this content.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textLightGrey(context), fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.isUploading.value) {
          return _UploadProgressView(controller: controller);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video picker
              _SectionTitle('Video *'),
              const SizedBox(height: 8),
              _MediaPickerTile(
                icon: Icons.videocam_rounded,
                label: controller.videoFile.value?.name ?? 'Select Video',
                hasFile: controller.videoFile.value != null,
                onTap: controller.pickVideo,
              ),

              const SizedBox(height: 16),

              // Thumbnail picker
              _SectionTitle('Thumbnail *'),
              const SizedBox(height: 8),
              _MediaPickerTile(
                icon: Icons.image_rounded,
                label: controller.thumbnailFile.value?.name ?? 'Select Thumbnail',
                hasFile: controller.thumbnailFile.value != null,
                onTap: controller.pickThumbnail,
              ),

              const SizedBox(height: 16),

              // Description
              _SectionTitle('Description'),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: controller.descriptionController,
                hint: 'Add a description...',
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Genre dropdown
              if (uploadType != ContentUploadType.news) ...[
                _SectionTitle('Genre *'),
                const SizedBox(height: 8),
                _GenreDropdown(controller: controller),
                const SizedBox(height: 16),
              ],

              // Language dropdown
              _SectionTitle('Language'),
              const SizedBox(height: 8),
              _LanguageDropdown(controller: controller),
              const SizedBox(height: 16),

              // Content-type specific fields
              ..._buildTypeSpecificFields(context, controller),

              // Link to previous part
              _SectionTitle('Link to Previous Part (optional)'),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: controller.linkedPostIdController,
                hint: 'Enter post ID of previous part',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Product Links
              _ProductLinksSection(controller: controller),
              const SizedBox(height: 16),

              // Comment toggle
              Row(
                children: [
                  Text('Allow Comments', style: TextStyle(color: whitePure(context), fontSize: 14)),
                  const Spacer(),
                  Obx(() => Switch(
                        value: controller.canComment.value,
                        onChanged: (v) => controller.canComment.value = v,
                        activeColor: Colors.tealAccent,
                      )),
                ],
              ),

              // AI Generated toggle
              Row(
                children: [
                  Text(LKey.aiGenerated.tr, style: TextStyle(color: whitePure(context), fontSize: 14)),
                  const Spacer(),
                  Obx(() => Switch(
                        value: controller.isAiGenerated.value,
                        onChanged: (v) => controller.isAiGenerated.value = v,
                        activeColor: Colors.tealAccent,
                      )),
                ],
              ),

              const SizedBox(height: 8),

              // Error message
              Obx(() {
                if (controller.errorMessage.value.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                );
              }),

              // Upload button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.upload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Upload ${controller.uploadTypeLabel}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildTypeSpecificFields(BuildContext context, ContentUploadController controller) {
    switch (uploadType) {
      case ContentUploadType.musicVideo:
        return [
          _SectionTitle('Artist Name'),
          const SizedBox(height: 8),
          _StyledTextField(controller: controller.artistController, hint: 'Artist name'),
          const SizedBox(height: 16),
          _SectionTitle('Release Date'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => controller.pickReleaseDate(context),
            child: AbsorbPointer(
              child: _StyledTextField(
                controller: controller.releaseDateController,
                hint: 'Tap to select date',
              ),
            ),
          ),
          const SizedBox(height: 16),
        ];
      case ContentUploadType.trailer:
        return [
          _SectionTitle('Production House'),
          const SizedBox(height: 8),
          _StyledTextField(controller: controller.productionController, hint: 'Production house name'),
          const SizedBox(height: 16),
          _SectionTitle('Release Date'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => controller.pickReleaseDate(context),
            child: AbsorbPointer(
              child: _StyledTextField(
                controller: controller.releaseDateController,
                hint: 'Tap to select date',
              ),
            ),
          ),
          const SizedBox(height: 16),
        ];
      case ContentUploadType.news:
        return [
          _SectionTitle('Category'),
          const SizedBox(height: 8),
          _StyledTextField(controller: controller.categoryController, hint: 'e.g. Politics, Sports, Tech'),
          const SizedBox(height: 16),
          _SectionTitle('Source'),
          const SizedBox(height: 8),
          _StyledTextField(controller: controller.sourceController, hint: 'Source / Channel name'),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Breaking News', style: TextStyle(color: whitePure(context), fontSize: 14)),
              const Spacer(),
              Obx(() => Switch(
                    value: controller.isBreaking.value,
                    onChanged: (v) => controller.isBreaking.value = v,
                    activeColor: Colors.redAccent,
                  )),
            ],
          ),
          const SizedBox(height: 16),
        ];
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: whitePure(context), fontSize: 14, fontWeight: FontWeight.w600));
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _MediaPickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool hasFile;
  final VoidCallback onTap;

  const _MediaPickerTile({
    required this.icon,
    required this.label,
    required this.hasFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: hasFile ? Colors.tealAccent.withValues(alpha: 0.5) : Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(icon, color: hasFile ? Colors.tealAccent : Colors.grey.shade500, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: hasFile ? Colors.white : Colors.grey.shade500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}

class _GenreDropdown extends StatelessWidget {
  final ContentUploadController controller;
  const _GenreDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.genres.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Loading genres...', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<int>(
          value: controller.selectedGenre.value?.id,
          hint: Text('Select Genre', style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          dropdownColor: Colors.grey.shade900,
          underline: const SizedBox.shrink(),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: controller.genres
              .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name ?? '')))
              .toList(),
          onChanged: (id) {
            controller.selectedGenre.value =
                controller.genres.firstWhereOrNull((g) => g.id == id);
          },
        ),
      );
    });
  }
}

class _LanguageDropdown extends StatelessWidget {
  final ContentUploadController controller;
  const _LanguageDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.languages.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Loading languages...', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<int>(
          value: controller.selectedLanguage.value?.id,
          hint: Text('Select Language', style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          dropdownColor: Colors.grey.shade900,
          underline: const SizedBox.shrink(),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: controller.languages
              .map((l) => DropdownMenuItem(value: l.id, child: Text(l.name ?? '')))
              .toList(),
          onChanged: (id) {
            controller.selectedLanguage.value =
                controller.languages.firstWhereOrNull((l) => l.id == id);
          },
        ),
      );
    });
  }
}

class _UploadProgressView extends StatelessWidget {
  final ContentUploadController controller;
  const _UploadProgressView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: controller.uploadProgress.value / 100,
                        strokeWidth: 6,
                        color: Colors.tealAccent,
                        backgroundColor: Colors.grey.shade800,
                      ),
                    ),
                    Obx(() => Text(
                          '${controller.uploadProgress.value.toInt()}%',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        )),
                  ],
                )),
            const SizedBox(height: 20),
            Text(
              'Uploading ${controller.uploadTypeLabel}...',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductLinksSection extends StatelessWidget {
  final ContentUploadController controller;

  const _ProductLinksSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionTitle('Product Links (optional)'),
            const Spacer(),
            Obx(() => controller.productLinks.length < 3
                ? GestureDetector(
                    onTap: controller.addProductLink,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 14, color: Colors.tealAccent),
                          SizedBox(width: 4),
                          Text('Add', style: TextStyle(color: Colors.tealAccent, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.productLinks.isEmpty) {
            return Text(
              'Add product links to show Buy Now, Sign Up, etc. buttons on your video.',
              style: TextStyle(color: textLightGrey(context), fontSize: 12),
            );
          }
          return Column(
            children: List.generate(controller.productLinks.length, (index) {
              return _ProductLinkRow(
                index: index,
                controller: controller,
              );
            }),
          );
        }),
      ],
    );
  }
}

class _ProductLinkRow extends StatelessWidget {
  final int index;
  final ContentUploadController controller;

  const _ProductLinkRow({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final link = controller.productLinks[index];
                    return DropdownButtonFormField<ProductButtonType>(
                      initialValue: link.buttonType,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white24)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white24)),
                      ),
                      items: ProductButtonType.values.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type.label));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) controller.updateProductLink(index, buttonType: v);
                      },
                    );
                  }),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => controller.removeProductLink(index),
                  child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: controller.productLinks[index].label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Button label (e.g. Shop Now)',
                hintStyle: TextStyle(color: textLightGrey(context), fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white24)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white24)),
              ),
              onChanged: (v) => controller.updateProductLink(index, label: v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: controller.productLinks[index].url,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'https://example.com/product',
                hintStyle: TextStyle(color: textLightGrey(context), fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white24)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white24)),
              ),
              keyboardType: TextInputType.url,
              onChanged: (v) => controller.updateProductLink(index, url: v),
            ),
          ],
        ),
      ),
    );
  }
}
