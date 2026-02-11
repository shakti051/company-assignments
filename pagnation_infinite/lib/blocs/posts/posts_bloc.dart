import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pagnation_infinite/models/post.dart';
import 'package:pagnation_infinite/post_repository.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository repository;
  static const int limit = 10;

  int start = 0;
  bool isFetching = false;

  PostBloc(this.repository) : super(PostInitial()) {
    on<FetchPosts>(_fetchPosts);
    on<RefreshPosts>(_refreshPosts);
    on<ChangePostSort>(_changeSort);
  }

  Future<void> _fetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    if (isFetching) return;

    final currentState = state;

    // 🛑 Stop when no more pages
    if (currentState is PostLoaded && currentState.nextCursor == null) {
      return;
    }

    isFetching = true;

    final oldPosts = currentState is PostLoaded ? currentState.posts : <Post>[];

    final cursor = currentState is PostLoaded ? currentState.nextCursor : null;

    final currentSortOrder = currentState is PostLoaded
        ? currentState.sortOrder
        : PostSortOrder.newestFirst;

    // 🔹 Loading state
    if (currentState is PostLoaded) {
      emit(currentState.copyWith(isFetchingMore: true));
    } else {
      emit(PostLoading());
    }

    try {
      final page = await repository.fetchPosts(cursor: cursor, limit: limit);

      // 🔹 Deduplicate
      final newItems = page.items
          .where((item) => !oldPosts.any((e) => e.id == item.id))
          .toList();

      // 🔥 Merge old + new
      final combined = [...oldPosts, ...newItems];

      // 🔥 Re-apply sorting
      switch (currentSortOrder) {
        case PostSortOrder.newestFirst:
          combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;

        case PostSortOrder.oldestFirst:
          combined.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
      }
      print("Next cursor: ${page.nextCursor}");
      print("Fetched items: ${page.items.length}");
      emit(
        PostLoaded(
          posts: combined,
          nextCursor: page.nextCursor,
          isFetchingMore: false,
          paginationError: null,
          sortOrder: currentSortOrder,
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
          posts: sortedPosts,
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
