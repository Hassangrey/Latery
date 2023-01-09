import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/error_snackbar.dart';
import 'package:latery/src/features/auth/reapsitory/auth_repoasitory.dart';
import 'package:latery/src/model/userdata_model.dart';

final userProvider = StateProvider<UserData?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

// * Provider to listen to the user changes, logged in, out, updated profile info
final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

// * We will use this provider to get the info of a certain user
// * it will be used when 1- We need the user info throughout the app
// * 2- to get the info of a certain user (when we enter their profile, in post info)
final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);

  return authController.getUserData(uid);
});

// ? We extends state notifier so we can now what is the state of this class, so we can show a loading screen.
class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signInWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInWithGoogle();
    state = false;
    // * Here is the code that replaced a second try & catch block
    user.fold(
      (fail) => showErrorSnackBar(context, fail.message),
      (user) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }

  Stream<UserData> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void logout() async {
    _authRepository.logOut();
  }
}
