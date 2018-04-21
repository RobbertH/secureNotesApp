import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypt/crypt.dart';

// TODO: animated feedback when decrypting (spinning loader or something)

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  String _userSuppliedPassword;
  String _errorMessage = "";

  Color _keyIconColor = Colors.amber;

  final _secureStorage = new FlutterSecureStorage(); // to securely store the salt

  final TextEditingController textEditingController = new TextEditingController();

//  Set<String> _noteIDs = new Set();

  @override
  initState() {
    debugPrint("LoginPage");
    super.initState();
    _checkIfFirstTime();
//    _loadIDsFromMemory(); // TODO remove?
  }

  void _checkIfFirstTime() async {
    String tester;
    try { // see if password exists in secure memory
      tester = await _secureStorage.read(key: "passwordHash");
    }
    catch (e) { // don't have a password yet -> new user
      setState(() {
        _errorMessage = "\n Welcome. Please set a new password.";
      });
    }
    if (tester == null){ // don't have a password yet -> new user
      setState(() {
        _errorMessage = "\n Welcome. Please set a new password.";
      });
    }
  }

//  void _loadIDsFromMemory() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    setState( () => _noteIDs = new Set.from(prefs.getStringList("noteIDs")) ?? new Set());
//    debugPrint(_noteIDs.toString());
//  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Center(child: new Text("Secure Notes"),),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new Column(
            children: [
              new Expanded(child: new Container()),
              new TextFormField(
                controller: textEditingController,
                decoration: new InputDecoration(
                  labelText: 'Your password',
                  icon: new Transform(
                    transform: new Matrix4.rotationZ(3.14159265/2),
                    child: new Icon(Icons.vpn_key, color: _keyIconColor,),
                    alignment: FractionalOffset.bottomRight,
                    origin: new Offset(-10.0, -10.0),
                  ),
                  suffixIcon: new InkWell(
                    onTap: _onOK,
                    child: new Container(
                      decoration: new BoxDecoration(
                        border: new Border.all(width: 2.0, color: Colors.lightBlue,),
                      ),
                      child: new Text(" OK ", style: new TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                      ),
                    ),
                ),
                validator: (value) => value.length == 0 ? 'Please input a password' : null, // TODO: passwordless should be possible. Lay end responsibility at user.
                onSaved: (value) => _userSuppliedPassword = value,
                obscureText: true,
              ),
              new Text(_errorMessage),
              new Expanded(child: new Container()),
            ],
          ),
        ),
      ),
    );
  }

  void _onOK(){
    debugPrint("OK");

    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      textEditingController.clear();
      _performLogin();
    }
  }

  void _performLogin() async {
    // USER FEEDBACK: WE'RE DOING STUFF FOR YOU
    debugPrint("lala");

    setState(() {
      _keyIconColor = Colors.amber;
      _errorMessage = "\n Verifying password. Please wait.";
    });

    authenticate();
    }

    void authenticate() async {
      // === AUTHENTICATION FIRST ===
      // If the user can authenticate, the same password will be used
      // To decrypt the note titles, and eventually the notes themselves
      // The password will be pushed to the note editor.

      String _passwordHash;

      debugPrint("entertainers");

      void onHashFetchFail() async {
        // first declare inner function
        setState(() {
          _errorMessage = "\n Securely storing new password. Please wait.";
        });
        Crypt newHashMachine = new Crypt.sha256(
            _userSuppliedPassword); // randomly salted (handled by Crypt)
        _passwordHash = newHashMachine.toString();
        await _secureStorage.write(
            key: "passwordHash", value: _passwordHash); // store password hash
      }
      try { // fetch password hash from secure memory
        _passwordHash = await _secureStorage.read(key: "passwordHash");
      }
      catch (e) { // don't have a password yet -> make one
        onHashFetchFail();
      }
      if (_passwordHash == null) {
        onHashFetchFail();
      }

      Crypt hashMachine = new Crypt(_passwordHash);
      if (!hashMachine.match(_userSuppliedPassword)) { // Wrong password
        setState(() {
          _keyIconColor = Colors.red;
          _errorMessage = "\n Wrong password. Please retry.";
        });
      }
      else { // Correct password
        setState(() {
          _keyIconColor = Colors.greenAccent;
          _errorMessage = "\n Correct password. Decrypting. Please wait.";
        });
        // === LOGIN SUCCESSFUL -> DECRYPT NOTE TITLES ===
        decryptNoteTitles();
      }

      debugPrint("hurroo");
    }

    void decryptNoteTitles() async {
      final PlatformStringCryptor cryptor = new PlatformStringCryptor();
      debugPrint("crrct");

      // _saltForNotes fetching or generating
      String _saltForNotes;
      void onSaltFetchFail() async {
        _saltForNotes = await cryptor.generateSalt();
        await _secureStorage.write(key: "saltForNotes", value: _saltForNotes);
      }
      try { // fetch salt from secure memory
        debugPrint("here");
        _saltForNotes = await _secureStorage.read(key: "saltForNotes");
      }
      catch (e) { // don't have a salt yet -> make one
        debugPrint("never");
        onSaltFetchFail();
      }
      if (_saltForNotes == null) {
        debugPrint("here!");
        onSaltFetchFail();
      }
      debugPrint("nice");

      final String _key = await cryptor.generateKeyFromPassword("p", _saltForNotes);
      debugPrint("nice!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      final String string = "Note titles fetched from memory\$title 1\$title 2\$title 3"; // TODO validate titles (no "$")
      final String encrypted = await cryptor.encrypt(string, _key);
      //String _userSuppliedKey = await cryptor.generateKeyFromPassword(_userSuppliedPassword, _saltForNotes);
      final String _userSuppliedKey = await cryptor.generateKeyFromPassword(_userSuppliedPassword, _saltForNotes);
      String _noteTitlesDecrypted;
      try {
        _noteTitlesDecrypted = await cryptor.decrypt(encrypted, _userSuppliedKey);
      } on MacMismatchException {
        setState((){
          _keyIconColor = Colors.red;
          _errorMessage = "\n Wrong password. Please retry.";
        });
        // TODO think about best way to inform user: snackbar, red error form or status quo (text)
      }

      if (_noteTitlesDecrypted != null) {
        // doesn't matter if hacker sets this to non-null somehow, values aren't decrypted in that case :)
        Navigator.of(context).pushNamed('/homePage/$_key/$_noteTitlesDecrypted'); // TODO: slash probably not best option
        // TODO: use question mark or somethin :) convert to base64?
        setState(() { _errorMessage = "\n ";});
        // TODO pass decrypted note titles to homepage
      }

    }



}