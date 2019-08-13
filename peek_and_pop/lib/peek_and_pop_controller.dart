//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// © Cosmos Software | Ali Yigit Bireroglu                                                                                                           /
// All material used in the making of this code, project, program, application, software et cetera (the "Intellectual Property")                     /
// belongs completely and solely to Ali Yigit Bireroglu. This includes but is not limited to the source code, the multimedia and                     /
// other asset files. If you were granted this Intellectual Property for personal use, you are obligated to include this copyright                   /
// text at all times.                                                                                                                                /
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//@formatter:off
import 'dart:ui';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'gesture_detector.dart' as MyGestureDetector;
import 'Export.dart';

///The widget that is responsible of ALL Peek & Pop related logic. It works together with [PeekAndPopChild] and [PeekAndPopDetector].
class PeekAndPopController extends StatefulWidget {
  ///The widget that is to be displayed on your regular UI.
  final Widget uiChild;

  ///The view to be displayed during the Peek & Pop process.
  final PeekAndPopBuilder peekAndPopBuilder;

  ///Set this to true if your [peekAndPopBuilder] doesn't change during the Peek & Pop process.
  final bool useCache;

  ///The maximum [BackdropFilter.sigmaX] and [BackdropFilter.sigmaY] to be applied to the [Blur] widget.
  final double sigma;

  ///The color to be displayed over the [Blur] widget. The alpha of this color is controlled by the [PeekAndPopControllerState.animationController].
  final Color backdropColor;

  ///An optional second view to be during the Peek & Pop process. See [PeekAndPopChildState.build] for more.
  final Widget overlayBuiler;

  ///Set this to true if your [peekAndPopBuilder] uses a [Hero] widget.
  final bool isHero;

  ///The callback for when the Peek & Pop process is about to successfully complete. You can return false to block the next part.
  final PeekAndPopProcessNotifier willPeekAndPopComplete;

  ///The callback for when the view is about to be initially pushed to the Navigator. You can return false to block the next part.
  final PeekAndPopProcessNotifier willPushPeekAndPop;

  ///The callback for when the state of the view is about to be updated. You can return false to block the next part.
  final PeekAndPopProcessNotifier willUpdatePeekAndPop;

  ///The callback for when the Peek & Pop process is about to be cancelled. You can return false to block the next part.
  final PeekAndPopProcessNotifier willCancelPeekAndPop;

  ///The callback for when the view is about to be popped after peeking. You can return false to block the next part.
  final PeekAndPopProcessNotifier willFinishPeekAndPop;

  ///The callback for when the view is about to be closed after popping. You can return false to block the next part.
  final PeekAndPopProcessNotifier willClosePeekAndPop;

  ///The callback for when the Peek & Pop process successfully completes. This callback is invoked after the entire process.
  final PeekAndPopProcessCallback onPeekAndPopComplete;

  ///The callback for when the view is initially pushed to the Navigator.
  final PeekAndPopProcessCallback onPushPeekAndPop;

  ///The callback for when the state of the view is updated.
  final PeekAndPopProcessCallback onUpdatePeekAndPop;

  ///The callback for when the Peek & Pop process is cancelled.
  final PeekAndPopProcessCallback onCancelPeekAndPop;

  ///The callback for when the view is being popped after peeking.
  final PeekAndPopProcessCallback onFinishPeekAndPop;

  ///The callback for when the view is being closed after popping.
  final PeekAndPopProcessCallback onClosePeekAndPop;

  ///The callback for when a gesture begins. This callback is only invoked from gestures detected by [PeekAndPopChild].
  final PeekAndPopGestureCallback onPressStart;

  ///The callback for when a gesture updates. This callback is only invoked from gestures detected by [PeekAndPopChild].
  final PeekAndPopGestureCallback onPressUpdate;

  ///The callback for when a gesture ends. This callback is only invoked from gestures detected by [PeekAndPopChild].
  final PeekAndPopGestureCallback onPressEnd;

  ///The pressure treshold at which the view first becomes visible.
  final double treshold;

  ///The min pressure for initiating the Peek & Pop process. Flutter's normal [GestureDetector] has relatively wrong values for a Peek & Pop process
  ///so a new [MyGestureDetector.GestureDetector] is created for altering these values. The new [MyGestureDetector.GestureDetector] is otherwise
  ///identical to Flutter's normal [GestureDetector].
  final double startPressure;

