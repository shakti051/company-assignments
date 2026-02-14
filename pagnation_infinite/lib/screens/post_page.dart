import 'package:flutter/material.dart';
import 'package:pagnation_infinite/blocs/posts/posts_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagnation_infinite/models/post.dart';
import 'dart:async';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    context.read<PostBloc>().add(FetchPosts());
  }

  void _onSearchChanged(String query) {
    setState(() {}); // update clear icon visibility
    debugPrint("value: $query");
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      debugPrint("Debounced value: $query");
      context.read<PostBloc>().add(SearchPosts(trimmed));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    debugPrint("Scrolling...");
    if (!_controller.hasClients) return;

    final position = _controller.position;

    debugPrint("Extent after: ${position.extentAfter}");

    if (position.extentAfter < 200) {
      debugPrint("Triggering pagination 🔥");
      context.read<PostBloc>().add(FetchPosts());
    }
  }

  // Handles case when list is too small to scroll
  void _checkIfNeedMore() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;

      final position = _controller.position;
      // If after adding new items we are still near bottom
      if (position.extentAfter < 300) {
        context.read<PostBloc>().add(FetchPosts());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostLoaded && state.failureMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failureMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search posts...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          setState(() {}); // refresh UI
                        },
                      )
                    : null,
              ),
            ),
          ),
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
              _checkIfNeedMore();

              // EMPTY STATE

              // 🔎 SEARCH - No results
              if (state.posts.isEmpty &&
                  !state.isFetchingMore &&
                  state.searchQuery.isNotEmpty) {
                return const Center(
                  child: Text(
                    "No results found",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              // 📄 Normal empty (only happens first time before fetch)
              if (state.posts.isEmpty && state.searchQuery.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PostBloc>().add(RefreshPosts());
                },
                child: ListView.builder(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      state.posts.length +
                      (state.isFetchingMore ? 1 : 0), // important
                  itemBuilder: (context, index) {
                    debugPrint("TOTAL POSTS: ${state.posts.length}");
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
      ),
    );
  }

  // ---------------- CARD UI ----------------

  Widget MyCardWidget(Post post) {
    final state = context.watch<PostBloc>().state;

    String query = '';
    if (state is PostLoaded) {
      query = state.searchQuery;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  child: highlightText(
                    post.title,
                    query,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  post.createdAt.toIso8601String().substring(0, 10),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    context.read<PostBloc>().add(LikePost(post.id));
                  },
                ),
              ],
            ),
            // Text(
            //   "This is preview for ${post.id}",
            //   style: const TextStyle(fontSize: 14),
            // ),
          ],
        ),
      ),
    );
  }

  Widget highlightText(String text, String query, {TextStyle? style}) {
    final baseStyle =
        style ?? const TextStyle(color: Colors.black, fontSize: 14);

    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);

      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: baseStyle.copyWith(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
    );
  }
}
