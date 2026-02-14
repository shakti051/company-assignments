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
  // 👇 NEW
  final String searchQuery;
  final bool hasReachedEnd;
  final String? failureMessage;

  const PostLoaded({
    required this.posts,
    required this.nextCursor,
    required this.isFetchingMore,
    required this.paginationError,
    required this.sortOrder,
    this.hasReachedEnd = false,
    this.searchQuery = '',
    this.failureMessage
  });

  PostLoaded copyWith({
    List<Post>? posts,
    String? nextCursor,
    bool? isFetchingMore,
    String? paginationError,
    PostSortOrder? sortOrder,
    String? searchQuery,
    bool? hasReachedEnd,
    String? failureMessage
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      nextCursor: nextCursor ?? this.nextCursor,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      paginationError: paginationError ?? this.paginationError,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      failureMessage: failureMessage
    );
  }

  @override
  List<Object?> get props => [
    posts,
    nextCursor,
    isFetchingMore,
    paginationError,
    sortOrder,
    searchQuery,
    hasReachedEnd,
    failureMessage
  ];
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);
  @override
  List<Object> get props => [message];
}
