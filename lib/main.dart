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

    List<String> path = settings.name.split("/"); // indexing starts at 0 but first element is empty
    debugPrint("Routing - The path is:");
    debugPrint(path.toString());

    if (path.length >= 3) { // e.g. [, noteEditor, id]

      if (path[1] == "noteEditor") {
        return new CustomRoute(
          builder: (_) => new NoteEditor(path[2]),
          settings: settings,
          transition: Transition.fade,
        );
      }

    }

    if (path.length >= 2){

      if (path[1] == "homePage") {
        debugPrint("Going to homePage.");
        return new CustomRoute(
          builder: (_) => new HomePage(),
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

String parseUTF(String txt){
  debugPrint("start parsing UTF");
  List<int> result = new List<int>();
  if (txt.length > 2) {
    txt = txt.substring(1, txt.length - 1); // don't need brackets
    List<String> characters = txt.split(",");
    for (var character in characters) {
      result.add(int.parse(character.trim())); // trim spaces
    }
    return utf8.decode(result);
  }
  else {
    debugPrint("parsing error");
    return null;
  }
}