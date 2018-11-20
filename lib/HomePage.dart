import 'package:flutter/material.dart';
import 'dart:convert';
import 'notes.dart' as notes;

class HomePage extends StatefulWidget {

  HomePage(); // constructor

  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>(); // to show toasts
  static const Base64Codec base64 = const Base64Codec(); // to encode/decode base64

  HomePageState(); // constructor

  void _onFAB() async {
    // Ask notes module to make a new note for us and retrieve its ID
    int newID = await notes.makeNewNote();
    // Go to note editor to edit
    Navigator.of(context).pushNamed("/noteEditor/${newID.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    FutureBuilder futureBuilder = new FutureBuilder(
        future: notes.getNotesMap(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: new CircularProgressIndicator()
              );
            default:
              return Center(
                  child: _homeScreen(snapshot.data)
              );
          }
        }
    );

    return new MaterialApp(
      title: "Notes",
      home: new Scaffold(
        key: _scaffoldState,
        body: futureBuilder,
        appBar: new AppBar(
          title: new Text("Notes"),
          centerTitle: true,
        ),
        //drawer: _drawer(),
        floatingActionButton: new FloatingActionButton(
          onPressed: _onFAB,
          child: new Icon(Icons.add),
        ),
      ),
    );
  }


  Widget _homeScreen(Map<int, List<String>> notesMap) {
    return new ListView(
      children: _buildListTiles(notesMap),
    );
  }

  List<ListTile> _buildListTiles(Map<int, List<String>> notesMap){
    List<ListTile> result = [];
    notesMap.forEach(
        (noteID, lst) {
          result.add(new ListTile(
            title: new Text(lst[0]),
            subtitle: new Text(lst[1]),
            onTap: () => Navigator.of(context).pushNamed("/noteEditor/${noteID.toString()}"),
          ));
        });
    return result;
  }

  Widget _drawer() {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new ListTile(
            leading: new Icon(Icons.library_books),
            title: new Text("Do nothing"),
            onTap: (){}, // nothing
          ),
          new ListTile(
            leading: new Icon(Icons.exit_to_app),
            title: new Text("Back to login"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

}