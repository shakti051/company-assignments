import 'package:flutter/cupertino.dart';


class DashboardPage extends StatefulWidget {

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Image.asset("images/dashboard.png"),
      ),
    );
  }
}
