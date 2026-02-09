import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pagnation_infinite/post.dart';

class PostRepository {
  final Dio dio;

  PostRepository(this.dio);

  Future<List<Post>> fetchPosts({
    required int start,
    int limit = 100,
  }) async {
    final response = await dio.get(
      '/posts',
      queryParameters: {
        '_start': start,
        '_limit': limit,
      },
    );

    return (response.data as List)
        .map((e) => Post.fromJson(e))
        .toList();
  }
}