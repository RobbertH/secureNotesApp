import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:notes/Cryptography.dart' as Cryptography;
import 'package:notes/notesMap.dart' as notesMap;

// TODO: the note editor needs access to the encrypted_titles.txt file to
// fetch the title and update it and update the small content preview text
// ==> move the _noteTitlesAndIDs variable, its en/decrypted string complements
// and its updates methods to a separate file

class NoteEditor extends StatefulWidget {
  final String _id;

  NoteEditor(this._id);

  @override
  State<StatefulWidget> createState() {
    return new NoteEditorState(_id);
  }

}

class NoteEditorState extends State<NoteEditor> {

  NoteEditorState(this._id);

  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>();
  final FocusNode _textFieldFocusNode = new FocusNode();
  final FocusNode _titleFieldFocusNode = new FocusNode();

  final String _id;
  static String _note;
  static String _noteTitle = "";
  bool _editorMode = false;

  TextEditingController _noteTextController = new TextEditingController(text: _note);
  TextEditingController _titleTextController = new TextEditingController(text: _noteTitle);

  @override
  void initState() {
    super.initState();
    _loadNoteFromMemory();
    _loadTitleFromMemory();
  }

  void _loadNoteFromMemory() async {
    String dummy = await readNote(_id); // dummy needed to await
    setState( () => _note = dummy);
    _noteTextController.text = _note;
  }

  void _loadTitleFromMemory() async {
    String dummy = await notesMap.getNoteTitle(int.parse(_id)); // dummy needed to await
    setState( () => _noteTitle = dummy);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        key: _scaffoldState,
        appBar: new AppBar(
          leading: new IconButton(icon: new Icon(Icons.arrow_back), onPressed: Navigator.of(context).pop),
          title: _titleBar(),
        ),
        body: _buildBody(),
        floatingActionButton: 
          new FloatingActionButton(
            onPressed: _pushFloatingButton,
            child: new Icon(_editorMode ? Icons.save : Icons.edit),
          ),
      ),
    );
  }

  Widget _titleBar(){
    return new Row(children: <Widget>[
      new InkWell(
        child: new Text(_noteTitle),
        onTap: _updateNoteTitle,
      ),
      new IconButton(icon: new Icon(Icons.edit), onPressed: _updateNoteTitle)
    ],) ;
  }

  Future<void> _updateNoteTitle() async {
    if (_noteTitle == "Untitled") {
      _titleTextController.clear(); // Never display 'Untitled' in the Title TextField
    }
    else {
      _titleTextController.text = _noteTitle;
    }
    try {
      FocusScope.of(context).requestFocus(_titleFieldFocusNode); // focus on title TextField
    }
    catch (e) {
      debugPrint(e.toString());
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adjust title'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _titleTextController,
              focusNode: _titleFieldFocusNode,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                _noteTitle = _titleTextController.text;
                notesMap.updateNote(int.parse(_id), _noteTitle, _getContentPreview(_note));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _getContentPreview(String note){
    List<String> noteLst = note.split("\n");
    note = noteLst.first;
    if (note.length >= 30){
      return note.substring(0, 30) + "...";
    }
    else {
      return note;
    }
  }

  Widget _buildBody() {
    return new TextField(
      focusNode: _textFieldFocusNode,
      decoration: new InputDecoration(
        filled: true,
        fillColor: Colors.white12,
        hintText: "Start your new note here",
        enabled: false,
      ),
      maxLines: 10000, // TODO: find better solution for this :p
      onChanged: (txt){ _note = txt;},
      controller: _noteTextController,
    );
  }

  void _pushFloatingButton() {
    // save or edit
    if (_editorMode == false) { // we were not in editor mode
      setState(() => _editorMode = true); // so we're switching to it
      FocusScope.of(context).requestFocus(_textFieldFocusNode); // focus on textfield
    }
    else { // we were in editor mode
      setState(() => _editorMode = false); // so we're switching out of it
      _textFieldFocusNode.unfocus();
      _writeNoteToMemory(_note);
      notesMap.updateNote(int.parse(_id), _noteTitle, _getContentPreview(_note)); // also update content preview
    }

    _noteTextController.selection = new TextSelection.fromPosition(
        new TextPosition(offset: _noteTextController.text.length)
    ); // needed to set the cursor behind the text
  }

  void _writeNoteToMemory(String value) async {
    bool succeeded = await writeNote(_id, value);
    if (succeeded) {
      debugPrint("written!");
    }
  }

  Future<bool> writeNote(String noteID, String noteContent) async {
    final path = (await getApplicationDocumentsDirectory()).path;
    final noteFile = new File('$path/${noteID}.txt');
    String encryptedContent = await Cryptography.encrypt("$noteContent");
    try {
      noteFile.writeAsString('$encryptedContent'); // Write the file
      return true;
    }
    catch (e) {
      debugPrint("Writing note to file failed.");
      return false;
    }

  }

  Future<String> readNote(String noteID) async {
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      final file = new File('$path/${noteID}.txt');
      String contents = await file.readAsString(); // Read the file
      debugPrint(contents);
      return Cryptography.decrypt(contents);
    }
    catch (e) { // No file yet
      debugPrint("Failed to open file from editor.");
      return ""; // If we encounter an error, return empty str
    }

  }


}