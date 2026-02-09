import 'package:flutter/material.dart';
import 'package:pagnation_infinite/blocs/posts/posts_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagnation_infinite/post.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    context.read<PostBloc>().add(FetchPosts());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;

    final max = _controller.position.maxScrollExtent;
    final current = _controller.position.pixels;

    if (current >= max * 0.9) {
      context.read<PostBloc>().add(FetchPosts());
    }
  }

  /// Handles case when list is too small to scroll
  void _checkIfNeedMore(PostLoaded state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;

      if (_controller.position.maxScrollExtent == 0 &&
          !state.hasReachedEnd &&
          !state.isFetchingMore) {
        context.read<PostBloc>().add(FetchPosts());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              if (state is! PostLoaded) return const SizedBox();

              return PopupMenuButton<PostSortOrder>(
                icon: const Icon(Icons.sort),
                initialValue: state.sortOrder,
                onSelected: (value) {
                  context.read<PostBloc>().add(ChangePostSort(value));
                  _controller.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: PostSortOrder.newestFirst,
                    child: Text('Newest first'),
                  ),
                  PopupMenuItem(
                    value: PostSortOrder.oldestFirst,
                    child: Text('Oldest first'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          // INITIAL LOADING
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR (first load)
          if (state is PostError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PostBloc>().add(FetchPosts());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // LOADED
          if (state is PostLoaded) {
            _checkIfNeedMore(state);

            // EMPTY STATE
            if (state.posts.isEmpty) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<PostBloc>().add(FetchPosts());
                  },
                  child: const Text('Retry'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostBloc>().add(RefreshPosts());
              },
              child: ListView.builder(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.posts.length + 1, // important
                itemBuilder: (context, index) {
                  debugPrint("TOTAL POST ${state.posts.length}");
                  // ---------------- POSTS ----------------
                  if (index < state.posts.length) {
                    final post = state.posts[index];
                    return MyCardWidget(post);
                  }

                  // ---------------- BOTTOM AREA ----------------

                  // Loading more
                  if (state.isFetchingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Pagination error → Retry button
                  if (state.paginationError != null) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<PostBloc>().add(FetchPosts());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ),
                    );
                  }

                  // Nothing else to load
                  return const SizedBox.shrink();
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // ---------------- CARD UI ----------------

  Widget MyCardWidget(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    post.id.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Post ID ${post.id}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  post.createdAt.toIso8601String().substring(0, 10),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "This is preview for ${post.id}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}