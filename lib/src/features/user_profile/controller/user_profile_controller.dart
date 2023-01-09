import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/error_snackbar.dart';
import 'package:latery/src/core/enums/enums.dart';
import 'package:latery/src/core/providers/storage_repo_provider.dart';
import 'package:latery/src/features/auth/controller/auth_controller.dart';
import 'package:latery/src/features/user_profile/repository/user_profile_repo.dart';
import 'package:latery/src/model/post_model.dart';
import 'package:latery/src/model/userdata_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(firebaseStorageProvider);
  return UserProfileController(
      userProfileRepository: userProfileRepository,
      ref: ref,
      storageRepository: storageRepository);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void editUserProfile({
    required File? avatarFile,
    required File? bannerFile,
    required BuildContext context,
    required String name,
  }) async {
    UserData user = _ref.read(userProvider)!;
    state = true;
    if (avatarFile != null) {
      // communities/avatar/memes
      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: avatarFile,
      );
      res.fold(
        (l) => showErrorSnackBar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }
    if (bannerFile != null) {
      // communities/banner/memes
      final res = await _storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
      );
      res.fold(
        (l) => showErrorSnackBar(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }
    user = user.copyWith(name: name);
    final res = await _userProfileRepository.editUserProfile(user);
    state = false;
    res.fold((l) => showErrorSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      Routemaster.of(context).pop();
    });
  }

  void updateUserKarma(UserKarma karma) async {
    UserData user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);
    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }
}
