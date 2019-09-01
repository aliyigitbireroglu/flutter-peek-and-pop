//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// © Cosmos Software | Ali Yigit Bireroglu                                                                                                           /
// All material used in the making of this code, project, program, application, software et cetera (the "Intellectual Property")                     /
// belongs completely and solely to Ali Yigit Bireroglu. This includes but is not limited to the source code, the multimedia and                     /
// other asset files. If you were granted this Intellectual Property for personal use, you are obligated to include this copyright                   /
// text at all times.                                                                                                                                /
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//@formatter:off

import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:transparent_image/transparent_image.dart';

import 'package:snap/snap.dart';
import 'gesture_detector.dart' as MyGestureDetector;
import 'Export.dart';

///The widget that is responsible of detecting Peek & Pop related gestures after the gesture recognition is rerouted and of ALL Peek & Pop related UI.
///It is automatically created by the [PeekAndPopController]. It uses [MyGestureDetector.GestureDetector] for reasons
///explained at [PeekAndPopController.startPressure] and [PeekAndPopController.peakPressure]
class PeekAndPopChild extends StatefulWidget {
  final PeekAndPopControllerState _peekAndPopController;

  final Rect overlapRect;
  final Alignment alignment;

  const PeekAndPopChild(
    this._peekAndPopController,
    this.overlapRect,
    this.alignment,
  );

  @override
  PeekAndPopChildState createState() {
    return PeekAndPopChildState(
      _peekAndPopController,
      overlapRect,
      alignment,
    );
  }
}

class PeekAndPopChildState extends State<PeekAndPopChild> with SingleTickerProviderStateMixin {
  final PeekAndPopControllerState _peekAndPopController;

  final Rect overlapRect;
  final Alignment alignment;

  final GlobalKey<QuickActionsState> quickActions = GlobalKey<QuickActionsState>();
  final GlobalKey<SnapControllerState> snapController = GlobalKey<SnapControllerState>();
  final GlobalKey view = GlobalKey();
  final GlobalKey bound = GlobalKey();
  double quickActionsLowerLimit = -1.0;
  double quickActionsUpperLimit = -1.0;
  bool snapControllerIsReset = false;

  ///The [AnimationController] used to set the scale of the view when it is initially pushed to the Navigator.
  AnimationController animationController;
  Animation<double> animation;

  final ValueNotifier<int> animationTrackerNotifier = ValueNotifier<int>(0);

  ///I noticed that a fullscreen blur effect via the [BackdropFilter] widget is not good to use while running the animations required for the Peek &
  ///Pop process as it causes a noticeable drop in the framerate- especially for devices with high resolutions. During a mostly static view, the
  ///drop is acceptable. However, once the animations start running, this drop causes a visual disturbance. To prevent this, a new optimised blur
  ///effect algorithm is implemented. Now, the [BackdropFilter] widget is only used until the animations are about to start. At that moment, it is
  ///replaced by a static image. Therefore, to capture this image, your root CupertinoApp/MaterialApp MUST be wrapped in a [RepaintBoundary] widget
  ///which uses the [background] key. As a result, the Peek & Pop process is now up to 4x more fluent.
  Uint8List blurSnapshot = kTransparentImage;

  ///See [blurSnapshot].
  final ValueNotifier<int> blurTrackerNotifier = ValueNotifier<int>(0);

  bool isReady = false;
  bool get canPeek => isReady && animationController.value == 0 && !willPeek && !isPeeking;
  bool willPeek = false;
  bool isPeeking = false;

  int frameCount = 0;
  final int loopCount = 1;
  final int primaryDelay = 1;
  final int secondaryDelay = 2;
  final int toImageCount = 4;
  final double upscaleCoefficient = 1.01;

  double width = -1;
  double height = -1;

  PeekAndPopChildState(
    this._peekAndPopController,
    this.overlapRect,
    this.alignment,
  );

  void updateTrackerNotifiers() {
    animationTrackerNotifier.value += 1;
    blurTrackerNotifier.value += 1;
  }

  void animationStatusListener(AnimationStatus animationStatus) {
    switch (animationStatus) {
      case AnimationStatus.forward:
        HapticFeedback.mediumImpact();
        break;
      default:
        break;
    }
  }

