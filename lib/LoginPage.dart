import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Store data in secure storage (keyChain or keyStore)
import 'package:flutter_string_encryption/flutter_string_encryption.dart'; // AES/CBC/PKCS5/Random IVs/HMAC-SHA256 Integrity Check
import 'package:crypt/crypt.dart'; // One-way string hashing for salted passwords using the Unix crypt format.
import 'package:notes/Cryptography.dart' as Cryptography;

// TODO: include pictures in the README
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
  String _passwordFieldHintText = "Your password";

  Color _keyIconColor = Colors.amber;

  // secure storage is used to securely store
  // * the salt needed to generate the key that crypt uses (saltForNotes)
  // * and also the hash of the password itself (passwordHash)
  final _secureStorage = new FlutterSecureStorage();

  final TextEditingController _textEditingController = new TextEditingController();

//  Set<String> _noteIDs = new Set();

  @override
  initState() {
    debugPrint("LoginPage");
    super.initState();
    _checkIfFirstTime();
  }

  void _checkIfFirstTime() async {
    String tester;
    try { // see if password exists in secure memory
      tester = await _secureStorage.read(key: "passwordHash");
    }
    catch (e) { // don't have a password yet -> new user
      setState(() {
        _errorMessage = "\n Welcome. Please set a new password.";
        _passwordFieldHintText = "Your new password";
      });
    }
    if (tester == null){ // don't have a password yet -> new user
      setState(() {
        _errorMessage = "\n Welcome. Please set a new password.";
        _passwordFieldHintText = "Your new password";
      });
    }
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
                controller: _textEditingController,
                decoration: new InputDecoration(
                  labelText: _passwordFieldHintText,
                  icon: new Transform(
                    transform: new Matrix4.rotationZ(3.14159265/2),
                    child: new Icon(Icons.vpn_key, color: _keyIconColor,),
                    alignment: FractionalOffset.bottomRight,
                    origin: new Offset(-10.0, -10.0),
                  ),
                  suffixIcon: new InkWell(
                    onTap: _onOK,
                    child: new Container(
                      width: 2.0,
                      height: 2.0,
                      decoration: new BoxDecoration(
                        border: new Border.all(width: 2.0, color: Colors.lightBlue,),
                      ),
                      child: new Center(
                        child: new Text(" OK ", style: new TextStyle(
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ),
                      ),
                    ),
                ),
                validator: (value) => value.length == 0 ? 'Please input a password' : null,
                // TODO: passwordless should be possible. Lay end responsibility at user.
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
    debugPrint("Ok button pushed");

    final form = _formKey.currentState;

    if (form.validate()) {
      form.save(); // Executes onSaved defined earlier (i.e. _userSuppliedPassword is fetched from input field)
      _textEditingController.clear(); // Wipes password from input field
      _performLogin();
    }
  }

  void _performLogin() async {
    debugPrint("_performLogin started");

    setState(() { // User feedback: we're doing stuff for you
      _keyIconColor = Colors.amber;
      _errorMessage = "\n Verifying password. Please wait.";
    });

    _authenticate();
  }

  void _authenticate() async {
    // === AUTHENTICATION FIRST ===
    // If the user can authenticate, the same password will be used
    // to decrypt the note titles (which reside in a separate file with title + ID),
    // and eventually the notes themselves (which have a file for themselves,
    // each containing the ID + title + content).
    // The password will be pushed to the note editor.

    String _passwordHash;

    debugPrint("Authentication started");

    // First declare inner function to define what happens in catch/null blocks.
    // This block of code is a bit confusing because it's not chronological, but it is used
    // later in the code, when we try to fetch the hash and it is not found.
    // That means there is no password yet. Hence we'll make one.
    void onHashFetchFail() async {
      setState(() {
        _errorMessage = "\n Securely storing new password. Please wait.";
      });
      Crypt newHashMachine = new Crypt.sha256(_userSuppliedPassword); // randomly salted (handled by Crypt)
      _passwordHash = newHashMachine.toString();
      await _secureStorage.write(
        key: "passwordHash", value: _passwordHash); // store password hash
        setState(() {
          _errorMessage = "\n Securely stored new password. Re-enter to log in.";
        });
    }

    // Fetch password hash from secure memory
    try {
      _passwordHash = await _secureStorage.read(key: "passwordHash");
    }
    // Don't have a password yet -> make one (as defined in the method above)
    catch (e) {
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
        _keyIconColor = Colors.lightGreen;
        _errorMessage = "\n Correct password. Decrypting. Please wait.";
      });
      // === LOGIN SUCCESSFUL -> MAKE KEY TO BE ABLE TO DECRYPT LATER ===
      _buildKey();
    }

    debugPrint("Reached end of _authenticate method.");
  }

  void _buildKey() async {
    final PlatformStringCryptor cryptor = new PlatformStringCryptor();

    // _saltForNotes fetching or generating
    String _saltForNotes;
    Future<void> onSaltFetchFail() async {
      debugPrint("Salt fetch fail");
      _saltForNotes = await cryptor.generateSalt();
      debugPrint("Got new salt! here it is:");
      debugPrint(_saltForNotes);
      await _secureStorage.write(key: "saltForNotes", value: _saltForNotes);
      debugPrint("Salt written to secure storage.");
    }
    try { // fetch salt from secure memory
      debugPrint("Trying to fetch salt.");
      _saltForNotes = await _secureStorage.read(key: "saltForNotes");
    }
    catch (e) { // don't have a salt yet -> make one
      debugPrint("Don't have salt yet (error)");
      await onSaltFetchFail();
    }
    if (_saltForNotes == null) {
      debugPrint("Don't have salt yet (null)");
      await onSaltFetchFail();
    }

    debugPrint("We should have a salt now (new or existing) "
        "(this message might be printed when it is still generating, because of the async functions)");

    debugPrint("Generating key from user supplied password");
    final String _userSuppliedKey = await cryptor.generateKeyFromPassword(_userSuppliedPassword, _saltForNotes);
    Cryptography.setKey(_userSuppliedKey);
    debugPrint(_userSuppliedKey);
    Navigator.of(context).pushNamed('/homePage');
    setState(() {
      _errorMessage = "\n ";
      _passwordFieldHintText = "Your password";
    });

  }

}
