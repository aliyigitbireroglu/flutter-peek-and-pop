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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'gesture_detector.dart' as MyGestureDetector;
import 'Export.dart';

///The widget that is responsible of ALL Peek & Pop related logic. It works together with [PeekAndPopChild] and [PeekAndPopDetector].
class PeekAndPopController extends StatefulWidget {
  ///The widget that is to be displayed on your regular UI.
  final Widget uiChild;

  ///Set this to true if your [uiChild] doesn't change during the Peek & Pop process.
  final bool uiChildUseCache;

  ///The view to be displayed during the Peek & Pop process.
  final PeekAndPopBuilder peekAndPopBuilder;

  ///Set this to true if your [peekAndPopBuilder] doesn't change during the Peek & Pop process.
  final bool peekAndPopBuilderUseCache;

  ///The Quick Actions to be displayed if the view is dragged and snapped. Leave null if you do not wish to use Quick Actions.
  final QuickActionsBuilder quickActionsBuilder;

  ///The maximum [BackdropFilter.sigmaX] and [BackdropFilter.sigmaY] to be applied to the [Blur] widget.
  final double sigma;

  ///The color to be displayed over the [Blur] widget. The alpha of this color is controlled by the [PeekAndPopControllerState.primaryAnimationController]
  ///based on your [alpha] value.
  final Color backdropColor;

  ///The maximum alpha to be applied to your [backdropColor] by the [PeekAndPopControllerState.primaryAnimationController].
  final int alpha;

  ///An optional second view to be displayed during the Peek & Pop process. See [PeekAndPopChildState.build] for more.
  final Widget overlayBuiler;

  ///Set this to true if you want your [peekAndPopBuilder] to appear based on the Rect of your [uiChild]. If [customOverlapRect] is provided, it
  ///will override the Rect of your [uiChild]. Not recommended to use at the same time as [useOverlap] but it won't cause problems as can be seen
  ///in the example project.
  final bool useOverlap;

  ///See [useOverlap].
  final Rect customOverlapRect;

  ///Set this to true if you want your [peekAndPopBuilder] to appear based on the center of your [uiChild]. If set to false, the
  ///[peekAndPopBuilder] will appear from the center of the page. Not recommended to use at the same time as [useOverlap] but it won't cause
  ///problems as can be seen in the example project.
  final bool useAlignment;

  ///Set this to false if you do not want your [uiChild] to be persistent on the screen until the Peek stage.
  final bool useIndicator;

  ///The coefficient for determining how much the indicator should scale up during the Peek stage. 0.0 means no scaling.
  final double indicatorScaleUpCoefficient;

  ///The callback for when the Peek & Pop process is about to successfully complete. You can return false to prevent the default action.
  final PeekAndPopProcessNotifier willPeekAndPopComplete;

  ///The callback for when the view is about to be initially pushed to the Navigator. You can return false to prevent the default action.
  final PeekAndPopProcessNotifier willPushPeekAndPop;

  ///The callback for when the state of the view is about to be updated. You can return false to prevent the default action.
  final PeekAndPopProcessNotifier willUpdatePeekAndPop;

  ///The callback for when the Peek & Pop process is about to be cancelled. You can return false to prevent the default action.
  final PeekAndPopProcessNotifier willCancelPeekAndPop;

  ///The callback for when the view is about to be popped after peeking. You can return false to prevent the default action.
  final PeekAndPopProcessNotifier willFinishPeekAndPop;

  ///The callback for when the view is about to be closed after popping. You can return false to prevent the default action.
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
  final Function pageTransition;

  const PeekAndPopController(
    this.uiChild,
    this.uiChildUseCache,
    this.peekAndPopBuilder,
    this.peekAndPopBuilderUseCache, {
    Key key,
    this.quickActionsBuilder,
    this.sigma: 10,
    this.backdropColor: Colors.black,
    this.alpha: 126,
    this.overlayBuiler,
    this.useOverlap: true,
    this.customOverlapRect,
    this.useAlignment: false,
    this.useIndicator: true,
    this.indicatorScaleUpCoefficient: 0.0,
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
    this.startPressure: 0.125,
    this.peakPressure: 1.0,
    this.peekScale: 0.5,
    this.peekCoefficient: 0.05,
    this.pageTransition,
  }) : super(key: key);