  void increaseFramecount(Duration duration) async {
    isReady = true;
    frameCount++;
  }

  bool willUpdatePeekAndPop(PeekAndPopControllerState _peekAndPopController) {
    if (snapController.currentState == null) return true;

    if (quickActionsLowerLimit == -1) return true;

    return !snapController.currentState.isMoved(quickActionsLowerLimit);
  }

  bool willCancelPeekAndPop(PeekAndPopControllerState _peekAndPopController) {
    if (snapController.currentState == null) return true;

    if (quickActionsLowerLimit == -1) return true;

    if (snapController.currentState.isMoved(quickActionsLowerLimit)) return false;
    snapController.currentState.move(Offset.zero);
    return true;
  }

  bool willFinishPeekAndPop(PeekAndPopControllerState _peekAndPopController) {
    if (snapController.currentState == null) return true;

    if (quickActionsLowerLimit == -1) return true;

    if (snapController.currentState.isMoved(quickActionsLowerLimit)) return false;
    snapController.currentState.move(Offset.zero);
    return true;
  }

  void onFinishPeekAndPop(PeekAndPopControllerState _peekAndPopController) {
    snapControllerIsReset = false;
  }

  void onCancelPeekAndPop(PeekAndPopControllerState _peekAndPopController) {
    snapControllerIsReset = false;
  }

  void resetSnapController() {
    snapControllerIsReset = true;

    double height = MediaQuery.of(context).size.height;
    double quickActionsHeight = quickActions.currentState.getHeight() + 50;
    RenderBox viewRenderBox = view.currentContext.findRenderObject();
    double viewHeight = viewRenderBox.size.height;
    double limitBase = max(-0.1, (viewHeight + quickActionsHeight - height) / viewHeight);

    quickActionsUpperLimit = max(100, viewHeight * limitBase + 25);
    quickActionsLowerLimit = max(100, quickActionsUpperLimit / 2.0);

    snapController.currentState.snapTargets.add(SnapTarget(Offset(0.0, limitBase), Pivot.topLeft));
    snapController.currentState.snapTargets.add(SnapTarget(Offset(1.0, limitBase), Pivot.topRight));
    snapController.currentState.softReset(Offset(0.0, limitBase == -0.1 ? limitBase + 0.1 : limitBase * -1.0), Offset(1.0, 1.0));
  }

  void beginDrag(dynamic pressDetails) {
    if (animationController.status != AnimationStatus.completed) return;

    if (!snapControllerIsReset && snapController.currentState != null) resetSnapController();

    if (snapControllerIsReset && snapController.currentState != null) snapController.currentState.beginDrag(pressDetails);
  }

  void updateDrag(dynamic pressDetails) {
    if (animationController.status != AnimationStatus.completed) return;

    if (!snapControllerIsReset && snapController.currentState != null) resetSnapController();

    if (snapControllerIsReset && snapController.currentState != null) snapController.currentState.updateDrag(pressDetails);
  }

  void endDrag(dynamic pressDetails) {
    if (animationController.status != AnimationStatus.completed) return;

    if (!snapControllerIsReset && snapController.currentState != null) resetSnapController();

    if (snapControllerIsReset && snapController.currentState != null) snapController.currentState.endDrag(pressDetails);
  }

  void onMove(Offset offset) {
    if (quickActions.currentState == null) return;

    if (quickActionsUpperLimit == -1) return;

    if (offset.dy < quickActionsUpperLimit * -1.0 &&
        quickActions.currentState.animationController.status != AnimationStatus.forward &&
        quickActions.currentState.animationController.status != AnimationStatus.completed &&
        quickActions.currentState.animationController.value != 1) {
      quickActions.currentState.animationController.forward();
    } else if (offset.dy > quickActionsUpperLimit * -1.0 &&
        quickActions.currentState.animationController.status != AnimationStatus.reverse &&
        quickActions.currentState.animationController.status != AnimationStatus.dismissed &&
        quickActions.currentState.animationController.value != 0) {
      quickActions.currentState.animationController.reverse();
    }
  }

