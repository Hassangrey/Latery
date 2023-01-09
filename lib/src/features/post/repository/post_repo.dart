import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:latery/src/core/constants/firebase_constants.dart';
import 'package:latery/src/core/failure.dart';
import 'package:latery/src/core/providers/firebase_providers.dart';
import 'package:latery/src/core/type_defs.dart';
import 'package:latery/src/model/comment_model.dart';
import 'package:latery/src/model/community_model.dart';
import 'package:latery/src/model/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firestore: ref.watch(firestoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    // * We will grap the communities by their names, and we will order them by their date of creation
    // * Then, we will get them from database and return them as a list
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upvote(Post post, String uid) async {
    // * We check first if the user has downvoted, we remove that downvote and then we add the upvote
    // * If the user wants to remove the upvote, they can click again on the upvote arrow to remove it (neither up nor downvote will be counted)
    // * Else, just add an upvote to the array
    if (post.downvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([uid]),
      });
    }
    if (post.upvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([uid]),
      });
    } else {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  void downvote(Post post, String uid) async {
    if (post.upvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([uid]),
      });
    }
    if (post.downvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([uid]),
      });
    } else {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  // ? -------------- Comments Functions --------------
  Stream<Post> getPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());

      return right(_posts.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getPostComments(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  CollectionReference get _comments =>
      _firestore.collection(FireBaseConstants.commentsCollection);
  CollectionReference get _posts =>
      _firestore.collection(FireBaseConstants.postsCollection);
}
