import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'dart:async';
// All encryption and decryption is handled here. The key is also saved here.
// That way, we don't have to pass the key using plain routing messages.
// Under normal operation, the key is set only once upon key generation from
// the user supplied password. Then, encrypt and decrypt methods are called
// using that key.

// The key is a private variable as indicated by the underscore at the start of
// its name. This underscore is thus arguably the most important character in the whole code.
String _key = "";
final PlatformStringCryptor _cryptor = new PlatformStringCryptor();

Future<String> decrypt(String data) {
  return _cryptor.decrypt(data, _key);
}

Future<String> encrypt(String data) {
  return _cryptor.encrypt(data, _key);
}

void setKey(String key) {
  _key = key;
}