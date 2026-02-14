import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pagnation_infinite/models/post.dart';
import 'package:pagnation_infinite/post_repository.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository repository;
  static const int limit = 20;

  int start = 0;
  bool isFetching = false;
    
  PostBloc(this.repository) : super(PostInitial()) {
    on<FetchPosts>(_fetchPosts);
    on<RefreshPosts>(_refreshPosts);
    on<ChangePostSort>(_changeSort);
    on<SearchPosts>(_onSearchPosts);
    on<LikePost>(_onLikePost);    
  }


  Future<void> _onLikePost(
  LikePost event,
  Emitter<PostState> emit,
) async {
  if (state is! PostLoaded) return;

  final currentState = state as PostLoaded;

  final updatedPosts = currentState.posts.map((post) {
    if (post.id == event.postId) {
      return post.copyWith(isLiked: !post.isLiked);
    }
    return post;
  }).toList();

  // ✅ Optimistic update
  emit(currentState.copyWith(posts: updatedPosts, failureMessage: null));

  try {
    await Future.delayed(const Duration(seconds: 1));

    final isFailure = DateTime.now().millisecond % 2 == 0;

    if (isFailure) {
      throw Exception("API Failed");
    }

  } catch (e) {
    // ❌ Rollback
    emit(currentState.copyWith(
      failureMessage: "Failed to like post. Please try again.",
    ));
  }
}
  Future<void> _onSearchPosts(
  SearchPosts event,
  Emitter<PostState> emit,
) async {
  if (state is! PostLoaded) return;

  final currentState = state as PostLoaded;
  final query = event.query.trim(); // ✅ important

  // If query is empty → reset
  if (query.isEmpty) {
    emit(
      currentState.copyWith(
        searchQuery: '',
        posts: [],
        hasReachedEnd: false,
        paginationError: null,
      ),
    );

    add(FetchPosts(reset: true));
    return;
  }

  // Perform search
  emit(
    currentState.copyWith(
      searchQuery: query, // ✅ always use trimmed query
      posts: [],
      hasReachedEnd: false,
      paginationError: null,
      isFetchingMore: false,
    ),
  );

  add(FetchPosts(reset: true));
}

  Future<void> _fetchPosts(
  FetchPosts event,
  Emitter<PostState> emit,
) async {
  
  // ✅ Allow reset even if already fetching
  if (isFetching && !event.reset) return;

  final currentState = state;

  String? cursor;
  List<Post> oldPosts = [];
  PostSortOrder currentSortOrder = PostSortOrder.newestFirst;
  String? searchQuery;

  if (currentState is PostLoaded) {
    searchQuery = currentState.searchQuery; // ✅ get latest query
    currentSortOrder = currentState.sortOrder;

    if (event.reset) {
      cursor = null;
      oldPosts = [];
    } else {
      if (currentState.nextCursor == null) return;

      cursor = currentState.nextCursor;
      oldPosts = currentState.posts;

      emit(currentState.copyWith(
        isFetchingMore: true,
        paginationError: null,
      ));
    }
  } else {
    emit(PostLoading());
  }

  isFetching = true;

  try {
    final page = await repository.fetchPosts(
      cursor: cursor,
      limit: limit,
      query: (searchQuery == null || searchQuery.isEmpty)
          ? null
          : searchQuery,
    );

    final newItems = page.items
        .where((item) => !oldPosts.any((e) => e.id == item.id))
        .toList();

    final combined = [...oldPosts, ...newItems];

    switch (currentSortOrder) {
      case PostSortOrder.newestFirst:
        combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case PostSortOrder.oldestFirst:
        combined.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    emit(
      PostLoaded(
        posts: combined,
        nextCursor: page.nextCursor,
        isFetchingMore: false,
        paginationError: null,
        sortOrder: currentSortOrder,
        searchQuery: searchQuery ?? '',
      ),
    );
  } catch (e) {
    if (currentState is PostLoaded) {
      emit(
        currentState.copyWith(
          isFetchingMore: false,
          paginationError: e.toString(),
        ),
      );
    } else {
      emit(PostError(e.toString()));
    }
  } finally {
    isFetching = false;
  }
}
  // Future<void> _fetchPosts(FetchPosts event, Emitter<PostState> emit) async {
  //   // 🛑 Prevent duplicate calls
  //   if (isFetching) return;

  //   final currentState = state;

  //   String? cursor;
  //   List<Post> oldPosts = [];
  //   PostSortOrder currentSortOrder = PostSortOrder.newestFirst;
  //   String searchQuery = '';

  //   if (currentState is PostLoaded) {
  //     // ✅ If reset → start fresh
  //     if (event.reset) {
  //       cursor = null;
  //       oldPosts = [];
  //     } else {
  //       // 🛑 Stop if no more pages
  //       if (currentState.nextCursor == null) return;

  //       cursor = currentState.nextCursor;
  //       oldPosts = currentState.posts;
  //     }

  //     currentSortOrder = currentState.sortOrder;
  //     searchQuery = currentState.searchQuery;

  //     emit(currentState.copyWith(isFetchingMore: true, paginationError: null));
  //   } else {
  //     // First load
  //     emit(PostLoading());
  //   }

  //   isFetching = true;

  //   try {
  //     final page = await repository.fetchPosts(
  //       cursor: cursor,
  //       limit: limit,
  //       query: searchQuery.isEmpty ? null : searchQuery
  //     );

  //     // 🔹 Deduplicate
  //     final newItems = page.items
  //         .where((item) => !oldPosts.any((e) => e.id == item.id))
  //         .toList();

  //     // 🔹 Merge
  //     final combined = [...oldPosts, ...newItems];

  //     // 🔹 Apply sorting
  //     switch (currentSortOrder) {
  //       case PostSortOrder.newestFirst:
  //         combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  //         break;
  //       case PostSortOrder.oldestFirst:
  //         combined.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //         break;
  //     }

  //     emit(
  //       PostLoaded(
  //         posts: combined,
  //         nextCursor: page.nextCursor,
  //         isFetchingMore: false,
  //         paginationError: null,
  //         sortOrder: currentSortOrder,
  //         searchQuery: searchQuery, // ✅ IMPORTANT
  //       ),
  //     );
  //   } catch (e) {
  //     if (currentState is PostLoaded) {
  //       emit(
  //         currentState.copyWith(
  //           isFetchingMore: false,
  //           paginationError: e.toString(),
  //         ),
  //       );
  //     } else {
  //       emit(PostError(e.toString()));
  //     }
  //   } finally {
  //     isFetching = false;
  //   }
  // }


  Future<void> _refreshPosts(
    RefreshPosts event,
    Emitter<PostState> emit,
  ) async {
    isFetching = false;

    // 🔥 Preserve current sort order
    final currentSortOrder = state is PostLoaded
        ? (state as PostLoaded).sortOrder
        : PostSortOrder.newestFirst;

    emit(PostLoading());

    try {
      final page = await repository.fetchPosts(cursor: null, limit: limit);

      final sortedPosts = List<Post>.from(page.items);

      // 🔥 Apply sorting before emitting
      switch (currentSortOrder) {
        case PostSortOrder.newestFirst:
          sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;

        case PostSortOrder.oldestFirst:
          sortedPosts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
      }

      emit(
        PostLoaded(
          posts: sortedPosts, //
          nextCursor: page.nextCursor,
          isFetchingMore: false,
          paginationError: null,
          sortOrder: currentSortOrder, // ✅ preserve
        ),
      );
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  void _changeSort(ChangePostSort event, Emitter<PostState> emit) {
    if (state is! PostLoaded) return;

    final current = state as PostLoaded;
    final sorted = List<Post>.from(current.posts);

    if (event.sortOrder == PostSortOrder.newestFirst) {
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    emit(current.copyWith(posts: sorted, sortOrder: event.sortOrder));
  }
}
