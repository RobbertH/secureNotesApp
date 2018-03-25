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
        appBar: new AppBar(
          title: new Text("Notes"),
        ),
        drawer: _drawer(),
      ),
    );
  }

  Widget _homeScreen() {
    return new ListView(
      children: _buildListTiles(),
    );
  }

  List<ListTile> _buildListTiles(){
    List<ListTile> result = [];
    for (var i in [1,2,3]){
      result.add(new ListTile(
        title: new Text(i.toString()),
        subtitle: new Text("content here"),
        onTap: () => Navigator.of(context).pushNamed("/noteEditor/${i.toString()}"),
      ));
    }
    return result;
  }

  Widget _drawer() {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new ListTile(
            leading: new Icon(Icons.library_books),
            title: new Text("aj"),
            onTap: () => Navigator.of(context).pushNamed("/noteEditor/aj"),
          ),
          new ListTile(
            leading: new Icon(Icons.exit_to_app),
            title: new Text("Back"),
            //onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }



}