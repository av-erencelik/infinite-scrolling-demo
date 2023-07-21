import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:infinite/core/failure.dart';
import 'package:infinite/core/providers.dart';
import 'package:infinite/core/type_defs.dart';
import 'package:infinite/models/post_model.dart';

final forumRepositoryProvider = Provider((ref) {
  return ForumRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class ForumRepository {
  final FirebaseFirestore _firestore;
  ForumRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _posts => _firestore.collection("posts");

  FutureVoid createPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "something happened!"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<Post>> fetchPosts(Post? post) async {
    if (post == null) {
      final documentSnapshot = await _posts
          .orderBy(
            "createdAt",
            descending: false,
          )
          .limit(20)
          .get();
      return documentSnapshot.docs
          .map<Post>(
            (doc) => Post.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } else {
      final documentSnapshot = await _posts
          .orderBy(
            "createdAt",
            descending: false,
          )
          .startAfter(
            [post.createdAt.millisecondsSinceEpoch],
          )
          .limit(20)
          .get();
      return documentSnapshot.docs
          .map<Post>(
            (doc) => Post.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    }
  }

  FutureEither<Post> upvotePost(String postId) async {
    try {
      final postRef = _posts.doc(postId);
      await postRef.update({"totalVote": FieldValue.increment(1)});
      final postDoc = await postRef.get();
      return right(Post.fromMap(postDoc.data() as Map<String, dynamic>));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "something happened!"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<Post> downvotePost(String postId) async {
    try {
      final postRef = _posts.doc(postId);
      await postRef.update({"totalVote": FieldValue.increment(-1)});
      final postDoc = await postRef.get();
      return right(Post.fromMap(postDoc.data() as Map<String, dynamic>));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "something happened!"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
