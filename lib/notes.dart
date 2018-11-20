import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:notes/Cryptography.dart' as Cryptography;
import 'dart:convert';

// TODO: make fields private and make methods for everything
// e.g. noteTitlesAndIDs.add(id, title, contentPreview)
// e.g. getNoteTitlesAndIDs()
// TODO: find a better name
// e.g. notes.getNotes() instead of notes.getNoteTitlesAndIDs()

// Note titles and IDs in three formats
Map<int, List<String>> _notesMap = new Map<int, List<String>>(); // e.g. {5: ["note title 1", "content preview"]}
String _noteTitlesAndIDsDecrypted = ""; // as a string
String _noteTitlesAndIDsEncrypted = ""; // ready to store

// Separator characters
const String _itemSeparator = "\$"; // dictionary item separator (id:title:contentPreview$id:title:contentPreview)
const String _contentSeparator = ":"; // content separator within dictionary item (id:title:contentPreview)

// Access to private fields

// getNotesMap():
// load, decrypt and parse {IDs: titles and content previews}
Future<Map<int, List<String>>> getNotesMap() async {
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
    return new Map<int, List<String>>(); // If we encounter an error, abort
  }

  // Decrypt the obtained data
  _noteTitlesAndIDsDecrypted = await Cryptography.decrypt(_noteTitlesAndIDsEncrypted);
  debugPrint("Decryption successful.");
  debugPrint(_noteTitlesAndIDsDecrypted);

  // Parse the decrypted data
  if (_noteTitlesAndIDsDecrypted.contains(_itemSeparator)) { // not empty
    List<String> noteTitlesAndIDsSplit = _noteTitlesAndIDsDecrypted.split(_itemSeparator);
    debugPrint("Parsing note titles:");
    debugPrint(noteTitlesAndIDsSplit.toString());
    noteTitlesAndIDsSplit
        .forEach((str) {
      debugPrint(str);

      List<String> content = str.split(_contentSeparator); // [id, titleBase64, contentPreviewBase64]
      int id = int.parse(content[0]); // save id
      content.removeAt(0); // drop id
      content.first = String.fromCharCodes(base64.decode(content.first)); // decode title
      content.last = String.fromCharCodes(base64.decode(content.last)); // decode contentPreview
      debugPrint("decoded base 64 strings:");
      debugPrint(content.toString());
      _notesMap[id] = content;
    }
    );
  }
  return _notesMap;
}

void saveNotes() async {
  String result = "";
  _notesMap.forEach((id, lst){
    // id is not encoded as a base64 string, because it's an int => safe to parse later
    String titleBase64 = base64.encode(lst.first.codeUnits);
    String contentPreviewBase64 = base64.encode(lst.last.codeUnits);
    // Add id:title:contentPreview$ to list
    result = result +
        id.toString() + _contentSeparator +
        titleBase64 + _contentSeparator +
        contentPreviewBase64 + _itemSeparator;
  });
  if (result.endsWith(_itemSeparator)) { // not empty
    result = result.substring(0,result.length-1); // drop last separator => easier to split when decoding
  }
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

Future<int> makeNewNote() async {
  debugPrint("New note!");
  // get last ID
  int biggestID = 0;
  if (_notesMap.isNotEmpty) {
    biggestID = _notesMap.keys.reduce(max); // if this is too slow we can always save it, too
  }
  // newID = lastID + 1
  int newID = biggestID + 1;
  // update titles (newID: untitled, nocontent at first)
  _notesMap[newID] = ["Untitled", "id: $newID"];
  saveNotes();
  // make a new file newID.txt
  final path = (await getApplicationDocumentsDirectory()).path;
  final file = new File('$path/$newID.txt');
  String emptyEncrypted = await Cryptography.encrypt("");
  file.writeAsString(emptyEncrypted); // Write the file
  return newID;
}