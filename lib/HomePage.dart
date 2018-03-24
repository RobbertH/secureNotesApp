import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }

}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Notes",
      home: new Scaffold(
        key: _scaffoldState,
        body: _homeScreen(),
      ),
    );
  }

  Widget _homeScreen() {
    return new Center(
      child: new Text("lol"),
    );
  }

}