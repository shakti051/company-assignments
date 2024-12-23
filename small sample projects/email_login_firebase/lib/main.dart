import 'package:email_login_firebase/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Email & Password',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const LoginPage(),
        );
      },
    );
  }
}
