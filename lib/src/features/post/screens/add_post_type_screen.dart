import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/error.dart';
import 'package:latery/src/core/common/error_snackbar.dart';
import 'package:latery/src/core/common/image_picker.dart';
import 'package:latery/src/core/common/loader.dart';
import 'package:latery/src/features/communities/controller/community_controller.dart';
import 'package:latery/src/features/post/controller/post_controller.dart';
import 'package:latery/src/model/community_model.dart';
import 'package:latery/src/theme/colors.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final linkController = TextEditingController();
  List<Community> communities = [];
  Community? selectedCommunity;

  File? image;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    bodyController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        image = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' &&
        image != null &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
          context: context,
          title: titleController.text.trim(),
          image: image,
          selectedCommunity: selectedCommunity ?? communities[0]);
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
          context: context,
          title: titleController.text.trim(),
          description: bodyController.text.trim(),
          selectedCommunity: selectedCommunity ?? communities[0]);
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
          context: context,
          title: titleController.text.trim(),
          link: linkController.text.trim(),
          selectedCommunity: selectedCommunity ?? communities[0]);
    } else {
      showErrorSnackBar(context, 'Do not leave any field empty!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blueColor,
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text('Share'),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    maxLength: 30,
                    controller: titleController,
                    style: TextStyle(
                      color: currentTheme.textTheme.bodyMedium!.color!,
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      hintStyle: TextStyle(color: AppColors.greyColor),
                      hintText: 'Enter Title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isTypeImage)
                    GestureDetector(
                      onTap: selectBannerImage,
                      child: DottedBorder(
                        color: currentTheme.textTheme.bodyMedium!.color!,
                        radius: const Radius.circular(15),
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        borderType: BorderType.RRect,
                        child: Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: image != null
                                ? Image.file(image!)
                                : const Center(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 80,
                                    ),
                                  )),
                      ),
                    ),
                  if (isTypeText)
                    TextField(
                      maxLines: 5,
                      controller: bodyController,
                      style: TextStyle(
                        color: currentTheme.textTheme.bodyMedium!.color!,
                      ),
                      decoration: const InputDecoration(
                        filled: true,
                        hintStyle: TextStyle(color: AppColors.greyColor),
                        hintText: 'Enter body',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                  if (isTypeLink)
                    TextField(
                      maxLines: 5,
                      controller: linkController,
                      style: TextStyle(
                        color: currentTheme.textTheme.bodyMedium!.color!,
                      ),
                      decoration: const InputDecoration(
                        filled: true,
                        hintStyle: TextStyle(color: AppColors.greyColor),
                        hintText: 'Enter link',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Select Community'),
                  ),
                  ref.watch(userCommunitiesProvider).when(
                        data: (data) {
                          communities = data;
                          if (data.isEmpty) {
                            return const SizedBox();
                          }
                          return DropdownButton(
                              value: selectedCommunity ?? data[0],
                              items: data
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(e.avatar),
                                            radius: 15,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(e.name),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedCommunity = val;
                                });
                              });
                        },
                        error: (error, stackTrace) =>
                            ErrorText(errorText: error.toString()),
                        loading: () => const Loader(),
                      ),
                ],
              ),
            ),
    );
  }
}
