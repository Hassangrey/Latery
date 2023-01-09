import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/error.dart';
import 'package:latery/src/core/common/image_picker.dart';
import 'package:latery/src/core/common/loader.dart';
import 'package:latery/src/core/constants/constants.dart';
import 'package:latery/src/features/communities/controller/community_controller.dart';
import 'package:latery/src/model/community_model.dart';
import 'package:latery/src/theme/colors.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? avatarFile;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    bioController = TextEditingController();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectAvatarImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        avatarFile = File(res.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
          avatarFile: avatarFile,
          bannerFile: bannerFile,
          context: context,
          community: community,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (data) => GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                backgroundColor: AppColors.blackColor,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: const Text('Edit Community'),
                  centerTitle: false,
                  actions: [
                    TextButton(
                      onPressed: () => save(data),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: AppColors.whiteColor),
                      ),
                    ),
                  ],
                ),
                body: isLoading
                    ? const Loader()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: selectBannerImage,
                                    child: DottedBorder(
                                      color: AppColors.whiteColor,
                                      radius: const Radius.circular(15),
                                      dashPattern: const [10, 4],
                                      strokeCap: StrokeCap.round,
                                      borderType: BorderType.RRect,
                                      child: Container(
                                        width: double.infinity,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: bannerFile != null
                                            ? Image.file(bannerFile!)
                                            : data.banner.isEmpty ||
                                                    data.banner ==
                                                        Constants.bannerDefault
                                                ? const Center(
                                                    child: Icon(
                                                      Icons.camera_alt_outlined,
                                                      size: 40,
                                                      color:
                                                          AppColors.whiteColor,
                                                    ),
                                                  )
                                                : Image.network(
                                                    data.banner,
                                                    fit: BoxFit.cover,
                                                  ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    left: 20,
                                    child: GestureDetector(
                                      onTap: selectAvatarImage,
                                      child: avatarFile != null
                                          ? CircleAvatar(
                                              backgroundImage:
                                                  FileImage(avatarFile!),
                                              radius: 32,
                                            )
                                          : CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(data.avatar),
                                              radius: 32,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextFormField(
                              initialValue: data.bio,
                              style:
                                  const TextStyle(color: AppColors.whiteColor),
                            )
                          ],
                        ),
                      ),
              ),
            ),
        error: ((error, stackTrace) => ErrorText(errorText: error.toString())),
        loading: () => const Loader());
  }
}