  ///The max pressure for finishing the Peek & Pop process. Flutter's normal [GestureDetector] has relatively wrong values for a Peek & Pop process
  ///so a new [MyGestureDetector.GestureDetector] is created for altering these values. The new [MyGestureDetector.GestureDetector] is otherwise
  ///identical to Flutter's normal [GestureDetector].
  final double peakPressure;

  ///The base scale at which you want your view to be displayed during the Peek stage.
  final double peekScale;

  ///The coefficient for controlling how much your view can rescale according to the pressure magnitude during the Peek stage. A low value such as
  ///0.05 is recommended based on observations made by Swiss scientists.
  final double peekCoefficient;

  ///The transition to be used when:
  ///   a) The view is opened directly.
  ///   b) The view is closed.
  ///   (A default [SlideTransition] is provided.)
  final Function popTransition;

  //TODO Change the name of this variable as it can cause confusion.

  const PeekAndPopController(this.uiChild, this.peekAndPopBuilder, this.useCache,
      {this.sigma: 10,
      this.backdropColor: Colors.black,
      this.overlayBuiler,
      this.isHero: false,
      this.willPeekAndPopComplete,
      this.willPushPeekAndPop,
      this.willUpdatePeekAndPop,
      this.willCancelPeekAndPop,
      this.willFinishPeekAndPop,
      this.willClosePeekAndPop,
      this.onPeekAndPopComplete,
      this.onPushPeekAndPop,
      this.onUpdatePeekAndPop,
      this.onCancelPeekAndPop,
      this.onFinishPeekAndPop,
      this.onClosePeekAndPop,
      this.onPressStart,
      this.onPressUpdate,
      this.onPressEnd,
      this.treshold: 0.5,
      this.startPressure: 0.1,
      this.peakPressure: 0.9,
      this.peekScale: 0.5,
      this.peekCoefficient: 0.05,
      this.popTransition});

  @override
  PeekAndPopControllerState createState() {
    return PeekAndPopControllerState(
        uiChild,
        peekAndPopBuilder,
        useCache,
        sigma,
        backdropColor,
        overlayBuiler,
        isHero,
        willPeekAndPopComplete,
        willPushPeekAndPop,
        willUpdatePeekAndPop,
        willCancelPeekAndPop,
        willFinishPeekAndPop,
        willClosePeekAndPop,
        onPeekAndPopComplete,
        onPushPeekAndPop,
        onUpdatePeekAndPop,
        onCancelPeekAndPop,
        onFinishPeekAndPop,
        onClosePeekAndPop,
        onPressStart,
        onPressUpdate,
        onPressEnd,
        treshold,
        startPressure,
        peakPressure,
        peekScale,
        peekCoefficient,
        popTransition);
  }
}

class PeekAndPopControllerState extends State<PeekAndPopController> with TickerProviderStateMixin {
  final Widget uiChild;
  final PeekAndPopBuilder peekAndPopBuilder;
  final bool useCache;
  final double sigma;
  final Color backdropColor;
  final Widget overlayBuilder;
  final bool isHero;

  final PeekAndPopProcessNotifier willPeekAndPopComplete;
  final PeekAndPopProcessNotifier willPushPeekAndPop;
  final PeekAndPopProcessNotifier willUpdatePeekAndPop;
  final PeekAndPopProcessNotifier willCancelPeekAndPop;
  final PeekAndPopProcessNotifier willFinishPeekAndPop;
  final PeekAndPopProcessNotifier willClosePeekAndPop;

  final PeekAndPopProcessCallback onPeekAndPopComplete;
  final PeekAndPopProcessCallback onPushPeekAndPop;
  final PeekAndPopProcessCallback onUpdatePeekAndPop;
  final PeekAndPopProcessCallback onCancelPeekAndPop;
  final PeekAndPopProcessCallback onFinishPeekAndPop;
  final PeekAndPopProcessCallback onClosePeekAndPop;

  final PeekAndPopGestureCallback onPressStart;
  final PeekAndPopGestureCallback onPressUpdate;
  final PeekAndPopGestureCallback onPressEnd;

  final double treshold;
  final double startPressure;
  final double peakPressure;
  final double peekScale;
  final double peekCoefficient;

  final Function popTransition;

  PeekAndPopChildState peekAndPopChild;

  ///A required precaution for preventing consecutive Peek & Pop processes without sufficient time.
  ///(I actually forgot why it is required but it is required.)
  DateTime lastActionTime;

  ///The [AnimationController] used to set the values of the [Blur] widget and to set the scale of the view during the Peek stage.
  AnimationController animationController;

