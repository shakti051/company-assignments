part of 'posts_bloc.dart';

sealed class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class FetchPosts extends PostEvent {
  final bool reset;

 const FetchPosts({this.reset = false});
 
  @override
  List<Object> get props => [reset]; 
}


class RefreshPosts extends PostEvent {}

class ChangePostSort extends PostEvent {
  final PostSortOrder sortOrder;

  const ChangePostSort(this.sortOrder);

  @override
  List<Object> get props => [sortOrder];
}

class SearchPosts extends PostEvent {
  final String query;

 const SearchPosts(this.query);

  @override
  List<Object> get props => [query];
}

class LikePost extends PostEvent {
  final int postId;

 const LikePost(this.postId);
 
  @override
  List<Object> get props => [postId];
}