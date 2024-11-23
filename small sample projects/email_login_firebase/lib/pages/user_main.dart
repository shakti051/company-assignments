import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../user/change_pass.dart';
import '../user/dashboard.dart';
import '../user/profile.dart';


class UserMain extends StatefulWidget {
  const UserMain({super.key});

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {
  
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
     DashboardPage(),
     Profile(),
     ChangePass(),
  ];
  
  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: ' Dashboard ',),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: ' Profile ',),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: ' Change Password ',),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}