import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // TODO get rid of this

// TODO: encrypt notes and their titles
// decrypt all titles (seperate file), to build the listView
// decrypt note (seperate file per note) only when clicked on the respective listTile

// TODO: switch from sharedprefs to files (better for exporting & encrypting)
// TODO: sharedpreferences is super wrong! use files!

// TODO: implement export feature: without encryption (plain) / without salt / with everything (and release salt to user)

// TODO: is it possible to 'ask' the loginpage to decrypt the notes?
// TODO: otherwise, just pass the key that was generated from the password (via the Constructor) -> seems like a bad idea
// TODO: I think we might be able to create a separate class that handles decryption and encryption. But would that
// TODO: make it better? You still pass it the password or key in the constructor :(

// TODO: I don't think any of this matters. The _userSuppliedPassword is a variable in LoginPage, so
// TODO: if a hacker could intercept a constructor, he could as well intercept the _userSuppliedPassword. Just pass it.

class HomePage extends StatefulWidget {

  String _userSuppliedKey;
  List<String> _noteTitles;

  HomePage(_userSuppliedKey, _NoteTitles); // constructor

  @override
  State<StatefulWidget> createState() {
    //debugPrint(_userSuppliedKey); // TODO start coding here. WHY THE FUCK DOES PRINTING A VARIABLE RESULT IN AN ERROR?
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {

  String _userSuppliedKey = "nog niet gezet";
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>(); // to show toasts
  final _storage = new FlutterSecureStorage(); // to securely store the salt
  Set<String> _noteIDs = new Set();

  //HomePageState(this._userSuppliedKey); // constructor

  @override
  initState() {
    super.initState();
    _initPlatformState();
    _loadIDsFromMemory();
    debugPrint("this is the key we received:");
    debugPrint(_userSuppliedKey);
    debugPrint("bfore tryme");
    tryme();
    debugPrint("after tryme");
  }

  _initPlatformState() async { // TODO is this not working or something?
    final PlatformStringCryptor cryptor = new PlatformStringCryptor();
    final String _salt = await _storage.read(key: "salt");
    final String _password = await _storage.read(key: "password"); // TODO: is this a good idea?
    // TODO: Think about passing the notes themselves, or asking LoginPage to do the decrypting

    final String _generatedKey = await cryptor.generateKeyFromPassword(_password, _salt);
    debugPrint(_generatedKey);
  }

  tryme() async {
    debugPrint("terrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
    writeTitles("title 1\$ title 2\$ title 3");
    debugPrint("wrote titels");
    var lol = await readTitles();
    debugPrint(lol);
  }

  void _loadIDsFromMemory() async { // TODO fix this!!!!! test this!!!!!
    String _noteIDsString = await readTitles();
    String separator = "\$";
    debugPrint("about to split diz");
    debugPrint(_noteIDsString);
    List<String> _noteIDsList = _noteIDsString.split(separator);
    setState( () => _noteIDs = new Set.from(_noteIDsList) ?? new Set());
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
    debugPrint("new note!");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int lastID = prefs.getInt("lastID") ?? 0;
    int newID = lastID + 1;
    _noteIDs.add(newID.toString());
    debugPrint(_noteIDs.toString());
    prefs.setInt("lastID", newID);
    prefs.setStringList("noteIDs", _noteIDs.toList());
    Navigator.of(context).pushNamed("/noteEditor/${newID.toString()}");
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
            onTap: readTitles,
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

  void writeTitles(String titles) async {
    final path = (await getApplicationDocumentsDirectory()).path;
    final file = new File('$path/note_titles.txt');
    file.writeAsString('$titles'); // Write the file
}

  Future<String> readTitles() async {
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      final file = new File('$path/note_titles.txt');
      String contents = await file.readAsString(); // Read the file
      debugPrint("he");
      debugPrint(contents);
      return contents;
    }
    catch (e) { // No file yet
      debugPrint("er");
      return ""; // If we encounter an error, return empty str
    }
  }


}