  @override
  PeekAndPopControllerState createState() {
    return PeekAndPopControllerState(
      uiChild,
      uiChildUseCache,
      peekAndPopBuilder,
      peekAndPopBuilderUseCache,
      quickActionsBuilder,
      sigma,
      backdropColor,
      alpha,
      useOverlap,
      customOverlapRect,
      useAlignment,
      overlayBuiler,
      useIndicator,
      indicatorScaleUpCoefficient,
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
      pageTransition,
    );
  }
}

class PeekAndPopControllerState extends State<PeekAndPopController> with TickerProviderStateMixin {
  final Widget uiChild;
  final bool uiChildUseCache;
  final PeekAndPopBuilder peekAndPopBuilder;
  final bool peekAndPopBuilderUseCache;
  final QuickActionsBuilder quickActionsBuilder;
  QuickActionsData quickActionsData;
  bool get hasQuickActions {
    return quickActionsData != null && quickActionsData.quickActions != null && quickActionsData.quickActions.length > 0;
  }

  final double sigma;
  final Color backdropColor;
  final int alpha;
  final bool useOverlap;
  final Rect customOverlapRect;
  final bool useAlignment;
  final Widget overlayBuilder;
  final bool useIndicator;
  final double indicatorScaleUpCoefficient;
  OverlayEntry indicator;
  final GlobalKey uiChildContainer = GlobalKey();

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

  final Function pageTransition;

  PeekAndPopChildState peekAndPopChild;

  ///A required precaution for preventing consecutive Peek & Pop processes without sufficient time.
  ///(I actually forgot why it is required but it is required.)
  DateTime lastActionTime;

  ///The [AnimationController] used to set the values of the [Blur] widget and to set the scale of the view during the Peek stage.
  AnimationController primaryAnimationController;

  ///The [AnimationController] used to set the scale of the view during the Pop stage for creating an iOS-Style jump effect.
  AnimationController secondaryAnimationController;
  Animation<double> secondaryAnimation;

  final ValueNotifier<int> animationTrackerNotifier = ValueNotifier<int>(0);

  ///See [pushComplete].
  PointerDataPacketCallback pointerDataPacketCallback;

  ///See [pushComplete].
  PointerDataPacket pointerDataPacket;

  ///See [pushComplete].
  bool isLocked = false;

  ///See [pushComplete].
  final ValueNotifier<int> pressReroutedNotifier = ValueNotifier<int>(0);

  ///A value for tracking the stage of the Peek & Pop process.
  Stage stage = Stage.None;

  ///A value for simply tracking if the Peek & Pop process will be completed.
  bool get willBeDone {
    return stage == Stage.WillComplete || stage == Stage.WillFinish;
  }

  ///A value for simply tracking if the Peek & Pop process is completed.
  bool get isDone {
    return stage == Stage.IsComplete || stage == Stage.IsFinished || stage == Stage.WillClose || stage == Stage.IsClosed;
  }

  bool isDirect = false;

  DateTime pushTime;

  ///A required precaution.
  ///(I also forgot why.)
  bool ignoreAnimation = false;

  ///The callback for resetting the state of the [PeekAndPopDetector] once the gesture recognition is rerouted to the instantiated
  ///[PeekAndPopChild] or vice-versa.
  Function callback;

  double width = -1;
  double height = -1;
  double minimumLengthInBytes = 5000;

  ///Use this value to determine the depth of debug logging that is actually only here for myself and the Swiss scientists.
  final int _debugLevel = 10;

  PeekAndPopControllerState(
    this.uiChild,
    this.uiChildUseCache,
    this.peekAndPopBuilder,
    this.peekAndPopBuilderUseCache,
    this.quickActionsBuilder,
    this.sigma,
    this.backdropColor,
    this.alpha,
    this.useOverlap,
    this.customOverlapRect,
    this.useAlignment,
    this.overlayBuilder,
    this.useIndicator,
    this.indicatorScaleUpCoefficient,
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
    this.pageTransition,
  );

  void updateTrackerNotifiers() {
    animationTrackerNotifier.value++;
    if (peekAndPopChild != null) peekAndPopChild.updateTrackerNotifiers();
  }

