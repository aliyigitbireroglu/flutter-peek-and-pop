// © Cosmos Software | Ali Yigit Bireroglu All material used in the making of this code, project, program, application,
// software et cetera (the "Intellectual Property") belongs completely and solely to Ali Yigit Bireroglu. This includes but
// is not limited to the source code, the multimedia and other asset files. If you were granted this Intellectual Property
// for personal use, you are obligated to include this copyright text at all times.
// Copyright © 2019 Ali Yigit Bireroglu (https://www.cosmossoftare.coffee) All rights reserved.

//@formatter:off
import 'dart:ui';
import 'dart:math';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'gesture_detector.dart' as MyGestureDetector;

import 'Export.dart';

///The widget that is responsible of ALL Peek & Pop related logic. It works together with [PeekAndPopChildState] and [PeekAndPopDetector].
class PeekAndPopController extends StatefulWidget {
  ///The widget that is to be displayed on your regular UI.
  final Widget uiChild;
  ///The view to be displayed during the Peek & Pop process.
  final PeekAndPopBuilder peekAndPopBuilder;
  ///Set this to true if your [peekAndPopBuilder] doesn't change during the Peek & Pop process.
  final bool useCache;
  ///The color to be displayed over the [Backdrop] widget. The alpha of this color will be controlled internally and it will not exceed 126 (0.5).
  final Color backdropColor;
  ///An optional second view to be displayed over the [Backdrop] widget during the Peek & Pop process.
  final Widget overlayBuiler;
  ///Set this to true if your [peekAndPopBuilder] uses a [Hero] widget.
  final bool isHero;
  
  ///The callback for when the Peek & Pop successfully completes. This callback is invoked after the entire process.
  final PeekAndPopCallback onPeekAndPopComplete;
  ///The callback for when the view is initially pushed to the Navigator.
  final PeekAndPopCallback onPushPeekAndPop;
  ///The callback for when the state of the view is updated.
  final PeekAndPopCallback onUpdatePeekAndPop;
  ///The callback for when the Peek & Pop is cancelled.
  final PeekAndPopCallback onCancelPeekAndPop;
  ///The callback for when the view is being popped after peeking.
  final PeekAndPopCallback onFinishPeekAndPop;
  ///The callback for when the view is being closed after popping.
  final PeekAndPopCallback onClosePeekAndPop;

  ///The pressure treshold at which the view first becomes visible. The [Backdrop] widget does not depend on this.
  final double treshold;
  ///The min pressure for initiating the Peek & Pop process. Flutter's normal [GestureDetector] has relatively wrong values for a Peek & Pop process
  ///so a new [MyGestureDetector.GestureDetector] is created for altering these values. The new [MyGestureDetector.GestureDetector] is otherwise
  ///identical to Flutter's normal [GestureDetector].
  final double startPressure;
  ///The max pressure for finishing the Peek & Pop process. Flutter's normal [GestureDetector] has relatively wrong values for a Peek & Pop process
  ///so a new [MyGestureDetector.GestureDetector] is created for altering these values. The new [MyGestureDetector.GestureDetector] is otherwise
  ///identical to Flutter's normal [GestureDetector].
  final double peakPressure;
  ///The scale at which you want your view to be displayed when it first becomes visible.
  final double peekScale;
  ///The coefficient for controlling how much your view can rescale according to the pressure magnitude. A low value such as 0.05 is 
  ///recommended based on observations made by Swiss scientists.
  final double peekCoefficient;
  ///See [MoveController].
  final MoveController moveController;
  
  ///The transition to be used when:
  ///   a) The view is opened directly 
  ///   b) The view is closed. A default [SlideTransition] is provided.
  final Function popTransition;
  //TODO Change the name of this variable as it can cause confusion.

