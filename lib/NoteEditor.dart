import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteEditor extends StatefulWidget {
  final String id;

  NoteEditor({this.id});

  @override
  State<StatefulWidget> createState() {
    return new NoteEditorState(id: id);
  }

}

class NoteEditorState extends State<NoteEditor> {

  NoteEditorState({this.id});

  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>();
  final FocusNode _textFieldFocusNode = new FocusNode();

  final String id;
  static String _note;
  bool _editorMode = false;


  TextEditingController _textController = new TextEditingController(text: _note);

  @override
  void initState() {
    super.initState();
    _loadNoteFromMemory();
  }

  void _loadNoteFromMemory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState( () => _note = prefs.getString(id) ?? "An error occurred. ID not found." );
    _textController.text = _note;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        key: _scaffoldState,
        appBar: new AppBar(
          leading: new IconButton(icon: new Icon(Icons.arrow_back), onPressed: Navigator.of(context).pop),
          title: new Text(id),
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

  Widget _buildBody() {
    return new TextField(
      focusNode: _textFieldFocusNode,
      decoration: new InputDecoration(
        filled: true,
        fillColor: Colors.yellow,
        hintText: "Start your new note here",
        enabled: false,
      ),
      maxLines: 1000, // TODO: find better solution for this :p
      onChanged: (txt){ _note = txt;},
      controller: _textController,
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
    }

    _textController.selection = new TextSelection.fromPosition(
        new TextPosition(offset: _textController.text.length)
    ); // needed to set the cursor behind the text
  }

  void _writeNoteToMemory(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState( () => prefs.setString(id, value));
  }

}