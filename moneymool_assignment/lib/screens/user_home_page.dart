import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneymool_assignment/controllers/user_controller.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  
  List data = [
    {"user_id": 123, "name": "Krishna", "role": "admin", "city": "Delhi"},
    {"user_id": 123, "name": "Krishna", "role": "user", "city": "Delhi"},
    {"user_id": 124, "name": "Krishna A", "role": "admin", "city": "Delhi"},
    {"user_id": 125, "name": "Krishna B", "role": "user", "city": "Mumbai"},
    {"user_id": 126, "name": "Krishna C", "role": "admin", "city": "Jaipur"},
    {"user_id": 127, "name": "Krishna  D", "role": "user", "city": "Kolkata"}
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Table(
            
            border: TableBorder.all(width: 2, color: Colors.grey),
            children: List.generate(
              data.length,
              (index) => TableRow(children: [
                Text(data[index]["name"]),
                Text(data[index]["city"]),
                Text(data[index]["role"]),
              ]),
            ),
          )),
    );
  }
}
