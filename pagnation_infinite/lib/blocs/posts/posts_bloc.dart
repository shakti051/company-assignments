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
    on<FetchPosts>(_onFetchPosts);
    on<RefreshPosts>(_onRefreshPosts);
    on<ChangePostSort>((event, emit) {
      final currentState = state;
      if (currentState is! PostLoaded) return;
      final sortedPosts = List<Post>.from(currentState.posts);

      if (event.sortOrder == PostSortOrder.newestFirst) {
        sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        sortedPosts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }

      emit(
        currentState.copyWith(posts: sortedPosts, sortOrder: event.sortOrder),
      );
    });
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    if (isFetching) return;

    final currentState = state;
    if (currentState is PostLoaded && currentState.hasReachedEnd) return;

    isFetching = true;

    try {
      final currentPosts = currentState is PostLoaded
          ? currentState.posts
          : <Post>[];

      if (currentState is PostLoaded) {
        emit(currentState.copyWith(isFetchingMore: true));
      } else {
        emit(PostLoading());
      }

      final newPosts = await repository.fetchPosts(start: start, limit: limit);

      start += limit;

      emit(
        PostLoaded(
          posts: [...currentPosts, ...newPosts],
          hasReachedEnd: newPosts.length < limit,
          isFetchingMore: false,
          paginationError: null, // clear error
        ),
      );
    } catch (e) {
      if (state is PostLoaded) {
        final current = state as PostLoaded;
        emit(
          current.copyWith(
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

  Future<void> _onRefreshPosts(
    RefreshPosts event,
    Emitter<PostState> emit,
  ) async {
    try {
      start = 0;
      isFetching = false;

      emit(PostLoading());

      final posts = await repository.fetchPosts(start: start, limit: limit);

      start += limit;

      emit(PostLoaded(posts: posts, hasReachedEnd: posts.length < limit));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}
