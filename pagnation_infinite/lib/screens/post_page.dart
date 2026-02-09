import 'package:flutter/material.dart';
import 'package:pagnation_infinite/blocs/posts/posts_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    // initial load
    context.read<PostBloc>().add(FetchPosts());
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;

    final position = _controller.position;

    if (position.atEdge && position.pixels != 0) {
      context.read<PostBloc>().add(FetchPosts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Posts'),
      actions: [
         BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is! PostLoaded) return const SizedBox();

        return PopupMenuButton<PostSortOrder>(
          icon: const Icon(Icons.sort),
          initialValue: state.sortOrder,
          onSelected: (value) {
            context.read<PostBloc>().add(ChangePostSort(value));
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
          if (state is PostLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is PostLoaded) {
            // ✅ EMPTY STATE
            if (state.posts.isEmpty && !state.isFetchingMore) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No posts yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pull down to refresh or try again later',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<PostBloc>().add(FetchPosts());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            // ✅ NORMAL LIST + PAGINATION
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<PostBloc>().add(RefreshPosts());
                  },
                  child: ListView.builder(
                    controller: _controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      debugPrint("Total POST ${state.posts.length}");
                      return ListTile(
                        title: Text(post.title),
                        subtitle: Text(post.body),
                        trailing: Text(
                          post.createdAt.toIso8601String(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),

                // CENTER LOADER
                if (state.isFetchingMore || state.paginationError != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      minimum: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              offset: Offset(0, 2),
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        child: state.isFetchingMore
                            ? const SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : TextButton.icon(
                                onPressed: () {
                                  context.read<PostBloc>().add(FetchPosts());
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                      ),
                    ),
                  ),
              ],
            );
          }
          if (state is PostError) {
            return Center(child: Text(state.message));
          }

          return SizedBox();
        },
      ),
    );
  }
}
