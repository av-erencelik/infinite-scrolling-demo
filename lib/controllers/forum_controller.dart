import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite/core/pagination_state.dart';
import 'package:infinite/models/post_model.dart';
import 'package:infinite/repositories/forum_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:infinite/core/utils.dart';

final forumControllerProvider = Provider((ref) {
  return ForumController(
    forumRepository: ref.watch(forumRepositoryProvider),
    ref: ref,
  );
});

final fetchPostsProvider = StateNotifierProvider<PaginationNotifier<Post>, PaginationState<Post>>((ref) {
  return PaginationNotifier(
    fetchNextPosts: (post) {
      return ref.read(forumControllerProvider).fetchPosts(post);
    },
    postsPerBatch: 20,
  )..init();
});

class PaginationNotifier<T> extends StateNotifier<PaginationState<T>> {
  PaginationNotifier({
    required this.fetchNextPosts,
    required this.postsPerBatch,
  }) : super(const PaginationState.loading());
  final Future<List<T>> Function(T? lastPost) fetchNextPosts;
  final int postsPerBatch;

  Timer _timer = Timer(const Duration(milliseconds: 0), () {});
  bool noMorePosts = false;

  final List<T> _posts = [];

  void init() {
    if (_posts.isEmpty) {
      fetchFirstBatch();
    }
  }

  void updateData(List<T> result) {
    noMorePosts = result.length < postsPerBatch;
    if (result.isEmpty) {
      state = PaginationState.data(_posts);
    } else {
      state = PaginationState.data(_posts..addAll(result));
    }
  }

  void updateOnePost(T post, int index) {
    _posts[index] = post;
    state = PaginationState.data(_posts);
  }

  Future<void> fetchFirstBatch() async {
    try {
      state = const PaginationState.loading();
      final List<T> result = _posts.isEmpty ? await fetchNextPosts(null) : await fetchNextPosts(_posts.last);
      updateData(result);
    } catch (e, stk) {
      state = PaginationState.error(e, stk);
    }
  }

  Future<void> fetchNextBatch() async {
    if (_timer.isActive) {
      return;
    }
    if (noMorePosts) {
      return;
    }
    _timer = Timer(const Duration(milliseconds: 1000), () {});

    if (state == PaginationState<T>.onGoingLoading(_posts)) {
      return;
    }
    state = PaginationState.onGoingLoading(_posts);

    try {
      await Future.delayed(const Duration(seconds: 1));
      final result = await fetchNextPosts(_posts.last);
      updateData(result);
    } catch (e, stk) {
      state = PaginationState.onGoingError(_posts, e, stk);
    }
  }
}

class ForumController {
  final ForumRepository _forumRepository;

  ForumController({
    required ForumRepository forumRepository,
    required Ref ref,
  })  : _forumRepository = forumRepository,
        super();

  void createPost({required String title, required String body, required BuildContext context}) async {
    String postId = const Uuid().v4();
    final Post post = Post(
      id: postId,
      title: title,
      body: body,
      totalVote: 0,
      createdAt: DateTime.now(),
    );
    final response = await _forumRepository.createPost(post);
    response.fold(
      (failure) => showSnackBar(context, failure.message),
      (_) => showSnackBar(context, "Post created successfully!"),
    );
  }

  Future<List<Post>> fetchPosts(Post? post) async {
    return await _forumRepository.fetchPosts(post);
  }

  void upvotePost(String postId, BuildContext context, int index, WidgetRef ref) async {
    final res = await _forumRepository.upvotePost(postId);
    res.fold(
      (e) => showSnackBar(context, e.message),
      (post) => ref.read(fetchPostsProvider.notifier).updateOnePost(post, index),
    );
  }

  void downvotePost(String postId, BuildContext context, int index, WidgetRef ref) async {
    final res = await _forumRepository.downvotePost(postId);
    res.fold(
      (e) => showSnackBar(context, e.message),
      (post) => ref.read(fetchPostsProvider.notifier).updateOnePost(post, index),
    );
  }
}
