import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite/controllers/forum_controller.dart';
import 'package:infinite/models/post_model.dart';

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.50;
      if (maxScroll - currentScroll <= delta) {
        ref.read(fetchPostsProvider.notifier).fetchNextBatch();
      }
    });
    return Scaffold(
        floatingActionButton: ScrollToTopButton(scrollController: scrollController),
        body: CustomScrollView(
          controller: scrollController,
          restorationId: "post_list",
          slivers: const [
            SliverAppBar(
              title: Text("Infinite Scroll"),
              pinned: true,
              centerTitle: true,
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 20,
              ),
            ),
            PostList(),
            NoMorePosts(),
            OnGoingBottomWidget()
          ],
        ));
  }
}

class ScrollToTopButton extends StatelessWidget {
  const ScrollToTopButton({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: scrollController,
        builder: (context, child) {
          double scrollOffset = scrollController.offset;
          return scrollOffset > MediaQuery.of(context).size.height * 0.8
              ? FloatingActionButton(
                  onPressed: () async {
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundColor: Colors.blue,
                  tooltip: "En başa dön",
                  child: const Icon(
                    Icons.arrow_upward_sharp,
                  ),
                )
              : const SizedBox.shrink();
        });
  }
}

class PostList extends StatelessWidget {
  const PostList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(fetchPostsProvider);
      return state.when(
          data: (posts) {
            return posts.isEmpty
                ? const SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Text("No posts yet!"),
                      ],
                    ),
                  )
                : PostListBuilder(
                    posts: posts,
                  );
          },
          error: (e, stk) => const SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.error),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Something went wrong!",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
          loading: () => SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          onGoingLoading: (posts) => PostListBuilder(
                posts: posts,
              ),
          onGoingError: (posts, e, stk) => PostListBuilder(
                posts: posts,
              ));
    });
  }
}

class PostListBuilder extends ConsumerWidget {
  const PostListBuilder({
    super.key,
    required this.posts,
  });
  final List<Post> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ListTile(
            title: Text(
              posts[index].title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              posts[index].body,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.blue,
                  ),
                  onTap: () {
                    ref.read(forumControllerProvider).upvotePost(posts[index].id, context, index, ref);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  posts[index].totalVote.toString(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Colors.blue,
                  ),
                  onTap: () {
                    ref.read(forumControllerProvider).downvotePost(posts[index].id, context, index, ref);
                  },
                ),
              ],
            ),
          );
        },
        childCount: posts.length,
      ),
    );
  }
}

class OnGoingBottomWidget extends ConsumerWidget {
  const OnGoingBottomWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Consumer(
          builder: ((context, ref, child) {
            final state = ref.watch(fetchPostsProvider);
            return state.maybeWhen(
              orElse: () => const SizedBox.shrink(),
              onGoingLoading: (posts) => const Center(
                child: CircularProgressIndicator(),
              ),
              onGoingError: (posts, e, stk) => const Center(
                child: Column(
                  children: [
                    Icon(Icons.error),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Something went wrong!",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class NoMorePosts extends ConsumerWidget {
  const NoMorePosts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ;
    final state = ref.watch(fetchPostsProvider);
    return SliverToBoxAdapter(
      child: state.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          data: (items) {
            final noMoreItems = ref.read(fetchPostsProvider.notifier).noMorePosts;
            return noMoreItems
                ? const Padding(
                    padding: EdgeInsets.only(bottom: 10, top: 5),
                    child: Text(
                      "No More Posts!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
    );
  }
}
