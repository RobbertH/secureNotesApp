import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:notes/Cryptography.dart' as Cryptography;

class HomePage extends StatefulWidget {

  HomePage(); // constructor

  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {

  Map<int, List<String>> _noteTitlesAndIDs = new Map<int, List<String>>(); // e.g. {5: ["note title 1", "content short"]}
  String _noteTitlesAndIDsDecrypted = ""; // as a string
  String _noteTitlesAndIDsEncrypted = ""; // ready to store

  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>(); // to show toasts

  HomePageState(); // constructor

  @override
  initState() {
    super.initState();
    // load, decrypt and parse {IDs: titles and content previews} to display in ListView
    _loadIDsFromMemory();
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
      String emptyStringEncrypted = await Cryptography.encrypt(""); // always encrypt
      file.writeAsString(emptyStringEncrypted); // Write the file
      return; // If we encounter an error, abort
    }

    // Decrypt the obtained data
    _noteTitlesAndIDsDecrypted = await Cryptography.decrypt(_noteTitlesAndIDsEncrypted);
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
    _noteTitlesAndIDsEncrypted = await Cryptography.encrypt(_noteTitlesAndIDsDecrypted);
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
    String emptyEncrypted = await Cryptography.encrypt("");
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