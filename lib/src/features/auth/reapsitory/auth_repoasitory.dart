// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:latery/src/core/constants/constants.dart';
import 'package:latery/src/core/constants/firebase_constants.dart';
import 'package:latery/src/core/failure.dart';
import 'package:latery/src/core/providers/firebase_providers.dart';
import 'package:latery/src/core/type_defs.dart';
import 'package:latery/src/model/userdata_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  // (1) -- Private variables so we do not want them to be called ourside this class
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // We cannot assign final variables like 'this._auth;
  // (2) -- therefore we new instances and we assigned them to the final variables
  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FireBaseConstants.usersCollection);

  // * (4) -- use this to listen to any changes of the user (data, authunticated or not),
  Stream<User?> get authStateChange => _auth.authStateChanges();
  FutureEither<UserData> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // (3) -- Now that we created the account, we want to store it in our firebase
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      UserData userData;

      // * After the user signs in, we will take the info and store them in our database using UserData model
      // * We will check first, weather the user is new or not, so we do not reset the karma
      if (userCredential.additionalUserInfo!.isNewUser) {
        userData = UserData(
          uid: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? 'display_name',
          email: userCredential.user!.email!,
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          isAuthenticated: true,
          karma: 0,
          awards: ['til'],
        );

        // * Save them to our firebase since it is a new user
        await _users.doc(userData.uid).set(userData.toMap());

        // * If the user is not new, get the user data from the database since its already there
      } else {
        userData = await getUserData(userCredential.user!.uid).first;
      }
      return right(userData);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserData> getUserData(String uid) {
    return _users
        .doc(uid)
        .snapshots()
        .map((event) => UserData.fromMap(event.data() as Map<String, dynamic>));
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
