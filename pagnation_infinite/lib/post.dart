class Post {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
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
}