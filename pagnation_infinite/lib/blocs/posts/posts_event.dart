part of 'posts_bloc.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class FetchPosts extends PostEvent {}

class RefreshPosts extends PostEvent {}

class ChangePostSort extends PostEvent {
  final PostSortOrder sortOrder;

  const ChangePostSort(this.sortOrder);

  @override
  List<Object> get props => [sortOrder];
}