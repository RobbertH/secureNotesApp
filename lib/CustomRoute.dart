import 'package:flutter/material.dart';

enum Transition{ // enum for all possible transitions (used for the CustomRoutes)
  fromLeftToRight,
  fromRightToLeft,
  fromBottomToTop,
  fromTopToBottom,
  fade,
  none
}

class CustomRoute<T> extends MaterialPageRoute<T> {

  Transition transition;

  CustomRoute({ // constructor
    WidgetBuilder builder,
    RouteSettings settings,
    this.transition,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    switch (this.transition){
      case Transition.fromBottomToTop:
        return _slideFromBottomToTop(animation, child);
        break;
      case Transition.fromTopToBottom:
        return _slideFromTopToBottom(animation, child);
        break;
      case Transition.fromLeftToRight:
        return _slideFromLeftToRight(animation, child);
        break;
      case Transition.fromRightToLeft:
        return _slideFromRightToLeft(animation, child);
        break;
      case Transition.none:
        return _noTransition(animation, child);
      default:
        return _fade(animation, child);
    }
  }

  AnimatedWidget _slideFromLeftToRight(animation, child){
    return new SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(-1.0,0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  AnimatedWidget _slideFromRightToLeft(animation, child){
    return new SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(1.0,0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  AnimatedWidget _slideFromBottomToTop(animation, child){
    return new SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(0.0,-1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  AnimatedWidget _slideFromTopToBottom(animation, child){
    return new SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(0.0,1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  AnimatedWidget _noTransition(animation, child){
    return new SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(0.0,0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  SingleChildRenderObjectWidget _fade(animation, child){
    return new FadeTransition(opacity: animation, child: child);
  }

}

