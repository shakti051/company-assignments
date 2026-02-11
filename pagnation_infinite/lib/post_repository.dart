import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:pagnation_infinite/models/page.dart';
import 'package:pagnation_infinite/models/post.dart';
import 'services/api_exception.dart';

class PostRepository {
  final Dio dio;

  PostRepository(this.dio);

  Future<MyPage<Post>> fetchPosts({
    String? cursor,
    required int limit,
  }) async {
    try {
      // 🔹 Convert cursor to start index
      final start = cursor == null ? 0 : int.parse(cursor);

      // 🔹 Simulate network latency
      await Future.delayed(const Duration(milliseconds: 600));

      // 🔹 Simulate random failure
      if (DateTime.now().millisecondsSinceEpoch % 7 == 0) {
        throw Exception("Random network error");
      }

      final response = await dio.get(
        '/posts',
        queryParameters: {
          '_start': start,
          '_limit': limit,
        },
      );

      final posts = (response.data as List)
          .map((e) => Post.fromJson(e))
          .toList();

      // 🔹 Calculate next cursor
      final next = start + limit;

     
      return MyPage(
       items:  posts,
       nextCursor: posts.isEmpty ? null : next.toString(),
      );
    } on DioException catch (e) {
      final error = e.error;
      if (error is ApiException) {
        throw error;
      }
      throw ApiException(message: 'Unexpected error occurred');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}