  ///The [AnimationController] used to set the scale of the view during the Pop stage for creating an iOS-Style jump effect.
  AnimationController secondaryAnimationController;
  Animation<double> secondaryAnimation;

  ///[ValueNotifier] for updating the view through [PeekAndPopChildState.build] as the [animationController], the [secondaryAnimationController]
  ///or the [tertiaryAnimationController] changes.
  ValueNotifier<int> animationTrackerNotifier = ValueNotifier<int>(0);

  ///A [ValueNotifier] for rerouting gesture recognition from [PeekAndPopDetector] to [PeekAndPopChild].
  ValueNotifier<bool> pressReroutedNotifier = ValueNotifier<bool>(false);

  ///A value for tracking the stage of the Peek & Pop process.
  bool isComplete = false;

  ///A value for tracking the stage of the Peek & Pop process.
  bool isPushed = false;

  ///A required precaution for behaving accordingly if the [uiChild] is tapped instead of pressed.
  bool isDirect = false;

  ///A required precaution.
  ///(I also forgot why.)
  bool ignoreAnimation = false;

  ///Set this value to false if you want Long Press to be used instead of Force Press. Long Press version of this package is still under development
  ///and is not fully tested yet so consider it as a developers preview.
  bool supportsForcePress = true;

  ///The callback for resetting the state of the [PeekAndPopDetector] once the gesture recognition is rerouted to the instantiated
  ///[PeekAndPopChild] or vice-versa.
  Function callback;

  ///Use this value to determine the depth of debug logging that is actually only here for myself and the Swiss scientists.
  int _debugLevel = 0;

  PeekAndPopControllerState(
      this.uiChild,
      this.peekAndPopBuilder,
      this.useCache,
      this.sigma,
      this.backdropColor,
      this.overlayBuilder,
      this.isHero,
      this.willPeekAndPopComplete,
      this.willPushPeekAndPop,
      this.willUpdatePeekAndPop,
      this.willCancelPeekAndPop,
      this.willFinishPeekAndPop,
      this.willClosePeekAndPop,
      this.onPeekAndPopComplete,
      this.onPushPeekAndPop,
      this.onUpdatePeekAndPop,
      this.onCancelPeekAndPop,
      this.onFinishPeekAndPop,
      this.onClosePeekAndPop,
      this.onPressStart,
      this.onPressUpdate,
      this.onPressEnd,
      this.treshold,
      this.startPressure,
      this.peakPressure,
      this.peekScale,
      this.peekCoefficient,
      this.popTransition);

  void updateAnimationTrackerNotifier() {
    animationTrackerNotifier.value += 1;
  }

  void primaryAnimationStatusListener(AnimationStatus animationStatus) {
    if (ignoreAnimation) return;

    switch (animationStatus) {
      case AnimationStatus.completed:
        if (_debugLevel > 1) print("AnimationStatus.completed");

        HapticFeedback.heavyImpact();

        lastActionTime = DateTime.now();
        isComplete = true;
        pressReroutedNotifier.value = false;

        callback();
        break;
      case AnimationStatus.dismissed:
        if (_debugLevel > 1) print("AnimationStatus.dismissed");

        HapticFeedback.heavyImpact();

        lastActionTime = DateTime.now();
        Navigator.of(context).pop();

        callback();
        break;
      default:
        break;
    }
  }

  //TODO: There must be a better way of doing this!
  void secondaryAnimationStatusListener(AnimationStatus animationStatus) {
    if (ignoreAnimation) return;

    switch (animationStatus) {
      case AnimationStatus.completed:
        secondaryAnimation = Tween(begin: 1.0 - peekScale - peekCoefficient, end: 1.0 - peekScale - peekCoefficient + 0.025)
            .animate(CurvedAnimation(parent: secondaryAnimationController, curve: Curves.decelerate));
        secondaryAnimationController.reverse();
        break;
      case AnimationStatus.dismissed:
        break;
      default:
        break;
    }
  }

