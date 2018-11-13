import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // TODO get rid of this
import 'dart:math';

// TODO: encrypt notes and their titles
// decrypt all titles (seperate file), to build the listView
// decrypt note (seperate file per note) only when clicked on the respective listTile => handled in NoteEditor

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

  HomePage(this._userSuppliedKey); // constructor

  @override
  State<StatefulWidget> createState() {
    return new HomePageState(_userSuppliedKey);
  }
}

class HomePageState extends State<HomePage> {

  Map<int, List<String>> _noteTitlesAndIDs = new Map<int, List<String>>(); // e.g. {5: ["note title 1", "content short"]}
  String _noteTitlesAndIDsDecrypted = ""; // as a string
  String _noteTitlesAndIDsEncrypted = ""; // ready to store

  String _userSuppliedKey;
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>(); // to show toasts
  final PlatformStringCryptor _cryptor = new PlatformStringCryptor();

  HomePageState(this._userSuppliedKey); // constructor

  @override
  initState() {
    super.initState();
    // load, decrypt and parse {IDs: titles and content previews} to display in ListView
    _loadIDsFromMemory();

    debugPrint("this is the key we received:");
    debugPrint(_userSuppliedKey);
    debugPrint(_noteTitlesAndIDs.toString());
  }

  void _loadIDsFromMemory() async {
    // Read encrypted file with titles and ids
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      final file = new File('$path/titles_encrypted.txt');
      String contents = await file.readAsString(); // Read the file
      debugPrint("string contents:");
      debugPrint(contents);
      _noteTitlesAndIDsEncrypted = contents;
    }
    catch (e) { // No file yet
      debugPrint("Reading titles failed. Creating file and returning empty string.");
      final path = (await getApplicationDocumentsDirectory()).path;
      final file = new File('$path/titles_encrypted.txt');
      String emptyStringEncrypted = await _cryptor.encrypt("", _userSuppliedKey); // always encrypt
      file.writeAsString(emptyStringEncrypted); // Write the file
      return; // If we encounter an error, abort
    }

    // Decrypt the obtained data
    _noteTitlesAndIDsDecrypted = await _cryptor.decrypt(_noteTitlesAndIDsEncrypted, _userSuppliedKey);
    debugPrint("Decryption successful.");
    debugPrint(_noteTitlesAndIDsDecrypted);

    // Parse the decrypted data
    String separator = "\$";
    if (_noteTitlesAndIDsDecrypted.contains(separator)) { // not empty
      List<String> noteTitlesAndIDsSplit = _noteTitlesAndIDsDecrypted.split(separator);
      debugPrint("Parsing note titles:");
      debugPrint(noteTitlesAndIDsSplit.toString());
      noteTitlesAndIDsSplit.removeLast(); // after last comma there is an empty element. We don't want to parse that.
      noteTitlesAndIDsSplit
          .forEach( // TODO this is awful, convert to base64 and use multiple separators (eg $ and :)
              (str) {
            debugPrint(str);
            List<String> tiny = str.split(','); // TODO variable name
            int id = int.parse(tiny[0]); // save id
            tiny.removeAt(0); // drop id
            setState(() {
              _noteTitlesAndIDs[id] = tiny;
            });
          }
      );
    }
    // TODO come up with great storage format, should also validate titles for $
    // todo no we should not, we should convert them to base64 just like the key!
  }

  _saveNoteTitlesAndIds() async {
    String result = "";
    String separator = "\$";
    _noteTitlesAndIDs.forEach((id, lst){
      result = result + id.toString() + ',' + lst.first + ',' + lst.last + separator;
    });
    debugPrint("This is the result of converting the note titles and ids:");
    debugPrint(result);
    _noteTitlesAndIDsDecrypted = result;
    // encrypt
    _noteTitlesAndIDsEncrypted = await _cryptor.encrypt(_noteTitlesAndIDsDecrypted, _userSuppliedKey);
    // save in file 'titles_encrypted.txt'
    final path = (await getApplicationDocumentsDirectory()).path;
    final file = new File('$path/titles_encrypted.txt');
    file.writeAsString(_noteTitlesAndIDsEncrypted); // Write the file
    debugPrint("Note titles and IDs updated.");
  }

  void _makeNewNote() async {
    debugPrint("New note!");
    // get last ID
    int biggestID = 0;
    if (_noteTitlesAndIDs.isNotEmpty) {
      biggestID = _noteTitlesAndIDs.keys.reduce(max); // if this is too slow we can always save it, too
    }
    // newID = lastID + 1
    int newID = biggestID + 1;
    // update titles (newID: untitled, nocontent at first)
    _noteTitlesAndIDs[newID] = ["Untitled", "id: $newID"];
    _saveNoteTitlesAndIds();
    // make a new file newID.txt
    final path = (await getApplicationDocumentsDirectory()).path;
    final file = new File('$path/$newID.txt');
    String emptyEncrypted = await _cryptor.encrypt("", _userSuppliedKey);
    file.writeAsString(emptyEncrypted); // Write the file
    // go to note editor to edit
    Navigator.of(context).pushNamed("/noteEditor/${newID.toString()}");
    // when saved over there, once again update titles, and write both files (check if title changed)
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
  
  Widget _homeScreen() {
    return new ListView(
      children: _buildListTiles(),
    );
  }

  List<ListTile> _buildListTiles(){
    List<ListTile> result = [];
    _noteTitlesAndIDs.forEach(
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
            title: new Text("aj"),
            onTap: (){}, // nothing
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