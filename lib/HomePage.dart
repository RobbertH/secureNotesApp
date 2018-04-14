import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// TODO: encrypt notes and their titles
// decrypt all titles (seperate file), to build the listView
// decrypt note (seperate file per note) only when clicked on the respective listTile
// TODO: switch from sharedprefs to files (better for exporting & encrypting)
// TODO: sharedpreferences is super wrong! use files!
// TODO: implement export feature: without encryption (plain) / without salt / with everything (and release salt to user)

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  // DECLARATIONS
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>();

  final _storage = new FlutterSecureStorage(); // to securely store the salt
  String _randomKey = "Unknown";
  String _string = "Unknown";
  String _encrypted = "Unknown";

  Set<String> _noteIDs = new Set();

  @override
  initState() {
    super.initState();
    _initPlatformState();
    _loadIDsFromMemory();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  _initPlatformState() async {
    final PlatformStringCryptor cryptor = new PlatformStringCryptor();

    final String key = await cryptor.generateRandomKey();
    debugPrint("randomKey: $key");

    final String string = "here is the string, here is the string.";
    final String encrypted = await cryptor.encrypt(string, key);
    final String decrypted = await cryptor.decrypt(encrypted, key);

    assert(decrypted == string);

    final String userSuppliedKey =
        "jIkj0VOLhFpOJSpI7SibjA==:RZ03+kGZ/9Di3PT0a3xUDibD6gmb2RIhTVF+mQfZqy0=";

    try {
      await cryptor.decrypt(encrypted, userSuppliedKey);
    } on MacMismatchException {
      debugPrint("wrongly decrypted");
    }

    final salt = "Ee/aHwc6EfEactQ00sm/0A=="; // await cryptor.generateSalt();
    final password = "a_strong_password%./😋";
    final generatedKey = await cryptor.generateKeyFromPassword(password, salt);
    debugPrint("salt: $salt, key: $generatedKey");

    assert(generatedKey == userSuppliedKey);

    setState(() {
      _randomKey = key;
      _string = string;
      _encrypted = encrypted;
    });
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