  ///This function is called by the instantiated [PeekAndPopChild] once it is ready to be included in the Peek & Pop process. Perhaps the most
  ///essential functionality of this package also takes places in this function: The gesture recognition is rerouted from the  [PeekAndPopDetector]
  ///to the instantiated [PeekAndPopChild]. This is important for avoiding the necessity of having the user stop and restart their Force Press.
  ///Instead, the [PeekAndPopController] does this automatically so that the existing Force Press can continue to update even when if
  ///[PeekAndPopDetector] is blocked by the view which is often the case especially when using PlatformViews.
  void pushComplete(PeekAndPopChildState peekAndPopChild) {
    if (_debugLevel > 1) print("PushComplete");

    this.peekAndPopChild = peekAndPopChild;
    isPushed = true;

    if (!isDirect) {
      pressReroutedNotifier.value = true;
      Future.delayed(Duration(milliseconds: 333), () {
        reroutePress();
      });
    }

    if (!supportsForcePress) drivePeekAndPop(true);

    if (onPushPeekAndPop != null) onPushPeekAndPop(this);
  }

  ///See [pushComplete].
  void reroutePress() {
    //UNCOMMENT HERE
//    GestureBinding.instance.startIgnoring();
//    PointerUpEvent pointerUpEvent = PointerUpEvent(
//        timeStamp: Duration(milliseconds: GestureBinding.instance.lastEvent.timeStamp.inMilliseconds + 100),
//        pointer: GestureBinding.instance.lastEvent.pointer,
//        device: GestureBinding.instance.lastEvent.device,
//        position: GestureBinding.instance.lastEvent.position,
//        pressure: GestureBinding.instance.lastEvent.pressure,
//        pressureMax: GestureBinding.instance.lastEvent.pressureMax,
//        pressureMin: GestureBinding.instance.lastEvent.pressureMin,
//        distance: GestureBinding.instance.lastEvent.distance,
//        distanceMax: GestureBinding.instance.lastEvent.distanceMax,
//        size: GestureBinding.instance.lastEvent.size,
//        radiusMajor: GestureBinding.instance.lastEvent.radiusMajor,
//        radiusMinor: GestureBinding.instance.lastEvent.radiusMinor,
//        radiusMin: GestureBinding.instance.lastEvent.radiusMin,
//        radiusMax: GestureBinding.instance.lastEvent.radiusMax,
//        orientation: GestureBinding.instance.lastEvent.orientation,
//        tilt: GestureBinding.instance.lastEvent.tilt,
//        transform: GestureBinding.instance.lastEvent.transform);
//    GestureBinding.instance.addToPendingPointerEvents(pointerUpEvent);
//    PointerAddedEvent pointerAddedEvent = PointerAddedEvent(
//        timeStamp: Duration(milliseconds: GestureBinding.instance.lastEvent.timeStamp.inMilliseconds + 100),
//        device: GestureBinding.instance.lastEvent.device,
//        position: GestureBinding.instance.lastEvent.position,
//        pressureMax: GestureBinding.instance.lastEvent.pressureMax,
//        pressureMin: GestureBinding.instance.lastEvent.pressureMin,
//        distance: GestureBinding.instance.lastEvent.distance,
//        distanceMax: GestureBinding.instance.lastEvent.distanceMax,
//        radiusMin: GestureBinding.instance.lastEvent.radiusMin,
//        radiusMax: GestureBinding.instance.lastEvent.radiusMax,
//        orientation: GestureBinding.instance.lastEvent.orientation,
//        tilt: GestureBinding.instance.lastEvent.tilt,
//        transform: GestureBinding.instance.lastEvent.transform);
//    GestureBinding.instance.addToPendingPointerEvents(pointerAddedEvent);
//    PointerDownEvent pointerDownEvent = PointerDownEvent(
//        timeStamp: Duration(milliseconds: GestureBinding.instance.lastEvent.timeStamp.inMilliseconds + 100),
//        pointer: GestureBinding.instance.lastEvent.pointer,
//        device: GestureBinding.instance.lastEvent.device,
//        position: GestureBinding.instance.lastEvent.position,
//        pressure: GestureBinding.instance.lastEvent.pressure,
//        pressureMax: GestureBinding.instance.lastEvent.pressureMax,
//        pressureMin: GestureBinding.instance.lastEvent.pressureMin,
//        distanceMax: GestureBinding.instance.lastEvent.distanceMax,
//        size: GestureBinding.instance.lastEvent.size,
//        radiusMajor: GestureBinding.instance.lastEvent.radiusMajor,
//        radiusMinor: GestureBinding.instance.lastEvent.radiusMinor,
//        radiusMin: GestureBinding.instance.lastEvent.radiusMin,
//        radiusMax: GestureBinding.instance.lastEvent.radiusMax,
//        orientation: GestureBinding.instance.lastEvent.orientation,
//        tilt: GestureBinding.instance.lastEvent.tilt,
//        transform: GestureBinding.instance.lastEvent.transform);
//    GestureBinding.instance.addToPendingPointerEvents(pointerDownEvent);
//    GestureBinding.instance.stopIgnoring();
  }