  const PeekAndPopController(
          this.uiChild,
          this.peekAndPopBuilder,
          this.useCache,
          {this.backdropColor: Colors.black,
          this.overlayBuiler,
          this.isHero:false,
          this.onPeekAndPopComplete,
          this.onPushPeekAndPop,
          this.onUpdatePeekAndPop,
          this.onCancelPeekAndPop,
          this.onFinishPeekAndPop,
          this.onClosePeekAndPop,
          this.treshold: 0.5,
          this.startPressure: 0.2,
          this.peakPressure: 0.9,
          this.peekScale: 0.5,
          this.peekCoefficient: 0.05,
          this.moveController,  
          this.popTransition});

  @override
  PeekAndPopControllerState createState() {
    return PeekAndPopControllerState(
            uiChild,
            peekAndPopBuilder,
            useCache,
            backdropColor,
            overlayBuiler,
            isHero,
            onPeekAndPopComplete,
            onPushPeekAndPop,
            onUpdatePeekAndPop,
            onCancelPeekAndPop,
            onFinishPeekAndPop,
            onClosePeekAndPop,
            treshold,
            startPressure,
            peakPressure,
            peekScale,
            peekCoefficient,
            moveController,
            popTransition);
  }
}

class PeekAndPopControllerState extends State<PeekAndPopController> with TickerProviderStateMixin {
  final Widget uiChild;
  final PeekAndPopBuilder peekAndPopBuilder;
  final bool useCache;
  final Color backdropColor;
  final Widget overlayBuilder;
  
  final bool isHero;
  
  final PeekAndPopCallback onPeekAndPopComplete;
  final PeekAndPopCallback onPushPeekAndPop;
  final PeekAndPopCallback onUpdatePeekAndPop;
  final PeekAndPopCallback onCancelPeekAndPop;
  final PeekAndPopCallback onFinishPeekAndPop;
  final PeekAndPopCallback onClosePeekAndPop;

  final double treshold;
  final double startPressure;
  final double peakPressure;
  final double peekScale;
  final double peekCoefficient;
  final MoveController moveController;
  
  final Function popTransition;
  
  ///A required precaution for preventing consecutive Peek & Pop processes without sufficient time. I actually forgot why it is required but it is 
  ///required.
  DateTime lastActionTime;

  ///The primary [AnimationController] used to set the values of the [Backdrop] widget and the view during the Peek stage.
  AnimationController animationController;
  ///The secondary [AnimationController] used to create an iOS-Style jump effect during the Pop stage.
  AnimationController secondaryAnimationController;
  ///The [Animation] controlled by the [secondaryAnimationController].
  Animation<double> secondaryAnimation;
  ///The tertiary [AnimationController] used to move the view if [PeekAndPopController.moveController] is set.
	AnimationController tertiaryAnimationController;
  ///The [Animation] controlled by the [tertiaryAnimationController].
  Animation<Offset> tertiaryAnimation;
  ///[ValueNotifier] for controlling the state of the [PeekAndPopChildState] as the [animationController] or the [secondaryAnimationController] changes.
  ValueNotifier<double> animationTrackerNotifier = ValueNotifier<double>(0.0);

  PeekAndPopChildState peekAndPopChild;

  ///A value for tracking the stage of the Peek & Pop process.
  bool isComplete = false;
  ///A value for tracking the stage of the Peek & Pop process.
  bool isPushed = false;
  //TODO: Use an Enum instead.
  
  ///A required precaution for behaving accordingly if the [uiChild] is tapped instead of pressed.
  bool isDirect = false;
  ///A required precaution for something that I also actually forgot. 
  bool ignoreAnimation = false;
  
  ///A [ValueNotifier] for rerouting gesture recognition from [PeekAndPopDetector] to [PeekAndPopChildState].
  ValueNotifier<bool> pressReroutedNotifier = ValueNotifier<bool>(false);

  ///Set this value to false if you want Long Press to be used instead of Force Press. Long Press version of this package is still under development
  ///and is not fully tested yet so consider it as a developers preview.
  bool supportsForcePress = true;

  ///The callback for resetting the state of the [PeekAndPopDetector] once the gesture recognition is rerouted to the instantiated 
  ///[PeekAndPopChildState] or vice-versa.
  Function callback;
  
  ///A value to determine the depth of debug printing that is actually only here for myself and the Swiss scientists. 
  int _debugLevel = 0;

