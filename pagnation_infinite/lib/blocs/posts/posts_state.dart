part of 'posts_bloc.dart';

enum PostSortOrder { newestFirst, oldestFirst }

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  final String? nextCursor;
  final bool isFetchingMore;
  final String? paginationError;
  final PostSortOrder sortOrder;

  const PostLoaded({
    required this.posts,
    required this.nextCursor,
    required this.isFetchingMore,
    required this.paginationError,
    required this.sortOrder,
  });

  PostLoaded copyWith({
    List<Post>? posts,
    String? nextCursor,
    bool? isFetchingMore,
    String? paginationError,
    PostSortOrder? sortOrder,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      nextCursor: nextCursor ?? this.nextCursor,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      paginationError: paginationError,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
    posts,
    nextCursor,
    isFetchingMore,
    paginationError,
    sortOrder,
  ];
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);
  @override
  List<Object> get props => [message];
}