  @override
  void initState() {
    super.initState();

    lastActionTime = DateTime.now();

    animationController = AnimationController(
        vsync: this,
        duration: supportsForcePress ? const Duration(milliseconds: 333) : const Duration(milliseconds: 333 * 10),
        lowerBound: 0,
        upperBound: 1)
      ..addListener(updateAnimationTrackerNotifier)
      ..addStatusListener(primaryAnimationStatusListener);
    secondaryAnimationController = AnimationController(
        vsync: this,
        duration: supportsForcePress ? const Duration(milliseconds: 222) : const Duration(milliseconds: 333 * 10),
        lowerBound: 0,
        upperBound: 1)
      ..addListener(updateAnimationTrackerNotifier)
      ..addStatusListener(secondaryAnimationStatusListener);
    secondaryAnimation = Tween(begin: 0.0, end: 1.0 - peekScale - peekCoefficient + 0.025)
        .animate(CurvedAnimation(parent: secondaryAnimationController, curve: Curves.decelerate));
  }

  @override
  void dispose() {
    animationController.removeListener(updateAnimationTrackerNotifier);
    animationController.removeStatusListener(primaryAnimationStatusListener);
    animationController.dispose();
    secondaryAnimation.removeListener(updateAnimationTrackerNotifier);
    secondaryAnimationController.removeStatusListener(secondaryAnimationStatusListener);
    secondaryAnimationController.dispose();

    super.dispose();
  }

  void peekAndPopComplete() {
    if (willPeekAndPopComplete != null && !willPeekAndPopComplete(this)) return;
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;

    if (_debugLevel > 0) print("OnPeekAndPopComplete");

    isComplete = true;
    isDirect = true;
    ignoreAnimation = true;
    animationController.value = 1;
    secondaryAnimation = Tween(begin: 1.0 - peekScale - peekCoefficient, end: 1.0 - peekScale - peekCoefficient + 0.1)
        .animate(CurvedAnimation(parent: secondaryAnimationController, curve: supportsForcePress ? Curves.elasticInOut : Curves.decelerate));
    secondaryAnimationController.value = 0;

    Navigator.of(context).push(PeekAndPopRoute(this, (BuildContext context) => PeekAndPopChild(this), popTransition)).whenComplete(() {
      HapticFeedback.heavyImpact();

      lastActionTime = DateTime.now();
      Future.delayed(Duration(milliseconds: supportsForcePress ? 666 : 666 * 10), () {
        animationController.value = 0;
        secondaryAnimationController.value = 0;
        secondaryAnimation = Tween(begin: 0.0, end: 1.0 - peekScale - peekCoefficient + 0.1)
            .animate(CurvedAnimation(parent: secondaryAnimationController, curve: supportsForcePress ? Curves.elasticInOut : Curves.decelerate));
        animationTrackerNotifier.value = 0;
        peekAndPopChild?.reset();
        peekAndPopChild = null;
        isComplete = false;
        isPushed = false;
        isDirect = false;
        ignoreAnimation = false;
        pressReroutedNotifier.value = false;
      });

      if (onPeekAndPopComplete != null) onPeekAndPopComplete(this);
    });
  }

  void pushPeekAndPop(dynamic pressDetails) {
    if (willPushPeekAndPop != null && !willPushPeekAndPop(this)) return;
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;

    if (_debugLevel > 0) print("PushPeekAndPop");

    Navigator.of(context).push(PeekAndPopRoute(this, (BuildContext context) => PeekAndPopChild(this), popTransition)).whenComplete(() {
      HapticFeedback.heavyImpact();

      lastActionTime = DateTime.now();
      Future.delayed(Duration(milliseconds: supportsForcePress ? 666 : 666 * 10), () {
        animationController.value = 0;
        secondaryAnimationController.value = 0;
        secondaryAnimation = Tween(begin: 0.0, end: 1.0 - peekScale - peekCoefficient + 0.1)
            .animate(CurvedAnimation(parent: secondaryAnimationController, curve: supportsForcePress ? Curves.elasticInOut : Curves.decelerate));
        animationTrackerNotifier.value = 0;
        peekAndPopChild = null;
        peekAndPopChild?.reset();
        isComplete = false;
        isPushed = false;
        isDirect = false;
        ignoreAnimation = false;
        pressReroutedNotifier.value = false;
      });

      if (onPeekAndPopComplete != null) onPeekAndPopComplete(this);
    });

    if (supportsForcePress) jumpPeekAndPop(pressDetails.pressure);
  }

