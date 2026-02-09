import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pagnation_infinite/post.dart';
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

  Future<void> _fetchPosts(
    FetchPosts event,
    Emitter<PostState> emit,
  ) async {
    // 🛑 stop duplicate calls
    if (isFetching) return;

    final currentState = state;

    // 🛑 stop when end reached
    if (currentState is PostLoaded && currentState.hasReachedEnd) return;

    isFetching = true;

    final oldPosts =
        currentState is PostLoaded ? currentState.posts : <Post>[];

    // UI loading states
    if (currentState is PostLoaded) {
      emit(currentState.copyWith(isFetchingMore: true));
    } else {
      emit(PostLoading());
    }

    try {
      final newPosts =
          await repository.fetchPosts(start: start, limit: limit);

      start += limit;

      emit(
        PostLoaded(
          posts: [...oldPosts, ...newPosts],
          hasReachedEnd: newPosts.length < limit,
          isFetchingMore: false,
          paginationError: null,
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
    start = 0;
    isFetching = false;

    emit(PostLoading());

    try {
      final posts =
          await repository.fetchPosts(start: start, limit: limit);

      start += limit;

      emit(
        PostLoaded(
          posts: posts,
          hasReachedEnd: posts.length < limit,
        ),
      );
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  void _changeSort(
    ChangePostSort event,
    Emitter<PostState> emit,
  ) {
    if (state is! PostLoaded) return;

    final current = state as PostLoaded;
    final sorted = List<Post>.from(current.posts);

    if (event.sortOrder == PostSortOrder.newestFirst) {
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    emit(
      current.copyWith(
        posts: sorted,
        sortOrder: event.sortOrder,
      ),
    );
  }
}
