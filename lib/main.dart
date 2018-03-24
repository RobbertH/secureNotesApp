import 'package:flutter/material.dart';
import 'CustomRoute.dart';
import 'HomePage.dart';

void main() => runApp(new MaterialApp(
  home: new HomePage(),
  onGenerateRoute: (RouteSettings settings) {
    switch (settings.name) {
      case ("/"):
        return new CustomRoute(
          builder: (_) => new HomePage(),
          settings: settings,
          transition: Transition.fade,
        );
      default: debugPrint("Routing error");
    }
  },
));