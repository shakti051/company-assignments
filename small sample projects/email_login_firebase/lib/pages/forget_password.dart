import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'sign_up.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();

  var email = " ";

  final emailController = TextEditingController();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.amber,
          content: Text(
            ' Password Reset Email has been sent !',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        print(' No user found for that email ');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.amber,
            content: Text(
              ' No user found for that email ',
              style: TextStyle(fontSize: 18.0, color: Colors.amber),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(' Reset Password '),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              "images/forget.jpg",
              width: 240,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: const Text(
              ' Reset link will be send to your email ID',
              style: TextStyle(fontSize: 14.0),
            ),
          ),
          Expanded(
              child: Form(
            key: _formKey,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
              child: ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      autofocus: false,
                      decoration: const InputDecoration(
                        labelText: ' Email ',
                        labelStyle: TextStyle(
                          color: Colors.black26,
                          fontSize: 15.0,
                        ),
                      ),
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ' Please enter Email ';
                        } else if (!value.contains('@')) {
                          return 'Please enter valid email ';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                email = emailController.text;
                              });
                              resetPassword();
                            }
                          },
                          child: const Text(
                            ' Send email ',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            ' Login ',
                            style: TextStyle(fontSize: 13.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(' Do not have an account ?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, a, b) =>
                                      const SignUp(),
                                  transitionDuration:
                                      const Duration(seconds: 0),
                                ),
                                (route) => false);
                          },
                          child: const Text(' Signup '),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
