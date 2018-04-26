import 'package:flutter/material.dart';
import 'CustomRoute.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'NoteEditor.dart';
import 'dart:convert';

void main() => runApp(new MaterialApp(
  home: new LoginPage(),
  onGenerateRoute: (RouteSettings settings) {
    if (settings.name == "/"){
      return new CustomRoute(
        builder: (_) => new LoginPage(),
        settings: settings,
        transition: Transition.fade,
      );
    }

    var path = settings.name.split("/"); // indexing starts at 0 but first element is empty
    if (path.length >= 3) { // e.g. [, noteEditor, id]

      if (path[1] == "noteEditor") {
        return new CustomRoute(
          builder: (_) => new NoteEditor(id: path[2]),
          // path[1] is the node's ID
          settings: settings,
          transition: Transition.fade,
        );
      }

    }

    if (path.length >= 4){

      if (path[1] == "homePage") {
        debugPrint("zibi");
        debugPrint(path[2]);
        debugPrint(parseUTF(path[2]));
        debugPrint(path[3]);
        return new CustomRoute(
          builder: (_) => new HomePage(parseUTF(path[2]), parseTitles(path[3])),
          // TODO: pass decrypted note titles or key
          settings: settings,
          transition: Transition.fade,
        );
      }

    }

    else {
      debugPrint("Routing error");
    }

  },
));

String parseUTF(String txt){ // TODO lol variable names suck balls
  debugPrint("start parsing utf");
  List<int> result = new List<int>();
  if (txt.length > 2) {
    txt = txt.substring(1, txt.length - 1); // don't need brackets
    var opi = txt.split(",");
    for (var el in opi) {
      result.add(int.parse(el.trim())); // strip spaces
    }
    return utf8.decode(result);
  }
  else {
    debugPrint("parsing error");
    return null;
  }
}

List<String> parseTitles(String txt){ // TODO lol variable names suck balls
  debugPrint("start parsing titles");
  List<String> result = new List<String>();
  if (txt.length > 2) {
    txt = txt.substring(1, txt.length - 1); // don't need brackets
    var opi = txt.split(",");
    for (var el in opi) { // TODO list comprehension?
      result.add(el.trim()); // strip spaces from sides
    }
    return result;
  }
  else {
    debugPrint("parsing error");
    return null;
  }
}