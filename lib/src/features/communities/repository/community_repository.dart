import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:latery/src/core/constants/firebase_constants.dart';
import 'package:latery/src/core/failure.dart';
import 'package:latery/src/core/providers/firebase_providers.dart';
import 'package:latery/src/core/type_defs.dart';
import 'package:latery/src/model/community_model.dart';
import 'package:latery/src/model/post_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      // (2.1) -- Check if a community with the same name already exists ------ (Usually checking would be via uid, or any key you chose)
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Community with the same name already exists!';
      }
      // (2.2) -- Create the community, DONE
      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityId, String uid) async {
    try {
      return right(_communities.doc(communityId).update({
        'members': FieldValue.arrayUnion([uid]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityId, String uid) async {
    try {
      return right(_communities.doc(communityId).update({
        'members': FieldValue.arrayRemove([uid]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // (3.0) -- Get the user community, stream so it updates
  Stream<List<Community>> getUserCommunities(String uid) {
    // (3.1) -- We will go to the communities and check which communities is this user enrolled in, then we return them
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  // (4.0) -- Make a function to retrieve the data of 1 community (Name is also the id of the community)
  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // (5.0) -- Search query (communities) implementation
  Stream<List<Community>> searchCommunity(String query) {
    // (5.1) -- So first, we will return the result where the name of the community:
    // (5.2) -- If it is empty(query.isEmpty ? 0), return nothing  (otherwise it will return ALL the communities)
    // (5.3) -- if there is something typed, return all the suggestions where it is equal OR greater than the search
    // (5.3.1) --- If the user searched for 'me' all the communities that starts with that query will be shown. e.g., 'r/mems'
    // (5.4) -- The second condition, is what will show all the strings that starts with '0' and end with the length of the query typed (5.3.1 basically).
    // (5.5) -- IDK. it's too complicated to figure it out but it works
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities
            .add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _posts
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  // (1.0) -- Private variable so we do not access it outside of this repo
  CollectionReference get _communities =>
      _firestore.collection(FireBaseConstants.communitiesCollection);
  CollectionReference get _posts =>
      _firestore.collection(FireBaseConstants.postsCollection);
}
