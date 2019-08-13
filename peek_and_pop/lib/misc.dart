//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// © Cosmos Software | Ali Yigit Bireroglu                                                                                                           /
// All material used in the making of this code, project, program, application, software et cetera (the "Intellectual Property")                     /
// belongs completely and solely to Ali Yigit Bireroglu. This includes but is not limited to the source code, the multimedia and                     /
// other asset files. If you were granted this Intellectual Property for personal use, you are obligated to include this copyright                   /
// text at all times.                                                                                                                                /
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//@formatter:off
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'Export.dart';

typedef PeekAndPopBuilder = Widget Function(BuildContext context, PeekAndPopControllerState _peekAndPopController);
typedef PeekAndPopProcessNotifier = bool Function(PeekAndPopControllerState _peekAndPopController);
typedef PeekAndPopProcessCallback = void Function(PeekAndPopControllerState _peekAndPopController);
typedef PeekAndPopGestureCallback = void Function(dynamic pressDetails);

enum Stage {
  Null,
  Done,
}

///See [PeekAndPopChildState.headerSize] and [PeekAndPopChildState.getHeaderOffset].
enum HeaderOffset {
  Zero,
  NegativeHalf,
  PositiveHalf,
}

//TODO: Document
GlobalKey background = GlobalKey();

///See [PeekAndPopChildState.headerSize] and [PeekAndPopChildState.getHeaderOffset].
GlobalKey header = GlobalKey();

class PeekAndPopRoute<T> extends PageRoute<T> {
  final PeekAndPopControllerState _peekAndPopController;

  final WidgetBuilder builder;

  final Function popTransition;

  PeekAndPopRoute(this._peekAndPopController, this.builder, this.popTransition);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Color.fromARGB(1, 0, 0, 0);

  @override
  String get barrierLabel => "";

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 333);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (!_peekAndPopController.isComplete && !_peekAndPopController.isDirect && !_peekAndPopController.ignoreAnimation)
      return child;
    else {
      if (popTransition == null)
        return SlideTransition(position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(animation), child: child);
      else
        return popTransition(context, animation, secondaryAnimation, child);
    }
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }
}
