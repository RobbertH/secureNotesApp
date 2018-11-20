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

Future work includes:
* The ability to export the notes, or even sync them to e.g. Google Drive or dropbox. 
* A dark theme
* A better note editor

## Open Questions
* Whether a SHA256 salted password should be saved. We can also try to decrypt a note and upon failing, conclude that the password is wrong.
* Whether we want to give the user the option to choose their password as the empty string, or set a minimum password length.

## Screenshots
<img src="https://raw.githubusercontent.com/RobbertH/secureNotesApp/master/screenshots/LoginPage.png" alt="LoginPage" width="30%"> <img src="https://raw.githubusercontent.com/RobbertH/secureNotesApp/master/screenshots/HomePage.png" alt="HomePage" width="30%"> <img src="https://raw.githubusercontent.com/RobbertH/secureNotesApp/master/screenshots/NoteEditor.png" alt="NoteEditor" width="30%">

## Download
As this project is still in early development, no executable is provided. An executable can be obtained by cloning this repo and building from source.

## Disclaimer
The software is provided as-is; in no event shall the author(s) be liable for any claim, damages or other liability.  