  PeekAndPopControllerState(
    this.uiChild,
    this.peekAndPopBuilder,
    this.useCache,
    this.backdropColor,
    this.overlayBuilder,
    this.isHero,
    this.onPeekAndPopComplete,
    this.onPushPeekAndPop,
    this.onUpdatePeekAndPop,
    this.onCancelPeekAndPop,
    this.onFinishPeekAndPop,
    this.onClosePeekAndPop,
    this.treshold,
    this.startPressure,
    this.peakPressure,
    this.peekScale,
    this.peekCoefficient,
    this.moveController,
    this.popTransition);

  ///Called by both [animationController] and [secondaryAnimationController] to change the value of the [animationTrackerNotifier].
  void updateAnimationTrackerNotifier() {
    animationTrackerNotifier.value += 1;
  }

  ///[AnimationStatus] listener for the [animationController]. It is used to determine the stage of the Peek & Pop process.
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

  ///[AnimationStatus] listener for the [secondaryAnimationController]. It is used function to determine reverse the [secondaryAnimationController]
  /// after it plays once for the iOS-Style jump effect.
  void secondaryAnimationStatusListener(AnimationStatus animationStatus) {
    if (ignoreAnimation) return;

    switch (animationStatus) {
      case AnimationStatus.completed:
        secondaryAnimation = 
            Tween(
              begin: 1.0 - peekScale - peekCoefficient, 
              end: 1.0 - peekScale - peekCoefficient + 0.1)
            .animate(CurvedAnimation(
                      parent: secondaryAnimationController, 
                      curve: supportsForcePress ? Curves.elasticInOut : Curves.decelerate));
        secondaryAnimationController.reverse();
        break;
      default:
        break;
    }
  }
  //TODO: There must be a better way of doing this!
  
