# Secure Notes
Written in the [Flutter](https://flutter.io/) framework.

## About
This app aims to be a very simple alternative to the existing notes applications that aren't as secure or privacy-focused. 

## Features
* State of the art [encryption](https://pub.dartlang.org/packages/flutter_string_encryption) (AES/CBC/PKCS5/Random IVs/HMAC-SHA256 Integrity Check for encrypting/decrypting notes)
* [Salted SHA-256](https://pub.dartlang.org/packages/crypt) for storing the password in [secure storage](https://pub.dartlang.org/packages/flutter_secure_storage)
* [Open source](https://github.com/robberth/secureNotesApp)
* Cross-platform (available both on Android and iOS)

## Status
All basic functionality is implemented: authentication works and all notes and note titles are encrypted and can be modified in a simple editor.

Future work includes the ability to export the notes, or even sync them to e.g. Google Drive. 

## Download
As this project is still in early development, no executable is provided. An executable can be obtained by cloning this repo and building from source.

## Disclaimer
The software is provided as-is; in no event shall the author(s) be liable for any claim, damages or other liability.  
