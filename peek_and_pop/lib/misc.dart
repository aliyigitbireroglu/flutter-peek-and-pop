//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// © Cosmos Software | Ali Yigit Bireroglu                                                                                                           /
// All material used in the making of this code, project, program, application, software et cetera (the "Intellectual Property")                     /
// belongs completely and solely to Ali Yigit Bireroglu. This includes but is not limited to the source code, the multimedia and                     /
// other asset files. If you were granted this Intellectual Property for personal use, you are obligated to include this copyright                   /
// text at all times.                                                                                                                                /
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//@formatter:off

import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';

import 'Export.dart';

typedef PeekAndPopBuilder = Widget Function(BuildContext context, PeekAndPopControllerState _peekAndPopController);
typedef PeekAndPopProcessNotifier = bool Function(PeekAndPopControllerState _peekAndPopController);
typedef PeekAndPopProcessCallback = void Function(PeekAndPopControllerState _peekAndPopController);
typedef PeekAndPopGestureCallback = void Function(dynamic pressDetails);
typedef QuickActionsBuilder = QuickActionsData Function(PeekAndPopControllerState _peekAndPopController);

///See [PeekAndPopControllerState.stage].
enum Stage {
  None,
  WillPush,
  IsPushed,
  WillPeek,
  IsPeeking,
  WillCancel,
  IsCancelled,
  WillFinish,
  IsFinished,
  WillComplete,
  IsComplete,
  WillClose,
  IsClosed,
}

///The new optimised blur effect algorithm during the Peek & Pop process requires your root CupertinoApp/MaterialApp to be wrapped in a
///[RepaintBoundary] widget which uses this key. See README, [PeekAndPopChildState.blurSnapshot] or [PeekAndPopChildState.blurTrackerNotifier] for more
///info.
final GlobalKey background = GlobalKey();

///See [TransformBloc], [scaleUpWrapper] and [scaleDownWrapper].
TransformBloc transformBloc = TransformBloc();

///Use this function to scale down a widget as the Peek & Pop process proceeds.
Widget scaleDownWrapper(Widget child, double scaleDownCoefficient) {
  return StreamBuilder(
    stream: transformBloc,
    builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
      return Transform.scale(
        scale: snapshot.hasData ? (1.0 - (snapshot.data * scaleDownCoefficient)) : 1.0,
        child: child,
      );
    },
  );
}

///Use this function to scale up a widget as the Peek & Pop process proceeds.
Widget scaleUpWrapper(Widget child, double scaleUpCoefficient) {
  return StreamBuilder(
    stream: transformBloc,
    builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
      return Transform.scale(
        scale: snapshot.hasData ? (1.0 + (snapshot.data * scaleUpCoefficient)) : 1.0,
        child: child,
      );
    },
  );
}

///A Bloc class for controlling the [scaleDownWrapper] and [scaleUpWrapper].
class TransformBloc extends Bloc<double, double> {

  TransformBloc(): super(0.0);

  @override
  Stream<double> mapEventToState(double newState) async* {
    yield newState;
  }
}

///A simple class for organising general Quick Actions information.
class QuickActionsData {
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final List<QuickAction> quickActions;

  const QuickActionsData(
    this.padding,
    this.borderRadius,
    this.quickActions,
  );
}

///A simple class for organising an individual Quick Action information.
class QuickAction {
  final double height;
  final Function onTap;
  final BoxDecoration boxDecoration;
  final Widget child;

  const QuickAction(
    this.height,
    this.onTap,
    this.boxDecoration,
    this.child,
  );
}

class PeekAndPopRoute<T> extends PageRoute<T> {
  final PeekAndPopControllerState _peekAndPopController;

  final WidgetBuilder builder;

  final Function pageTransition;

  PeekAndPopRoute(
    this._peekAndPopController,
    this.builder,
    this.pageTransition,
  );

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
    if (!_peekAndPopController.isDirect && !_peekAndPopController.ignoreAnimation && _peekAndPopController.stage != Stage.IsComplete) return child;
    if (pageTransition == null)
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    return pageTransition(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }
}
