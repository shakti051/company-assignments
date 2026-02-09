import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagnation_infinite/blocs/posts/posts_bloc.dart';
import 'package:pagnation_infinite/post_repository.dart';
import 'package:pagnation_infinite/screens/post_page.dart';
import 'package:pagnation_infinite/services/dio_client.dart';

import 'services/service_locator.dart';

void main() {
  setupDependencies();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PostRepository>(
          create: (_) => PostRepository(
            sl<DioClient>().dio, // coming from GetIt
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<PostBloc>(
            create: (context) =>
                PostBloc(context.read<PostRepository>())..add(FetchPosts()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PostPage(),
    );
  }
}