  ///This function is called by the instantiated [PeekAndPopChildState] once it is ready to be included in the Peek & Pop process. Perhaps the most
  ///essential functionality of this package also takes places in this function: The gesture recognition is rerouted from the  [PeekAndPopDetector]
  ///to the instantiated [PeekAndPopChildState]. This is important for avoiding the necessity of having the user stop and restart their Force Press.
  ///Instead, the [PeekAndPopControllerState] does this automatically so that the existing Force Press can continue to update even when if
  ///[PeekAndPopDetector] is blocked by the view which is often the case especially when using PlatformViews. 
  void pushComplete(PeekAndPopChildState peekAndPopChild) {
    if (_debugLevel > 1) print("PushComplete");

    this.peekAndPopChild = peekAndPopChild;
    isPushed = true;

    if (!isDirect) {
      pressReroutedNotifier.value = true;
      Future.delayed(Duration(milliseconds: 333), () {
        //UNCOMMENT HERE
//        GestureBinding.instance.StartIgnoring();
//        PointerUpEvent pointerUpEvent = PointerUpEvent(
//                                          timeStamp: Duration(milliseconds: GestureBinding.instance.lastEvent.timeStamp.inMilliseconds + 100),
//                                          pointer: GestureBinding.instance.lastEvent.pointer,
//                                          device: GestureBinding.instance.lastEvent.device,
//                                          position: GestureBinding.instance.lastEvent.position,
//                                          pressure: GestureBinding.instance.lastEvent.pressure,
//                                          pressureMax: GestureBinding.instance.lastEvent.pressureMax,
//                                          pressureMin: GestureBinding.instance.lastEvent.pressureMin,
//                                          distance: GestureBinding.instance.lastEvent.distance,
//                                          distanceMax: GestureBinding.instance.lastEvent.distanceMax,
//                                          size: GestureBinding.instance.lastEvent.size,
//                                          radiusMajor: GestureBinding.instance.lastEvent.radiusMajor,
//                                          radiusMinor: GestureBinding.instance.lastEvent.radiusMinor,
//                                          radiusMin: GestureBinding.instance.lastEvent.radiusMin,
//                                          radiusMax: GestureBinding.instance.lastEvent.radiusMax,
//                                          orientation: GestureBinding.instance.lastEvent.orientation,
//                                          tilt: GestureBinding.instance.lastEvent.tilt,
//                                          transform: GestureBinding.instance.lastEvent.transform);
//        GestureBinding.instance.AddToPendingPointerEvents(pointerUpEvent);
//        PointerAddedEvent pointerAddedEvent = PointerAddedEvent(
//                                                timeStamp: Duration(milliseconds: GestureBinding.instance.lastEvent.timeStamp.inMilliseconds + 100),
//                                                device: GestureBinding.instance.lastEvent.device,
//                                                position: GestureBinding.instance.lastEvent.position,
//                                                pressureMax: GestureBinding.instance.lastEvent.pressureMax,
//                                                pressureMin: GestureBinding.instance.lastEvent.pressureMin,
//                                                distance: GestureBinding.instance.lastEvent.distance,
//                                                distanceMax: GestureBinding.instance.lastEvent.distanceMax,
//                                                radiusMin: GestureBinding.instance.lastEvent.radiusMin,
//                                                radiusMax: GestureBinding.instance.lastEvent.radiusMax,
//                                                orientation: GestureBinding.instance.lastEvent.orientation,
//                                                tilt: GestureBinding.instance.lastEvent.tilt,
//                                                transform: GestureBinding.instance.lastEvent.transform);
//        GestureBinding.instance.AddToPendingPointerEvents(pointerAddedEvent);
//        PointerDownEvent pointerDownEvent = PointerDownEvent(
//                                              timeStamp: Duration(milliseconds: GestureBinding.instance.lastEvent.timeStamp.inMilliseconds + 100),
//                                              pointer: GestureBinding.instance.lastEvent.pointer,
//                                              device: GestureBinding.instance.lastEvent.device,
//                                              position: GestureBinding.instance.lastEvent.position,
//                                              pressure: GestureBinding.instance.lastEvent.pressure,
//                                              pressureMax: GestureBinding.instance.lastEvent.pressureMax,
//                                              pressureMin: GestureBinding.instance.lastEvent.pressureMin,
//                                              distanceMax: GestureBinding.instance.lastEvent.distanceMax,
//                                              size: GestureBinding.instance.lastEvent.size,
//                                              radiusMajor: GestureBinding.instance.lastEvent.radiusMajor,
//                                              radiusMinor: GestureBinding.instance.lastEvent.radiusMinor,
//                                              radiusMin: GestureBinding.instance.lastEvent.radiusMin,
//                                              radiusMax: GestureBinding.instance.lastEvent.radiusMax,
//                                              orientation: GestureBinding.instance.lastEvent.orientation,
//                                              tilt: GestureBinding.instance.lastEvent.tilt,
//                                              transform: GestureBinding.instance.lastEvent.transform);
//        GestureBinding.instance.AddToPendingPointerEvents(pointerDownEvent);
//        GestureBinding.instance.StopIgnoring();
      });
    }

    if (!supportsForcePress) drivePeekAndPop(true);
    
    if (onPushPeekAndPop != null) onPushPeekAndPop(this);
  }

  @override
  void initState() {
    super.initState();

    lastActionTime = DateTime.now();

    animationController = 
      AnimationController(
        vsync: this, 
        duration: supportsForcePress ? const Duration(milliseconds: 333) : const Duration(milliseconds: 333*10), 
        lowerBound: 0, 
        upperBound: 1)
      ..addListener(updateAnimationTrackerNotifier)
      ..addStatusListener(primaryAnimationStatusListener);
    secondaryAnimationController = 
      AnimationController(
        vsync: this, 
        duration: supportsForcePress ? const Duration(milliseconds: 166) : const Duration(milliseconds: 166*10), 
        lowerBound: 0, 
        upperBound: 1)
      ..addListener(updateAnimationTrackerNotifier)
      ..addStatusListener(secondaryAnimationStatusListener);
    secondaryAnimation = 
      Tween(
        begin: 0.0, 
        end: 1.0 - peekScale - peekCoefficient + 0.1)
      .animate(CurvedAnimation(
                parent: secondaryAnimationController, 
                curve: supportsForcePress ? Curves.elasticInOut : Curves.decelerate));
    tertiaryAnimationController = 
			AnimationController(
				vsync: this, 
				duration: supportsForcePress ? const Duration(milliseconds: 333) : const Duration(milliseconds: 333*10), 
				lowerBound: 0, upperBound: 1)
			..addListener((){
			  moveController?.setOverrideMoveOffset(tertiaryAnimation.value);
			  updateAnimationTrackerNotifier();
      })
			..addStatusListener((_) {});
		tertiaryAnimation = 
			Tween(
				begin: Offset(0,0), 
				end: Offset(0,0))
			.animate(CurvedAnimation(
								parent: tertiaryAnimationController, 
								curve: supportsForcePress ? Curves.fastOutSlowIn : Curves.decelerate));
  }

