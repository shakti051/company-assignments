part of 'posts_bloc.dart';

enum PostSortOrder {
  newestFirst,
  oldestFirst,
}

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  final bool hasReachedEnd;
  final bool isFetchingMore;
  final String? paginationError;
  final PostSortOrder sortOrder;

  const PostLoaded({
    required this.posts,
    required this.hasReachedEnd,
    this.isFetchingMore = false,
    this.paginationError,
    this.sortOrder = PostSortOrder.newestFirst,
  });

  PostLoaded copyWith({
    List<Post>? posts,
    bool? hasReachedEnd,
    bool? isFetchingMore,
    String? paginationError,
    PostSortOrder? sortOrder,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      paginationError: paginationError,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props =>[posts, hasReachedEnd, isFetchingMore, paginationError,sortOrder];
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);
  @override
  List<Object> get props => [message];
}
