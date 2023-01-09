import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/error.dart';
import 'package:latery/src/core/common/image_picker.dart';
import 'package:latery/src/core/common/loader.dart';
import 'package:latery/src/core/constants/constants.dart';
import 'package:latery/src/features/auth/controller/auth_controller.dart';
import 'package:latery/src/features/user_profile/controller/user_profile_controller.dart';
import 'package:latery/src/theme/colors.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? avatarFile;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
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

  void saveProfile() {
    ref.read(userProfileControllerProvider.notifier).editUserProfile(
        avatarFile: avatarFile,
        bannerFile: bannerFile,
        context: context,
        name: nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
        data: (user) => GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                backgroundColor: AppColors.blackColor,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: const Text('Edit Profile'),
                  centerTitle: false,
                  actions: [
                    TextButton(
                      onPressed: saveProfile,
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
                                            : user.banner.isEmpty ||
                                                    user.banner ==
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
                                                    user.banner,
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
                                                  NetworkImage(user.profilePic),
                                              radius: 32,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextField(
                              controller: nameController,
                              style:
                                  const TextStyle(color: AppColors.whiteColor),
                              decoration: InputDecoration(
                                filled: true,
                                hintStyle:
                                    const TextStyle(color: AppColors.greyColor),
                                hintText: 'Name',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.orangeColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(18),
                              ),
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