  @override
  void dispose() {
    animationController.removeListener(updateAnimationTrackerNotifier);
    animationController.removeStatusListener(primaryAnimationStatusListener);
    animationController.dispose();
    secondaryAnimation.removeListener(updateAnimationTrackerNotifier);
    secondaryAnimationController.removeStatusListener(secondaryAnimationStatusListener);
    secondaryAnimationController.dispose();
		tertiaryAnimationController.removeListener(() {});
		tertiaryAnimationController.removeStatusListener((_) {});
		tertiaryAnimationController.dispose();
    
    super.dispose();
  }

  ///This function is called if the [uiChild] is tapped instead of pressed.
  void peekAndPopComplete() {
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;

    if (_debugLevel > 0) print("OnPeekAndPopComplete");

    isComplete = true;
    isDirect = true;
    ignoreAnimation = true;
    animationController.value = 1;
    secondaryAnimation = 
            Tween(
              begin: 1.0 - peekScale - peekCoefficient, 
              end: 1.0 - peekScale - peekCoefficient + 0.1)
            .animate(CurvedAnimation(
                      parent: secondaryAnimationController, 
                      curve: supportsForcePress ? Curves.elasticInOut : Curves.decelerate));
    secondaryAnimationController.value = 0;

    Navigator.of(context).push(PeekAndPopRoute(this,(BuildContext context) => PeekAndPopChild(this), popTransition))
    .whenComplete(() {
      HapticFeedback.heavyImpact();

      lastActionTime = DateTime.now();
      Future.delayed(Duration(milliseconds: supportsForcePress ? 666 : 666*10), () {
        animationController.value = 0;
        secondaryAnimationController.value = 0;
        secondaryAnimation = 
          Tween(
              begin: 0.0, 
              end: 1.0 - peekScale - peekCoefficient + 0.1)
          .animate(CurvedAnimation(
                    parent: secondaryAnimationController, 
                    curve: supportsForcePress ? Curves.elasticInOut : Curves.decelerate));
        tertiaryAnimationController.value = 0;
        animationTrackerNotifier.value = 0;
        peekAndPopChild = null;
        isComplete = false;
        isPushed = false;
        isDirect = false;
        ignoreAnimation = false;
        peekAndPopChild?.reset();
        moveController?.reset();
        pressReroutedNotifier.value = false;
      });

      if (onPeekAndPopComplete != null) onPeekAndPopComplete(this);
    });
  }

  ///Initial stage of the Peek & Pop process.
  void pushPeekAndPop(dynamic pressDetails) {
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;

    if (_debugLevel > 0) print("PushPeekAndPop");

    Navigator.of(context).push(PeekAndPopRoute(this, (BuildContext context) => PeekAndPopChild(this), popTransition))
    .whenComplete(() {
      HapticFeedback.heavyImpact();

      lastActionTime = DateTime.now();
      Future.delayed(Duration(milliseconds: supportsForcePress ? 666 : 666*10), () {
        animationController.value = 0;
        secondaryAnimationController.value = 0;
        secondaryAnimation = 
          Tween(
            begin: 0.0, 
            end: 1.0 - peekScale - peekCoefficient + 0.1)
            .animate(CurvedAnimation(
                      parent: secondaryAnimationController, 
                      curve: supportsForcePress ? Curves.elasticInOut : Curves.decelerate));
        tertiaryAnimationController.value = 0;
        animationTrackerNotifier.value = 0;
        peekAndPopChild = null;
        isComplete = false;
        isPushed = false;
        isDirect = false;
        ignoreAnimation = false;
        peekAndPopChild?.reset();
        moveController?.reset();
        pressReroutedNotifier.value = false;
      });
      
      if (onPeekAndPopComplete != null) onPeekAndPopComplete(this);
    });

    if (supportsForcePress) jumpPeekAndPop(pressDetails.pressure);
  }

