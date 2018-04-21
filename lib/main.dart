import 'package:flutter/material.dart';
import 'CustomRoute.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'NoteEditor.dart';

void main() => runApp(new MaterialApp(
  home: new HomePage(),
  onGenerateRoute: (RouteSettings settings) {
    if (settings.name == "/"){
      return new CustomRoute(
        builder: (_) => new LoginPage(),
        settings: settings,
        transition: Transition.fade,
      );
    }

    var path = settings.name.split("/");
    if (path[1] == "noteEditor" && path.length >= 3){ // e.g. [, noteEditor, id]
      return new CustomRoute(
        builder: (_) => new NoteEditor(id: path[2]), // path[1] is the node's ID
        settings: settings,
        transition: Transition.fade,
      );
    }

    if (path[1] == "homePage"){ // e.g. [, noteEditor, id]
      return new CustomRoute(
        builder: (_) => new HomePage(), // TODO: pass decrypted note titles
        settings: settings,
        transition: Transition.fade,
      );
    }

    else {
      debugPrint("routing error");
    }

  },
));