  void onSnap(Offset offset) {
    if (animationController.status != AnimationStatus.completed) return;

    if (quickActionsLowerLimit == -1) return;

    if (!snapController.currentState.isMoved(quickActionsLowerLimit)) {
      snapController.currentState.move(Offset.zero);
      _peekAndPopController.cancelPeekAndPop(null);
    }
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 111),
      lowerBound: 0,
      upperBound: 1,
    )
      ..addListener(updateTrackerNotifiers)
      ..addStatusListener(animationStatusListener);
    animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    if (_peekAndPopController.isDirect) animationController.value = 1;

    _peekAndPopController.pushComplete(this);
  }

  @override
  void dispose() {
    reset();

    animationController.removeListener(() {});
    animationController.removeStatusListener(animationStatusListener);
    animationController.dispose();

    super.dispose();
  }

  void reset() {
    snapControllerIsReset = false;
    quickActionsLowerLimit = -1.0;
    quickActionsUpperLimit = -1.0;
    animationController.value = 0;
    blurSnapshot = kTransparentImage;
    willPeek = false;
    isPeeking = false;
    frameCount = 0;
  }

  ///Tests conducted by Swiss scientists have shown that when an [AppBar] or a [CupertinoNavigationBar] is built with full transparency, their height
  ///is not included in the layout of a [Scaffold] or a [CupertinoPageScaffold]. Therefore, moving from a Peek stage with a transparent header to a
  ///Pop stage with a non-transparent header causes visual conflicts. Use this function with [getHeaderOffset] to prevent such problems. See the
  ///provided example for further clarification.
  ///IMPORTANT: It is essential that you use the provided [header] key for the header for this function to work.
  Size get headerSize {
    if (header.currentContext == null) return const Size(0, 0);

    RenderBox renderBox = header.currentContext.findRenderObject();
    return renderBox.size;
  }

  ///Tests conducted by Swiss scientists have shown that when an [AppBar] or a [CupertinoNavigationBar] is built with full transparency, their height
  ///is not included in the layout of a [Scaffold] or a [CupertinoPageScaffold]. Therefore, moving from a Peek stage with a transparent header to a
  ///Pop stage with a non-transparent header causes visual conflicts. Use this function with [headerSize] to prevent such problems. See the
  ///provided example for further clarification.
  ///IMPORTANT: It is essential that you use the provided [header] key for the header for this function to work.
  double getHeaderOffset(HeaderOffset headerOffset) {
    switch (headerOffset) {
      case HeaderOffset.NegativeHalf:
        return -headerSize.height / 2;
      case HeaderOffset.NegativeFull:
        return -headerSize.height;
      case HeaderOffset.PositiveHalf:
        return headerSize.height / 2;
      case HeaderOffset.PositiveFull:
        return headerSize.height;
      case HeaderOffset.Zero:
        return 0;
    }
    return 0;
  }

  //TODO: Improve.
  double get minimumLengthInBytes {
//    double width = MediaQuery.of(context).size.width;
//    double height = MediaQuery.of(context).size.height;
//    return width * height * 0.1 * 0.5;
    return _peekAndPopController.minimumLengthInBytes;
  }

  bool shouldContinueToImage(Map<ByteData, int> map) {
    if (map.length < toImageCount) return true;
    //print(minimumLengthInBytes);
    return map.values.toList().indexWhere((int lengthInBytes) {
          return lengthInBytes > minimumLengthInBytes;
        }) ==
        -1;
  }

  bool canBreakToImage(Map<ByteData, int> map, ByteData byteData) {
    return map.values.toList().indexWhere((int lengthInBytes) {
          return (byteData.lengthInBytes * 1.0) / (lengthInBytes * 1.0) > 10.0 || (lengthInBytes * 1.0) / byteData.lengthInBytes * 1.0 > 10.0;
        }) >
        -1;
  }

  void peek() async {
    if (canPeek) {
      isPeeking = false;
      willPeek = true;
      _peekAndPopController.stage = Stage.WillPeek;
      //print(_peekAndPopController.stage);
      transformBloc.dispatch(1.0);

      int currentFramecount = 0;

      for (int i = 0; i < loopCount; i++) {
        currentFramecount = frameCount;
        blurTrackerNotifier.value++;
        while (currentFramecount == frameCount) await Future.delayed(Duration(milliseconds: primaryDelay));
      }

      ///A workaround to avoid a Flutter Engine bug that was causing trouble with the optimised blur effect algorithm.
      RenderRepaintBoundary renderBackground = background.currentContext.findRenderObject();
      List<ui.Image> images = [];
      Map<ByteData, int> map = Map<ByteData, int>();
      while (shouldContinueToImage(map)) {
        images.add(await renderBackground.toImage(
          pixelRatio: WidgetsBinding.instance.window.devicePixelRatio * 0.1,
        ));
        ByteData byteData = await images.last.toByteData(format: ImageByteFormat.png);
        map[byteData] = byteData.lengthInBytes;
        //print(byteData.lengthInBytes);
        if (canBreakToImage(map, byteData)) {
          //print("Breaking because a significantly larger file is found.");
          break;
        }
      }
      ByteData byteData = map.keys.firstWhere((ByteData byteData) {
        return map[byteData] == map.values.reduce(max);
      });
      blurSnapshot = byteData.buffer.asUint8List();
      _peekAndPopController.minimumLengthInBytes = byteData.lengthInBytes * 0.5;

      for (int i = 0; i < loopCount; i++) {
        currentFramecount = frameCount;
        blurTrackerNotifier.value++;
        while (currentFramecount == frameCount) await Future.delayed(Duration(milliseconds: primaryDelay));
      }

      isPeeking = true;
      willPeek = false;
      _peekAndPopController.stage = Stage.IsPeeking;
      //print(_peekAndPopController.stage);

      currentFramecount = frameCount;
      blurTrackerNotifier.value++;

      for (int i = 0; i < 2; i++) {
        currentFramecount = frameCount;
        blurTrackerNotifier.value++;
        while (currentFramecount == frameCount) await Future.delayed(Duration(milliseconds: secondaryDelay));
      }

      animationController.forward();
    }
  }

  Widget wrapper() {
    if (_peekAndPopController.hasQuickActions && !(_peekAndPopController.willBeDone || _peekAndPopController.isDone))
      return Container(
        key: bound,
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SnapController(
              Container(
                key: view,
                child: Center(
                  child: _peekAndPopController.peekAndPopBuilder(
                    context,
                    _peekAndPopController,
                  ),
                ),
              ),
              _peekAndPopController.peekAndPopBuilderUseCache,
              view,
              bound,
              const Offset(0.0, 0.0),
              const Offset(1.0, 1.0),
              const Offset(0.0, 0.75),
              const Offset(0.0, 0.75),
              snapTargets: [
                const SnapTarget(Pivot.center, Pivot.center),
              ],
              useFlick: false,
              onMove: onMove,
              onSnap: onSnap,
              key: snapController,
            ),
          ],
        ),
      );
    return Center(
      child: _peekAndPopController.peekAndPopBuilder(
        context,
        _peekAndPopController,
      ),
    );
  }

  ///The build function returns a [Stack] with three (or optionally four to five) widgets:
  ///I) The new optimised blur effect algorithm (see [blurSnapshot]), for obvious reasons. The sigma values are controlled by the
  ///[PeekAndPopControllerState.primaryAnimationController].
  ///II) The view provided by your [PeekAndPopController.peekAndPopBuilder]. This entire widget is continuously rescaled by three different values:
  ///   a) [animation] controls the scaling of the widget when it is initially pushed to the Navigator.
  ///   b) [PeekAndPopControllerState.primaryAnimationController] controls the scaling of the widget during the Peek stage.
  ///   c) [PeekAndPopControllerState.secondaryAnimationController] controls the scaling of the widget during the Pop stage.
  ///   ([PeekAndPopControllerState.tertiaryAnimationController]) controls the position of the widget during the Peek stage
  ///   if [PeekAndPopController.moveControler] is set.)
  ///III) A [MyGestureDetector.GestureDetector] widget, again, for obvious reasons.
  ///IV) An optional [QuickActions] widget.
  ///V)  An optional second view provided by your [PeekAndPopController.overlayBuiler]. This entire widget is built after everything else so it avoids
  ///the [Blur] and the [MyGestureDetector.GestureDetector] widgets.
  @override
  Widget build(BuildContext context) {
    if (width == -1 || height == -1) {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    }

    return Stack(
      children: [
        ValueListenableBuilder(
          builder: (BuildContext context, int blurTracker, Widget cachedChild) {
            SchedulerBinding.instance.addPostFrameCallback(increaseFramecount);
            return Stack(
              children: [
                Visibility(
                  visible: !isPeeking,
                  child: AnimatedBuilder(
                    animation: _peekAndPopController.primaryAnimationController,
                    builder: (BuildContext context, Widget cachedChild) {
                      double sigma = _peekAndPopController.stage == Stage.None ||
                              _peekAndPopController.stage == Stage.WillClose ||
                              _peekAndPopController.stage == Stage.IsClosed ||
                              _peekAndPopController.isDone
                          ? 0
                          : willPeek || isPeeking || animationController.value == 1.0
                              ? _peekAndPopController.sigma
                              : min(
                                  _peekAndPopController.primaryAnimationController.value /
                                      _peekAndPopController.treshold *
                                      _peekAndPopController.sigma,
                                  _peekAndPopController.sigma,
                                );
                      double alpha = sigma / _peekAndPopController.sigma;
                      if (sigma != 0.0) transformBloc.dispatch(alpha);

                      return BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: sigma,
                          sigmaY: sigma,
                        ),
                        child: Container(
                          constraints: const BoxConstraints.expand(),
                          color: _peekAndPopController.backdropColor.withAlpha((alpha * _peekAndPopController.alpha).ceil()),
                        ),
                      );
                    },
                  ),
                ),
                Visibility(
                    visible: !(_peekAndPopController.stage == Stage.None ||
                        _peekAndPopController.stage == Stage.WillClose ||
                        _peekAndPopController.stage == Stage.IsClosed ||
                        _peekAndPopController.isDone),
                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (BuildContext context, Widget cachedChild) {
//                        double width = MediaQuery.of(context).size.width;
//                        double height = MediaQuery.of(context).size.height;
                        double opacity = _peekAndPopController.stage == Stage.WillCancel || _peekAndPopController.stage == Stage.IsCancelled
                            ? animationController.value
                            : 1.0;
                        if (opacity != 1.0) transformBloc.dispatch(opacity);

                        return Opacity(
                          opacity: opacity,
                          child: height > width
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: width * upscaleCoefficient,
                                      height: height,
                                      child: Image.memory(
                                        blurSnapshot,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    SizedBox(
                                      width: width,
                                      height: height * upscaleCoefficient,
                                      child: Image.memory(
                                        blurSnapshot,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                    )),
              ],
            );
          },
          valueListenable: blurTrackerNotifier,
        ),
        ValueListenableBuilder(
          child: _peekAndPopController.peekAndPopBuilderUseCache ? wrapper() : null,
          builder: (BuildContext context, int animationTracker, Widget cachedChild) {
            double scale = _peekAndPopController.peekScale +
                _peekAndPopController.peekCoefficient * _peekAndPopController.primaryAnimationController.value +
                _peekAndPopController.secondaryAnimation.value;
            scale = Tween<double>(
              begin: _peekAndPopController.useOverlap ? 1.0 : 0.0,
              end: scale,
            ).lerp(animationController.value);
            Rect _overlapRect = RectTween(
              begin: overlapRect,
              end: Rect.fromLTRB(0.0, 0.0, 0.0, 0.0),
            ).lerp(animationController.value);
            Alignment _alignment = Tween<Alignment>(
              begin: alignment,
              end: Alignment.center,
            ).lerp(animationController.value);
            double opacity = min(pow(animationController.value, 0.25), 1.0);

            return Transform.scale(
              scale: scale,
              alignment: _alignment,
              child: Stack(
                children: [
                  Positioned(
                    left: _overlapRect.left,
                    top: _overlapRect.top,
                    right: _overlapRect.right,
                    bottom: _overlapRect.bottom,
                    child: Opacity(
                      opacity: opacity,
                      child: _peekAndPopController.peekAndPopBuilderUseCache ? cachedChild : wrapper(),
                    ),
                  ),
                ],
              ),
            );
          },
          valueListenable: animationTrackerNotifier,
        ),
        ValueListenableBuilder(
          builder: (BuildContext context, int pressRerouted, Widget cachedChild) {
            if (pressRerouted == 1) _peekAndPopController.unlockPress();

            return IgnorePointer(
              ignoring: pressRerouted != 1,
              child: MyGestureDetector.GestureDetector(
                behavior: HitTestBehavior.opaque,
                startPressure: 0,
                peakPressure: _peekAndPopController.peakPressure,
                onForcePressStart: (ForcePressDetails forcePressDetails) {
                  _peekAndPopController.updatePeekAndPop(forcePressDetails, isFromOverlayEntry: true);
                  _peekAndPopController.beginDrag(forcePressDetails);
                },
                onForcePressUpdate: (ForcePressDetails forcePressDetails) {
                  _peekAndPopController.updatePeekAndPop(forcePressDetails, isFromOverlayEntry: true);
                  _peekAndPopController.updateDrag(forcePressDetails);
                },
                onForcePressEnd: (ForcePressDetails forcePressDetails) {
                  _peekAndPopController.cancelPeekAndPop(forcePressDetails, isFromOverlayEntry: true);
                  _peekAndPopController.endDrag(forcePressDetails);
                },
                onForcePressPeak: (ForcePressDetails forcePressDetails) {
                  _peekAndPopController.finishPeekAndPop(forcePressDetails, isFromOverlayEntry: true);
                },
                onVerticalDragStart: (DragStartDetails dragStartDetails) {
                  _peekAndPopController.beginDrag(dragStartDetails);
                },
                onVerticalDragUpdate: (DragUpdateDetails dragUpdateDetails) {
                  _peekAndPopController.updateDrag(dragUpdateDetails);
                },
                onVerticalDragEnd: (DragEndDetails dragEndDetails) {
                  _peekAndPopController.endDrag(dragEndDetails);
                },
                onHorizontalDragStart: (DragStartDetails dragStartDetails) {
                  _peekAndPopController.beginDrag(dragStartDetails);
                },
                onHorizontalDragUpdate: (DragUpdateDetails dragUpdateDetails) {
                  _peekAndPopController.updateDrag(dragUpdateDetails);
                },
                onHorizontalDragEnd: (DragEndDetails dragEndDetails) {
                  _peekAndPopController.endDrag(dragEndDetails);
                },
              ),
            );
          },
          valueListenable: _peekAndPopController.pressReroutedNotifier,
        ),
        if (_peekAndPopController.hasQuickActions)
          QuickActions(
            quickActions,
            _peekAndPopController.quickActionsData,
          ),
        if (_peekAndPopController.overlayBuilder != null) _peekAndPopController.overlayBuilder,
      ],
    );
  }
}

class QuickActions extends StatefulWidget {
  final QuickActionsData quickActionsData;

  const QuickActions(
    Key key,
    this.quickActionsData,
  ) : super(key: key);

  @override
  QuickActionsState createState() {
    return QuickActionsState(
      quickActionsData,
    );
  }
}

class QuickActionsState extends State<QuickActions> with SingleTickerProviderStateMixin {
  final QuickActionsData quickActionsData;

  ///The [AnimationController] used to position the Quick Actions.
  AnimationController animationController;
  Animation<double> animation;

  QuickActionsState(
    this.quickActionsData,
  );

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 333),
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  double getHeight() {
    double height = 0;
    quickActionsData.quickActions.forEach((QuickAction quickAction) => height += quickAction.height);
    return height;
  }

  Widget wrapper(QuickAction quickAction) {
    return Expanded(
      child: GestureDetector(
        onTap: quickAction.onTap,
        child: Container(
          constraints: BoxConstraints.expand(height: quickAction.height),
          decoration: quickAction.boxDecoration,
          child: quickAction.child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (animation == null) {
      double height = MediaQuery.of(context).size.height;
      animation = Tween(
        begin: height,
        end: height - getHeight() - 50,
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.decelerate,
        ),
      );
    }
    return AnimatedBuilder(
      animation: animation,
      child: Padding(
        padding: EdgeInsets.only(left: 12.5, top: 25, right: 12.5, bottom: 25),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ClipRRect(
            borderRadius: quickActionsData.borderRadius,
            child: Container(
              constraints: BoxConstraints.expand(height: getHeight()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: quickActionsData.quickActions.map((QuickAction quickAction) => wrapper(quickAction)).toList(),
              ),
            ),
          ),
        ),
      ),
      builder: (BuildContext context, Widget cachedChild) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: cachedChild,
        );
      },
    );
  }
}