  ///Main stage of the Peek & Pop process.
  void updatePeekAndPop(dynamic pressDetails, {bool isFromOverlayEntry: false}) {
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (!supportsForcePress) return;
    if (secondaryAnimationController.isAnimating) return;

    if (_debugLevel > 2) {
      if (!isFromOverlayEntry)
        print("PeekAndPopController: UpdatePeekAndPop = " + pressDetails.pressure.toString());
      else
        print("PeekAndPopChild: UpdatePeekAndPop = " + pressDetails.pressure.toString());
    }

    jumpPeekAndPop(pressDetails.pressure);
    if (pressDetails.pressure > treshold && peekAndPopChild?.animationController?.value == 0) peekAndPopChild.animationController.forward(from: 0.5);
    else if(moveController != null && moveController.canSetMoveOffset){
      moveController.canSetMoveOffset= false;
      Future.delayed(Duration(milliseconds: 333), () {
        moveController.currentMoveOffset = Offset(-1,-1);
      });
    }
    if(moveController?.currentMoveOffset != null){
      if(moveController.currentMoveOffset.dx == -1 || moveController.currentMoveOffset.dy == -1) {
        moveController.initialMoveOffset = pressDetails.localPosition;
        moveController.currentMoveOffset = pressDetails.localPosition;
      }
      else 
        moveController.setCurrentMoveOffset(pressDetails.localPosition);
    }

    if (onUpdatePeekAndPop != null) onUpdatePeekAndPop(this);
  }
  
  ///Cancellation stage of the Peek & Pop process.
  void cancelPeekAndPop(dynamic pressDetails, {bool isFromOverlayEntry: false, bool ignoreMoveOffset:false}) {
    if (isComplete || !isPushed || DateTime.now().difference(lastActionTime).inSeconds < 1) return;

    if (_debugLevel > 0) {
      if (!isFromOverlayEntry)
        print("PeekAndPopController: CancelPeekAndPop");
      else
        print("PeekAndPopChild: CancelPeekAndPop");
    }
    
    if(moveController != null){
      if(ignoreMoveOffset){
        if(moveController.isMoved)
          Future.wait([moveToCenter()]).then((_) {
              drivePeekAndPop(false);
              if (peekAndPopChild?.animationController?.value != 0) peekAndPopChild.animationController.reverse();
          
              if (onCancelPeekAndPop != null) onCancelPeekAndPop(this);
            });
      }
      else{
        MoveOffset moveOffset = moveController.getMoveOffset();
        switch(moveOffset){
          case MoveOffset.ZERO:
            break;
          case MoveOffset.CENTER:
            Future.wait([moveToCenter()]).then((_) {
              drivePeekAndPop(false);
              if (peekAndPopChild?.animationController?.value != 0) peekAndPopChild.animationController.reverse();
          
              if (onCancelPeekAndPop != null) onCancelPeekAndPop(this);
            });
            return;
            break;
          case MoveOffset.CONSTRAIN:
            Future.wait([moveToConstrains()]).then((_) {
                
            });
            return;
            break;
        }     
      }
    }

    drivePeekAndPop(false);
    if (peekAndPopChild?.animationController?.value != 0) peekAndPopChild.animationController.reverse();

    if (onCancelPeekAndPop != null) onCancelPeekAndPop(this);
  }

