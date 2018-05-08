# Secure Notes

Written in the [Flutter](https://flutter.io/) framework.

## About
This app aims to be a very simple alternative to the existing notes applications that aren't as secure or privacy-focused. 

## Why this secure notes app?
* State of the art [encryption](https://pub.dartlang.org/packages/flutter_string_encryption) (AES/CBC/PKCS5/Random IVs/HMAC-SHA256 Integrity Check for encrypting/decrypting notes)
* [salted SHA-256](https://pub.dartlang.org/packages/crypt) for storing the password in [secure storage](https://pub.dartlang.org/packages/flutter_secure_storage)
* [Open source](https://github.com/robberth/secureNotesApp)
* Cross-platform (available both on Android and iOS)

## Status
So far you can only save notes to files, no encryption yet.

At this moment the project is on hold, as I am waiting for a flutter update so non-string variables can be passed through the Navigator. 
See this [GitHub issue](https://github.com/flutter/flutter/issues/6225).
