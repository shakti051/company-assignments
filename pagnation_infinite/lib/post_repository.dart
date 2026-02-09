import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pagnation_infinite/post.dart';

import 'package:dio/dio.dart';
import 'services/api_exception.dart';

class PostRepository {
  final Dio dio;

  PostRepository(this.dio);

  Future<List<Post>> fetchPosts({
    required int start,
    required int limit,
  }) async {
    try {
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
    } on DioException catch (e) {
      // SAFE call
      final error = e.error;
      if (error is ApiException) {
        throw error;
      }
      throw ApiException(message: 'Unexpected error occurred');
    }
  }
}