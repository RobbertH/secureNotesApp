import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// TODO: encrypt notes and their titles
// decrypt all titles (seperate file), to build the listView
// decrypt note (seperate file per note) only when clicked on the respective listTile
// TODO: switch from sharedprefs to files (better for exporting & encrypting)

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>();
  Set<String> _noteIDs = new Set();

  @override
  void initState() {
    super.initState();
    _loadIDsFromMemory();
  }

  void _loadIDsFromMemory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState( () => _noteIDs = new Set.from(prefs.getStringList("noteIDs")) ?? new Set());
  }

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
        floatingActionButton: new FloatingActionButton(
          onPressed: _makeNewNote,
          child: new Icon(Icons.add),
        ),
      ),
    );
  }

  void _makeNewNote() async {
    // TODO: this whole thing is not right. If + button is pressed,
    // TODO should go to new note immediately and don't care about titles until later. Also app needs to take care of IDs.
    // TODO Use date or increasing counter for IDs.
    // So onFloatingButtonPress:
    // Make new note
    //    Get sharedprefs
    //    Make new ID
    //    Add the ID to sharedprefs and maybe to the page builder
    // Navigate to new note
    debugPrint("new note!");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //int lastID = 0;
    int lastID = prefs.getInt("lastID") ?? 0;
    int newID = lastID + 1;
    _noteIDs.add(newID.toString());
    debugPrint(_noteIDs.toString());
    prefs.setInt("lastID", newID);
    prefs.setStringList("noteIDs", _noteIDs.toList());
    Navigator.of(context).pushNamed("/noteEditor/${newID.toString()}");
  }

  void _saveNewNoteID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("noteIDs", _noteIDs.toList());
  }
  
  Widget _homeScreen() {
    return new ListView(
      children: _buildListTiles(),
    );
  }

  List<ListTile> _buildListTiles(){
    List<ListTile> result = [];
    for (String noteID in _noteIDs){
      result.add(new ListTile(
        title: new Text(noteID),
        subtitle: new Text("content here"),
        onTap: () => Navigator.of(context).pushNamed("/noteEditor/${noteID.toString()}"),
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