  ///Conclusion stage of the Peek & Pop process.
  void finishPeekAndPop(dynamic pressDetails, {bool isFromOverlayEntry: false, bool ignoreMoveOffset:false}) {
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if(moveController != null){
      if(ignoreMoveOffset){
        if(moveController.isMoved)
          Future.wait([moveToCenter()]).then((_) {
              drivePeekAndPop(true);
  
              if (onFinishPeekAndPop != null) onFinishPeekAndPop(this);
            });
      }
      else{
        MoveOffset moveOffset = moveController.getMoveOffset();
        switch(moveOffset){
          case MoveOffset.ZERO:
            break;
          case MoveOffset.CENTER:
            Future.wait([moveToCenter()]).then((_) {
              drivePeekAndPop(true);
  
              if (onFinishPeekAndPop != null) onFinishPeekAndPop(this);
            });
            return;
            break;
          case MoveOffset.CONSTRAIN:
            return;
            break;
        }
      }
    }
    
    drivePeekAndPop(true);

    if (onFinishPeekAndPop != null) onFinishPeekAndPop(this);
  }
  
  ///To close the Peek & Pop process, call this function instead of using the Navigator yourself.
  void closePeekAndPop() {
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
      secondaryAnimationController.forward(from:0);
      if(!useCache) peekAndPopChild.setState(() {});
    } 
    else {
      animationController.reverse();
      secondaryAnimationController.reverse();
    }
  }

  void jumpPeekAndPop(double value) {
    if (_debugLevel > 3) print("JumpPeekAndPop: $value");

    if(value == 1 ) finishPeekAndPop(null);
    else animationController.value = value;
  }
  
  ///This function is called when a drag occurs on the view if it is moved by the [PeekAndPopController.moveController].
  void beginDrag(DragStartDetails dragStartDetails){
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (!supportsForcePress) return;
    if (secondaryAnimationController.isAnimating) return;
    if (moveController == null) return;

    if (_debugLevel > 2) 
      print("BeginDrag");
  }
  
  ///This function is called when a drag occurs on the view if it is moved by the [PeekAndPopController.moveController].
  void updateDrag(DragUpdateDetails dragUpdateDetails){
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (!supportsForcePress) return;
    if (secondaryAnimationController.isAnimating) return;
    if (moveController == null) return;
    if (tertiaryAnimationController.isAnimating) return;

    if (_debugLevel > 2) 
      print("UpdateDrag");
    
    moveController.setCurrentMoveOffset(moveController.currentMoveOffset+dragUpdateDetails.delta);
    updateAnimationTrackerNotifier();
  }
  
  ///This function is called when a drag occurs on the view if it is moved by the [PeekAndPopController.moveController].
  void endDrag(DragEndDetails dragEndDetails){
    if (isComplete || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (!supportsForcePress) return;
    if (secondaryAnimationController.isAnimating) return;
    if (moveController == null) return;
    
    if (_debugLevel > 2) 
      print("EndDrag");
    
    cancelPeekAndPop(null);
  }
  
	Future moveToCenter() async{
		tertiaryAnimation = 
			Tween(
				begin: moveController.overrideMoveOffset, 
				end: - moveController.delta + moveController.overrideMoveOffset)
			.animate(CurvedAnimation(
								parent: tertiaryAnimationController, 
								curve: supportsForcePress ? Curves.fastOutSlowIn : Curves.decelerate));
		tertiaryAnimationController.forward(from:0);
		await Future.delayed(Duration(milliseconds: 333));
		return;
	}
	
	Future moveToConstrains() async{
		tertiaryAnimation = 
			Tween(
				begin: moveController.overrideMoveOffset, 
				end: moveController.currentClipTarget - moveController.delta + moveController.overrideMoveOffset)
			.animate(CurvedAnimation(
								parent: tertiaryAnimationController, 
								curve: supportsForcePress ? Curves.fastOutSlowIn : Curves.decelerate));
		tertiaryAnimationController.forward(from:0);
		await Future.delayed(Duration(milliseconds: 333));
		return;
	}

  @override
  Widget build(BuildContext context) {
    return PeekAndPopDetector(this, uiChild);
  }
}

