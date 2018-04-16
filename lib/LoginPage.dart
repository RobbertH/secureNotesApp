import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: give feedback when decrypting (spinning loader or something)

// TODO: an idea is to - at the first time, when choosing a password - encrypt a sentence with that password
// TODO: and save that sentence to secure storage (if that's permanent storage at least)
// TODO: if the user can decrypt it (no MAC exception), the password is correct. This way the password is not stored.

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

  Set<String> _noteIDs = new Set();

  @override
  initState() {
    debugPrint("LoginPage");
    super.initState();
    _loadIDsFromMemory();
  }

  void _loadIDsFromMemory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState( () => _noteIDs = new Set.from(prefs.getStringList("noteIDs")) ?? new Set());
  }

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
      _performLogin();
    }
  }

  void _performLogin() async {

    setState((){
      _keyIconColor = Colors.amber;
      _errorMessage = "\n Decrypting. Please wait.";
    } );

    debugPrint("OK!!!!!!!!!!");

    // start decrypting
    final PlatformStringCryptor cryptor = new PlatformStringCryptor();

    final String string = "Note titles fetched from memory:title 1:title 2:title 3"; // TODO validate titles (no ":")

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String _salt;

    try { // fetch salt from secure memory
      _salt = await _secureStorage.read(key: "salt");
      // TODO: differ between first time login -> generate salt
      // TODO: and not first time -> just read
      // TODO: at initstate, display a text saying the user can make their passwd by entering one
    }
    catch (e) { // don't have a salt yet -> make one
      _salt = await cryptor.generateSalt();
      await _secureStorage.write(key: "salt", value: _salt);
    }

    final String _key = await cryptor.generateKeyFromPassword("p", _salt);

    final String encrypted = await cryptor.encrypt(string, _key);

    String _userSuppliedKey = await cryptor.generateKeyFromPassword(_userSuppliedPassword, _salt);
    String _noteTitlesDecrypted;
    try {
      _noteTitlesDecrypted = await cryptor.decrypt(encrypted, _userSuppliedKey);
    } on MacMismatchException {
      debugPrint("wrongly decrypted");
      setState((){
        _keyIconColor = Colors.red;
        _errorMessage = "\n Wrong password. Please retry.";
      });
      // TODO think about best way to inform user: snackbar, red error form or status quo (text)
    }

    // TODO reset textfield!!!!!!!!!!!!!!!!!! important!!!!!!!!!!!!!

    if (_noteTitlesDecrypted != null) {
      // doesn't matter if hacker sets this to non-null somehow, values aren't decrypted in that case :)
      Navigator.of(context).pushNamed('/homePage/$_key/$_noteTitlesDecrypted'); // TODO: slash probably not best option
      // TODO: use question mark or somethin :)
      setState(() { _errorMessage = "\n ";});
      // TODO pass decrypted note titles to homepage
    }


  }


}