  void updatePeekAndPop(dynamic pressDetails, {bool isFromOverlayEntry: false}) {
    if (willUpdatePeekAndPop != null && !willUpdatePeekAndPop(this)) return;
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (!supportsForcePress) return;
    if (secondaryAnimationController.isAnimating) return;

    if (_debugLevel > 2) {
      if (!isFromOverlayEntry)
        print("PeekAndPopController: UpdatePeekAndPop = " + pressDetails.pressure.toString());
      else
        print("PeekAndPopChild: UpdatePeekAndPop = " + pressDetails.pressure.toString());
    }

    if (peekAndPopChild == null || !peekAndPopChild.willPeek) jumpPeekAndPop(pressDetails.pressure);
    if (peekAndPopChild != null && pressDetails.pressure > treshold) peekAndPopChild.Peek();

    if (onUpdatePeekAndPop != null) onUpdatePeekAndPop(this);
  }

  void cancelPeekAndPop(dynamic pressDetails, {bool isFromOverlayEntry: false}) {
    if (willCancelPeekAndPop != null && !willCancelPeekAndPop(this)) return;
    if (isComplete || !isPushed || DateTime.now().difference(lastActionTime).inSeconds < 1) return;

    if (_debugLevel > 0) {
      if (!isFromOverlayEntry)
        print("PeekAndPopController: CancelPeekAndPop");
      else
        print("PeekAndPopChild: CancelPeekAndPop");
    }

    drivePeekAndPop(false);
    if (peekAndPopChild?.animationController?.value != 0) peekAndPopChild.animationController.reverse();

    if (onCancelPeekAndPop != null) onCancelPeekAndPop(this);
  }

  void finishPeekAndPop(dynamic pressDetails, {bool isFromOverlayEntry: false}) {
    if (willFinishPeekAndPop != null && !willFinishPeekAndPop(this)) return;
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;

    drivePeekAndPop(true);

    if (onFinishPeekAndPop != null) onFinishPeekAndPop(this);
  }

  ///Use this function instead of using the Navigator.
  void closePeekAndPop() {
    if (willClosePeekAndPop != null && !willClosePeekAndPop(this)) return;
    if (!isComplete || !isPushed || DateTime.now().difference(lastActionTime).inSeconds < 1) return;

    if (_debugLevel > 0) print("ClosePeekAndPop");

    ignoreAnimation = true;
    Navigator.of(context).pop();

    if (onClosePeekAndPop != null) onClosePeekAndPop(this);
  }

  void drivePeekAndPop(bool forward) {
    if (_debugLevel > 0) print("DrivePeekAndPop: $forward");

    if (forward) {
      animationController.forward(from: animationController.value);
      secondaryAnimationController.forward(from: 0);
      if (!useCache) peekAndPopChild.setState(() {});
    } else {
      animationController.reverse();
      secondaryAnimationController.reverse();
    }
  }

  void jumpPeekAndPop(double value) {
    if (_debugLevel > 3) print("JumpPeekAndPop: $value");

    if (value == 1)
      finishPeekAndPop(null);
    else
      animationController.value = value;
  }

  void beginDrag(dynamic pressDetails) {
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (!supportsForcePress) return;
    if (secondaryAnimationController.isAnimating) return;

    if (_debugLevel > 2) print("BeginDrag");

    if (onPressStart != null) onPressStart(pressDetails);
  }

  void updateDrag(dynamic pressDetails) {
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (!supportsForcePress) return;
    if (secondaryAnimationController.isAnimating) return;

    if (_debugLevel > 2) print("UpdateDrag");

    if (onPressStart != null) onPressUpdate(pressDetails);
  }

  void endDrag(dynamic pressDetails) {
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (!supportsForcePress) return;
    if (secondaryAnimationController.isAnimating) return;

    if (_debugLevel > 2) print("EndDrag");

    if (onPressEnd != null) onPressEnd(pressDetails);
  }

  ///A value for tracking the stage of the Peek & Pop process.
  Stage get stage {
    if (!isPushed) return Stage.Null;
    if (secondaryAnimationController.isAnimating || isComplete) return Stage.Done;
  }

  @override
  Widget build(BuildContext context) {
    return PeekAndPopDetector(this, uiChild);
  }
}