  void primaryAnimationStatusListener(AnimationStatus animationStatus) {
    if (ignoreAnimation) return;

    switch (animationStatus) {
      case AnimationStatus.completed:
        HapticFeedback.mediumImpact();

        lastActionTime = DateTime.now();

        if (callback != null) callback();
        break;
      case AnimationStatus.dismissed:
        HapticFeedback.mediumImpact();

        lastActionTime = DateTime.now();

        Navigator.of(context).pop();

        stage = Stage.IsCancelled;
        print(stage);
        transformBloc.dispatch(0.0);

        if (peekAndPopChild != null) peekAndPopChild.blurTrackerNotifier.value++;

        if (callback != null) callback();
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
        secondaryAnimation = Tween(
          begin: 1.0 - peekScale - peekCoefficient,
          end: 1.0 - peekScale - peekCoefficient + 0.025,
        ).animate(
          CurvedAnimation(
            parent: secondaryAnimationController,
            curve: Curves.decelerate,
          ),
        );
        secondaryAnimationController.reverse();
        break;
      case AnimationStatus.dismissed:
        stage = Stage.IsFinished;
        print(stage);
        transformBloc.dispatch(0.0);

        if (peekAndPopChild != null) peekAndPopChild.blurTrackerNotifier.value++;
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
    pushTime = DateTime.now();

    if (!isDirect) {
      stage = Stage.IsPushed;
      print(stage);
    }
  }

  ///See [pushComplete].
  void _pointerDataPacketCallback(PointerDataPacket _pointerDataPacket) {
    pointerDataPacket = _pointerDataPacket;
  }

  ///See [pushComplete].
  void unlockPress() {
    if (_debugLevel > 4) print("Unlocking GestureBinding.");

    isLocked = false;
  }

  ///See [pushComplete].
  Future reroutePress() async {
    if (_debugLevel > 4) print("Waiting for isPushed || !isLocked.");

    while (stage != Stage.IsPushed) await Future.delayed(const Duration(milliseconds: 1));
    isLocked = true;
    pressReroutedNotifier.value = 1;
    while (isLocked) await Future.delayed(const Duration(milliseconds: 1));

    if (_debugLevel > 4) print("Resuming GestureBinding.");

    window.onPointerDataPacket = pointerDataPacketCallback;

    if (_debugLevel > 4) print("Resetting GestureBinding.");

    PointerData lastPointerData = pointerDataPacket.data.last;
    PointerDataPacket pointerDataPacketUp = PointerDataPacket(
      data: [
        PointerData(
          timeStamp: Duration(milliseconds: lastPointerData.timeStamp.inMilliseconds + 1),
          change: PointerChange.up,
          kind: lastPointerData.kind,
          signalKind: lastPointerData.signalKind,
          device: lastPointerData.device,
          physicalX: lastPointerData.physicalX,
          physicalY: lastPointerData.physicalY,
          buttons: lastPointerData.buttons,
          obscured: lastPointerData.obscured,
          pressure: lastPointerData.pressure,
          pressureMin: lastPointerData.pressureMin,
          pressureMax: lastPointerData.pressureMax,
          distance: lastPointerData.distance,
          distanceMax: lastPointerData.distanceMax,
          size: lastPointerData.size,
          radiusMajor: lastPointerData.radiusMajor,
          radiusMinor: lastPointerData.radiusMinor,
          radiusMin: lastPointerData.radiusMin,
          radiusMax: lastPointerData.radiusMax,
          orientation: lastPointerData.orientation,
          tilt: lastPointerData.tilt,
          platformData: lastPointerData.platformData,
          scrollDeltaX: lastPointerData.scrollDeltaX,
          scrollDeltaY: lastPointerData.scrollDeltaY,
        ),
      ],
    );
    PointerDataPacket pointerDataPacketRemove = PointerDataPacket(
      data: [
        PointerData(
          timeStamp: Duration(milliseconds: lastPointerData.timeStamp.inMilliseconds + 2),
          change: PointerChange.remove,
          kind: lastPointerData.kind,
          signalKind: lastPointerData.signalKind,
          device: lastPointerData.device,
          physicalX: lastPointerData.physicalX,
          physicalY: lastPointerData.physicalY,
          buttons: lastPointerData.buttons,
          obscured: lastPointerData.obscured,
          pressure: lastPointerData.pressure,
          pressureMin: lastPointerData.pressureMin,
          pressureMax: lastPointerData.pressureMax,
          distance: lastPointerData.distance,
          distanceMax: lastPointerData.distanceMax,
          size: lastPointerData.size,
          radiusMajor: lastPointerData.radiusMajor,
          radiusMinor: lastPointerData.radiusMinor,
          radiusMin: lastPointerData.radiusMin,
          radiusMax: lastPointerData.radiusMax,
          orientation: lastPointerData.orientation,
          tilt: lastPointerData.tilt,
          platformData: lastPointerData.platformData,
          scrollDeltaX: lastPointerData.scrollDeltaX,
          scrollDeltaY: lastPointerData.scrollDeltaY,
        ),
      ],
    );
    PointerDataPacket pointerDataPacketAdd = PointerDataPacket(
      data: [
        PointerData(
          timeStamp: Duration(milliseconds: lastPointerData.timeStamp.inMilliseconds + 3),
          change: PointerChange.add,
          kind: lastPointerData.kind,
          signalKind: lastPointerData.signalKind,
          device: lastPointerData.device,
          physicalX: lastPointerData.physicalX,
          physicalY: lastPointerData.physicalY,
          buttons: lastPointerData.buttons,
          obscured: lastPointerData.obscured,
          pressure: lastPointerData.pressure,
          pressureMin: lastPointerData.pressureMin,
          pressureMax: lastPointerData.pressureMax,
          distance: lastPointerData.distance,
          distanceMax: lastPointerData.distanceMax,
          size: lastPointerData.size,
          radiusMajor: lastPointerData.radiusMajor,
          radiusMinor: lastPointerData.radiusMinor,
          radiusMin: lastPointerData.radiusMin,
          radiusMax: lastPointerData.radiusMax,
          orientation: lastPointerData.orientation,
          tilt: lastPointerData.tilt,
          platformData: lastPointerData.platformData,
          scrollDeltaX: lastPointerData.scrollDeltaX,
          scrollDeltaY: lastPointerData.scrollDeltaY,
        ),
      ],
    );
    PointerDataPacket pointerDataPacketDown = PointerDataPacket(
      data: [
        PointerData(
          timeStamp: Duration(milliseconds: lastPointerData.timeStamp.inMilliseconds + 4),
          change: PointerChange.down,
          kind: lastPointerData.kind,
          signalKind: lastPointerData.signalKind,
          device: lastPointerData.device,
          physicalX: lastPointerData.physicalX,
          physicalY: lastPointerData.physicalY,
          buttons: lastPointerData.buttons,
          obscured: lastPointerData.obscured,
          pressure: lastPointerData.pressure,
          pressureMin: lastPointerData.pressureMin,
          pressureMax: lastPointerData.pressureMax,
          distance: lastPointerData.distance,
          distanceMax: lastPointerData.distanceMax,
          size: lastPointerData.size,
          radiusMajor: lastPointerData.radiusMajor,
          radiusMinor: lastPointerData.radiusMinor,
          radiusMin: lastPointerData.radiusMin,
          radiusMax: lastPointerData.radiusMax,
          orientation: lastPointerData.orientation,
          tilt: lastPointerData.tilt,
          platformData: lastPointerData.platformData,
          scrollDeltaX: lastPointerData.scrollDeltaX,
          scrollDeltaY: lastPointerData.scrollDeltaY,
        ),
      ],
    );
    PointerDataPacket pointerDataPacketMove = PointerDataPacket(
      data: [
        PointerData(
          timeStamp: Duration(milliseconds: lastPointerData.timeStamp.inMilliseconds + 5),
          change: PointerChange.move,
          kind: lastPointerData.kind,
          signalKind: lastPointerData.signalKind,
          device: lastPointerData.device,
          physicalX: lastPointerData.physicalX,
          physicalY: lastPointerData.physicalY,
          buttons: lastPointerData.buttons,
          obscured: lastPointerData.obscured,
          pressure: lastPointerData.pressure,
          pressureMin: lastPointerData.pressureMin,
          pressureMax: lastPointerData.pressureMax,
          distance: lastPointerData.distance,
          distanceMax: lastPointerData.distanceMax,
          size: lastPointerData.size,
          radiusMajor: lastPointerData.radiusMajor,
          radiusMinor: lastPointerData.radiusMinor,
          radiusMin: lastPointerData.radiusMin,
          radiusMax: lastPointerData.radiusMax,
          orientation: lastPointerData.orientation,
          tilt: lastPointerData.tilt,
          platformData: lastPointerData.platformData,
          scrollDeltaX: lastPointerData.scrollDeltaX,
          scrollDeltaY: lastPointerData.scrollDeltaY,
        ),
      ],
    );
    window.onPointerDataPacket(pointerDataPacketUp);
    window.onPointerDataPacket(pointerDataPacketRemove);
    window.onPointerDataPacket(pointerDataPacketAdd);
    window.onPointerDataPacket(pointerDataPacketDown);
    window.onPointerDataPacket(pointerDataPacketMove);
  }

  @override
  void initState() {
    super.initState();

    lastActionTime = DateTime.now();

    primaryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 333),
      lowerBound: 0,
      upperBound: 1,
    )
      ..addListener(updateTrackerNotifiers)
      ..addStatusListener(primaryAnimationStatusListener);
    secondaryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 222),
      lowerBound: 0,
      upperBound: 1,
    )
      ..addListener(updateTrackerNotifiers)
      ..addStatusListener(secondaryAnimationStatusListener);
    secondaryAnimation = Tween(
      begin: 0.0,
      end: 1.0 - peekScale - peekCoefficient + 0.025,
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimationController,
        curve: Curves.decelerate,
      ),
    );
  }

  @override
  void dispose() {
    reset();

    primaryAnimationController.removeListener(updateTrackerNotifiers);
    primaryAnimationController.removeStatusListener(primaryAnimationStatusListener);
    primaryAnimationController.dispose();
    secondaryAnimation.removeListener(updateTrackerNotifiers);
    secondaryAnimationController.removeStatusListener(secondaryAnimationStatusListener);
    secondaryAnimationController.dispose();

    super.dispose();
  }

  Rect _getOverlapRect() {
    RenderBox renderBox = uiChildContainer.currentContext.findRenderObject();
    Offset position = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;
    return Rect.fromLTRB(
      position.dx,
      position.dy,
      width - (position.dx + size.width),
      height - (position.dy + size.height),
    );
  }

  Rect getOverlapRect() {
    RenderBox renderBox = uiChildContainer.currentContext.findRenderObject();
    Offset position = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;
    if (isDirect || !useOverlap) return Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    if (customOverlapRect != null) return customOverlapRect;
    return Rect.fromLTRB(
      position.dx,
      position.dy,
      width - (position.dx + size.width),
      height - (position.dy + size.height),
    );
  }

  Alignment getAlignment() {
    Alignment alignment = Alignment.center;
    if (useAlignment) {
      RenderBox renderBox = uiChildContainer.currentContext.findRenderObject();
      Offset position = renderBox.localToGlobal(Offset.zero);
      Size size = renderBox.size;
      alignment = Alignment(
        ((position.dx + size.width / 2.0) - width / 2.0) / (width / 2.0),
        ((position.dy + size.height / 2.0) - height / 2.0) / (height / 2.0),
      );
    }
    return alignment;
  }

  void peekAndPopComplete() {
    if (isDone || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (willPeekAndPopComplete != null && !willPeekAndPopComplete(this)) return;

    if (_debugLevel > 0) print("OnPeekAndPopComplete");

    stage = Stage.WillComplete;
    print(stage);

    primaryAnimationController.value = 1;
    secondaryAnimation = Tween(
      begin: 1.0 - peekScale - peekCoefficient,
      end: 1.0 - peekScale - peekCoefficient + 0.025,
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimationController,
        curve: Curves.decelerate,
      ),
    );
    secondaryAnimationController.value = 0;
    pressReroutedNotifier.value = 2;
    isDirect = true;
    ignoreAnimation = true;

    Navigator.of(context)
        .push(PeekAndPopRoute(this, (BuildContext context) => PeekAndPopChild(this, getOverlapRect(), getAlignment()), pageTransition))
        .whenComplete(() {
      HapticFeedback.mediumImpact();

      lastActionTime = DateTime.now();

      Future.delayed(const Duration(milliseconds: 666), reset);
    });
    pushTime = DateTime.now();

    stage = Stage.IsComplete;
    print(stage);

    if (onPeekAndPopComplete != null) onPeekAndPopComplete(this);
  }

  bool firstPressIsPeak(double pressure) {
    return pressure >= treshold * 0.75;
  }

  void pushPeekAndPop(dynamic pressDetails) {
    if (isDone || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (willPushPeekAndPop != null && !willPushPeekAndPop(this)) return;

    if (_debugLevel > 0) print("PushPeekAndPop");

    stage = Stage.WillPush;
    print(stage);

    if (quickActionsBuilder != null) quickActionsData = quickActionsBuilder(this);

    if (_debugLevel > 4) print("Pausing GestureBinding.");

    pointerDataPacketCallback = window.onPointerDataPacket;
    window.onPointerDataPacket = _pointerDataPacketCallback;

    if (_debugLevel > 4) print("Locking GestureBinding.");

    reroutePress();

    Navigator.of(context)
        .push(PeekAndPopRoute(this, (BuildContext context) => PeekAndPopChild(this, getOverlapRect(), getAlignment()), pageTransition))
        .whenComplete(() {
      HapticFeedback.mediumImpact();

      lastActionTime = DateTime.now();

      Future.delayed(const Duration(milliseconds: 666), reset);
    });
    pushTime = DateTime.now();

    if (firstPressIsPeak(pressDetails.pressure)) {
      jumpPeekAndPop(treshold);
      updatePeekAndPop(treshold);
    } else {
      if (useIndicator) {
        indicator = buildIndicator(context);
        Overlay.of(context).insert(indicator);
        Overlay.of(context).setState(() {});
      }

      jumpPeekAndPop(pressDetails.pressure);
      updatePeekAndPop(pressDetails.pressure);
    }

    if (onPushPeekAndPop != null) onPushPeekAndPop(this);
  }

  OverlayEntry buildIndicator(context) {
    Rect rect = _getOverlapRect();

    return OverlayEntry(
      builder: (BuildContext context) {
        return scaleUpWrapper(
          IgnorePointer(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Positioned(
                    left: rect.left,
                    top: rect.top,
                    right: rect.right,
                    bottom: rect.bottom,
                    child: uiChild,
                  ),
                ],
              ),
            ),
          ),
          indicatorScaleUpCoefficient,
        );
      },
    );
  }

  void updatePeekAndPop(dynamic pressDetails, {bool isFromOverlayEntry: false}) {
    if (hasQuickActions && peekAndPopChild != null && !peekAndPopChild.willUpdatePeekAndPop(this)) return;
    if (peekAndPopChild == null || !peekAndPopChild.isReady) return;
    if (isDone || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (secondaryAnimationController.isAnimating) return;
    if (willUpdatePeekAndPop != null && !willUpdatePeekAndPop(this)) return;

    double pressure = pressDetails is double ? pressDetails : pressDetails.pressure;

    if (_debugLevel > 2) {
      if (!isFromOverlayEntry)
        print("PeekAndPopController: UpdatePeekAndPop = " + pressure.toString());
      else
        print("PeekAndPopChild: UpdatePeekAndPop = " + pressure.toString());
    }

    if (peekAndPopChild != null && peekAndPopChild.canPeek && pressure >= treshold) {
      if (useIndicator && indicator != null) {
        indicator.remove();
        indicator = null;
        Overlay.of(context).setState(() {});
      }
      peekAndPopChild.peek();
      pushTime = DateTime.now();
    } else if (peekAndPopChild != null && !peekAndPopChild.willPeek) jumpPeekAndPop(pressure);

    if (onUpdatePeekAndPop != null) onUpdatePeekAndPop(this);
  }

  void cancelPeekAndPop(dynamic pressDetails, {bool isFromOverlayEntry: false}) {
    if (hasQuickActions && peekAndPopChild != null && !peekAndPopChild.willCancelPeekAndPop(this)) return;
    if (peekAndPopChild == null || !peekAndPopChild.isReady) return;
    if (isDone || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (secondaryAnimationController.isAnimating) return;
    if (willCancelPeekAndPop != null && !willCancelPeekAndPop(this)) return;

    stage = Stage.WillCancel;
    print(stage);

    if (_debugLevel > 0) {
      if (!isFromOverlayEntry)
        print("PeekAndPopController: CancelPeekAndPop");
      else
        print("PeekAndPopChild: CancelPeekAndPop");
    }

    if (useIndicator && indicator != null) {
      indicator.remove();
      indicator = null;
      Overlay.of(context).setState(() {});
    }

    drivePeekAndPop(false);
    if (peekAndPopChild != null) peekAndPopChild.animationController.reverse();

    if (onCancelPeekAndPop != null) onCancelPeekAndPop(this);
    if (hasQuickActions && peekAndPopChild != null) peekAndPopChild.onCancelPeekAndPop(this);
  }

  void finishPeekAndPop(dynamic pressDetails, {bool isFromOverlayEntry: false}) {
    if (hasQuickActions && peekAndPopChild != null && !peekAndPopChild.willFinishPeekAndPop(this)) return;
    if (peekAndPopChild == null || !peekAndPopChild.isReady) return;
    if (isDone || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (secondaryAnimationController.isAnimating) return;
    if (peekAndPopChild.animationController.status != AnimationStatus.completed) return;
    if (pushTime != null && DateTime.now().difference(pushTime).inSeconds < 1) return;
    if (willFinishPeekAndPop != null && !willFinishPeekAndPop(this)) return;

    if (_debugLevel > 0) print("finishPeekAndPop");

    stage = Stage.WillFinish;
    print(stage);

    pressReroutedNotifier.value = 2;

    drivePeekAndPop(true);

    if (onFinishPeekAndPop != null) onFinishPeekAndPop(this);
    if (hasQuickActions && peekAndPopChild != null) peekAndPopChild.onFinishPeekAndPop(this);
  }

  ///Use this function instead of using the Navigator.
  void closePeekAndPop() {
    if (peekAndPopChild == null || !peekAndPopChild.isReady) return;
    if (!isDone || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (secondaryAnimationController.isAnimating) return;
    if (willClosePeekAndPop != null && !willClosePeekAndPop(this)) return;

    if (_debugLevel > 0) print("ClosePeekAndPop");

    stage = Stage.WillClose;
    print(stage);

    ignoreAnimation = true;

    Navigator.of(context).pop();

    stage = Stage.IsClosed;
    print(stage);

    if (onClosePeekAndPop != null) onClosePeekAndPop(this);
  }

  void drivePeekAndPop(bool forward) {
    if (_debugLevel > 0) print("DrivePeekAndPop: $forward");

    if (forward) {
      primaryAnimationController.forward();
      secondaryAnimationController.forward();
    } else {
      primaryAnimationController.reverse();
      secondaryAnimationController.reverse();
    }
  }

  void jumpPeekAndPop(double value) {
    if (_debugLevel > 3) print("JumpPeekAndPop: $value");

    if (value == 1.0)
      finishPeekAndPop(null);
    else
      primaryAnimationController.value = value;
  }

  void beginDrag(dynamic pressDetails) {
    if (isDone || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (secondaryAnimationController.isAnimating) return;
    if (stage != Stage.IsPeeking) return;
    if (pushTime != null && DateTime.now().difference(pushTime).inSeconds < 1) return;

    if (_debugLevel > 2) print("BeginDrag");

    if (onPressStart != null) onPressStart(pressDetails);
    if (hasQuickActions && peekAndPopChild != null) peekAndPopChild.beginDrag(pressDetails);
  }

  void updateDrag(dynamic pressDetails) {
    if (isDone || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (secondaryAnimationController.isAnimating) return;
    if (stage != Stage.IsPeeking) return;
    if (pushTime != null && DateTime.now().difference(pushTime).inSeconds < 1) return;

    if (_debugLevel > 2) print("UpdateDrag");

    if (onPressUpdate != null) onPressUpdate(pressDetails);
    if (hasQuickActions && peekAndPopChild != null) peekAndPopChild.updateDrag(pressDetails);
  }

  void endDrag(dynamic pressDetails) {
    if (isDone || DateTime.now().difference(lastActionTime).inSeconds < 1) return;
    if (secondaryAnimationController.isAnimating) return;
    if (stage != Stage.IsPeeking) return;
    if (pushTime != null && DateTime.now().difference(pushTime).inSeconds < 1) return;

    if (_debugLevel > 2) print("EndDrag");

    if (onPressEnd != null) onPressEnd(pressDetails);
    if (hasQuickActions && peekAndPopChild != null) peekAndPopChild.endDrag(pressDetails);
  }

  void reset() {
    peekAndPopChild = null;
    primaryAnimationController.value = 0.0;
    secondaryAnimationController.value = 0.0;
    secondaryAnimation = Tween(
      begin: 0.0,
      end: 1.0 - peekScale - peekCoefficient + 0.025,
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimationController,
        curve: Curves.decelerate,
      ),
    );
    animationTrackerNotifier.value = 0;
    pressReroutedNotifier.value = 0;
    pushTime = null;
    isDirect = false;
    ignoreAnimation = false;

    if (useIndicator && indicator != null) {
      indicator.remove();
      indicator = null;
      Overlay.of(context).setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (width == -1 || height == -1) {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    }

    return PeekAndPopDetector(
      this,
      Container(
        key: uiChildContainer,
        child: uiChild,
      ),
    );
  }
}
