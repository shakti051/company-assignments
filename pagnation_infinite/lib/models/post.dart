class Post {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
   final bool isLiked;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isLiked =false
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;

    return Post(
      id: id,
      title: json['title'],
      body: json['body'],
      createdAt: DateTime.now().subtract(Duration(minutes: id))
    );
  }
  
  Post copyWith({
    bool? isLiked,
  }) {
    return Post(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}