///Enum to control how the view should reposition during the Peek stage if necessary.
enum MoveOffset{
  ZERO,
  CENTER,
  CONSTRAIN
}
///A simple class to organise the information about if and how the view can move during the Peek stage.
class MoveController{
  bool canSetMoveOffset = true;
  Offset initialMoveOffset;
  Offset currentMoveOffset;
  Offset overrideMoveOffset = Offset.zero;
  
  ///Use this value to set the lower left boundary of the movement. For example, setting this value to (0.0, 5000.0) will ensure the view can't move
  ///to the left. 
  Offset constraintsMin;
  ///Use this value to set the upper right boundary of the movement. For example, setting this value to (0.0, 5000.0) will ensure the view can't move
  ///to the right. 
  Offset constraintsMax;
  ///Use this value to set the lower left elasticity of the movement. 
  Offset flexibilityMin;
  ///Use this value to set the upper right elasticity of the movement.
  Offset flexibilityMax;
  ///Use this value to set offset to which the view should clip if close enough when the gestures are over.
  List<Offset> clipTargets;
  
  Offset currentClipTarget;
  
  void setCurrentMoveOffset(Offset _currentMoveOffset){
    currentMoveOffset = _currentMoveOffset;
    if(callback!=null) callback(delta);
  }
  
  void setOverrideMoveOffset (Offset _overrideMoveOffset){
    overrideMoveOffset = _overrideMoveOffset;
    if(callback!=null) callback(delta);
  }
  
  ///Use this value to get the current [Offset] of the movement.
  Offset get delta{
    if(initialMoveOffset == null || currentMoveOffset == null) return Offset.zero;
    
    Offset _delta = Offset(currentMoveOffset.dx-initialMoveOffset.dx, currentMoveOffset.dy-initialMoveOffset.dy);
    if(_delta.dx < constraintsMin.dx)
      _delta = Offset(constraintsMin.dx - pow((_delta.dx-constraintsMin.dx).abs(), flexibilityMin.dx) + 1.0, _delta.dy);
    if(_delta.dx > constraintsMax.dx)
      _delta = Offset(constraintsMax.dx + pow((_delta.dx-constraintsMax.dx).abs(), flexibilityMax.dx) - 1.0, _delta.dy);
    if(_delta.dy < constraintsMin.dy)
      _delta = Offset(_delta.dx, constraintsMin.dy - pow((_delta.dy-constraintsMin.dy).abs(), flexibilityMin.dy) + 1.0);
    if(_delta.dy > constraintsMax.dy)
      _delta = Offset(_delta.dx, constraintsMax.dy + pow((_delta.dy-constraintsMax.dy).abs(), flexibilityMax.dy) - 1.0);
    return _delta + overrideMoveOffset;
  }
  
  MoveOffset getMoveOffset(){
    if(!isMoved) return MoveOffset.ZERO;
    
    if(clipTargets!=null) {
      double minDistance = double.infinity;
      clipTargets.forEach((Offset offset){
        double distance = Point(delta.dx, delta.dy).distanceTo(Point(offset.dx, offset.dy));
        if(distance < minDistance){
          currentClipTarget = offset;
          minDistance = distance; 
        }
      });
      double distance = Point(delta.dx, delta.dy).distanceTo(Point(0,0));
      if(distance < minDistance) return MoveOffset.CENTER;
      else return MoveOffset.CONSTRAIN;
    }
    else return MoveOffset.CENTER;
  }
  bool get isMoved {
    return delta.dx.abs() > 10 || delta.dy.abs() > 10;
  }
  
  ///The callback for when the view moves.
  PeekAndPopMoveCallback callback;
  
  MoveController(
    this.constraintsMin, 
    this.constraintsMax, 
    this.flexibilityMin,
    this.flexibilityMax,
    {this.clipTargets,
    this.callback});
  
  void reset(){
    canSetMoveOffset = true;
    initialMoveOffset = null;
    currentMoveOffset = null;
    overrideMoveOffset = Offset.zero;
  }
}