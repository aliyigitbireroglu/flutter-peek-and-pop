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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:transparent_image/transparent_image.dart';

import 'gesture_detector.dart' as MyGestureDetector;
import 'Export.dart';

///The widget that is responsible of detecting Peek & Pop related gestures after the gesture recognition is rerouted and of ALL Peek & Pop related UI.
///It is automatically created by the [PeekAndPopController]. It uses [MyGestureDetector.GestureDetector] for reasons
///explained at [PeekAndPopController.startPressure] and [PeekAndPopController.peakPressure]
class PeekAndPopChild extends StatefulWidget {
  final PeekAndPopControllerState _peekAndPopController;

  const PeekAndPopChild(this._peekAndPopController);

  @override
  PeekAndPopChildState createState() {
    return PeekAndPopChildState(_peekAndPopController);
  }
}

class PeekAndPopChildState extends State<PeekAndPopChild> with SingleTickerProviderStateMixin {
  final PeekAndPopControllerState _peekAndPopController;

  ///The [AnimationController] used to set the scale of the view when it is initially pushed to the Navigator.
  AnimationController animationController;
  Animation<double> animation;

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

  final int optimisationVersion = 1;
  int frameCount = 0;
  final int loopCount = 1;
  final int primaryDelay = 1;
  final int secondaryDelay = 2;

  final double upscaleCoefficient = 1.01;
  double width = -1;
  double height = -1;

  PeekAndPopChildState(this._peekAndPopController);

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

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 333), lowerBound: 0, upperBound: 1)
      ..addListener(() {})
      ..addStatusListener(animationStatusListener);
    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn));

    if (_peekAndPopController.isHero || _peekAndPopController.isDirect) animationController.value = 1;
    //else if (!_peekAndPopController.supportsForcePress) animationController.forward(from: 0.5);

    _peekAndPopController.pushComplete(this);
  }

  @override
  void dispose() {
    animationController.removeListener(() {});
    animationController.removeStatusListener(animationStatusListener);
    animationController.dispose();

    _peekAndPopController.peekAndPopChild = null;

    super.dispose();
  }

  void reset() {
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
        break;
      case HeaderOffset.PositiveHalf:
        return headerSize.height / 2;
        break;
      case HeaderOffset.Zero:
        return 0;
        break;
    }
    return 0;
  }

  void peek() async {
    if (canPeek) {
      isPeeking = false;
      willPeek = true;

      int currentFramecount = 0;

      for (int i = 0; i < loopCount; i++) {
        currentFramecount = frameCount;
        blurTrackerNotifier.value++;
        while (currentFramecount == frameCount) await Future.delayed(Duration(milliseconds: primaryDelay));
      }

      RenderRepaintBoundary renderBackground = background.currentContext.findRenderObject();
      ui.Image image = await renderBackground.toImage(
        pixelRatio:
            optimisationVersion == 0 ? WidgetsBinding.instance.window.devicePixelRatio : WidgetsBinding.instance.window.devicePixelRatio * 0.1,
      );
      ByteData imageByteData = await image.toByteData(format: ImageByteFormat.png);
      blurSnapshot = imageByteData.buffer.asUint8List();

      for (int i = 0; i < loopCount; i++) {
        currentFramecount = frameCount;
        blurTrackerNotifier.value++;
        while (currentFramecount == frameCount) await Future.delayed(Duration(milliseconds: primaryDelay));
      }

      isPeeking = true;
      willPeek = false;

      currentFramecount = frameCount;
      blurTrackerNotifier.value++;

      for (int i = 0; i < 2; i++) {
        currentFramecount = frameCount;
        blurTrackerNotifier.value++;
        while (currentFramecount == frameCount) await Future.delayed(Duration(milliseconds: secondaryDelay));
      }

      animationController.forward(from: 0.5);

      if (!_peekAndPopController.supportsForcePress) _peekAndPopController.finishPeekAndPop(null);
    }
  }

  ///A simple widget for positioning the view properly. At the moment, it only uses [Center] but further developments might be added.
  Widget wrapper() {
    return Center(child: _peekAndPopController.peekAndPopBuilder(context, _peekAndPopController));
  }

  ///The build function returns a [Stack] with three (or optionally four) widgets:
  ///I) The new optimised blur effect algorithm (see [blurSnapshot]), for obvious reasons. The sigma values are controlled by the
  ///[PeekAndPopControllerState.animationController].
  ///II) The view provided by your [PeekAndPopController.peekAndPopBuilder]. This entire widget is continuously rescaled by three different values:
  ///   a) [animation] controls the scaling of the widget when it is initially pushed to the Navigator.
  ///   b) [PeekAndPopControllerState.animationController] controls the scaling of the widget during the Peek stage.
  ///   c) [PeekAndPopControllerState.secondaryAnimationController] controls the scaling of the widget during the Pop stage.
  ///   ([PeekAndPopControllerState.tertiaryAnimationController]) controls the position of the widget during the Peek stage
  ///   if [PeekAndPopController.moveControler] is set.)
  ///III) A [MyGestureDetector.GestureDetector] widget, again, for obvious reasons.
  ///IV)  An optional second view provided by your [PeekAndPopController.overlayBuiler]. This entire widget is built after everything else so it avoids
  ///the [Blur] and the [MyGestureDetector.GestureDetector] widgets.
  @override
  Widget build(BuildContext context) {
    if (width == -1) width = MediaQuery.of(context).size.width;
    if (height == -1) height = MediaQuery.of(context).size.height;

    return Stack(children: [
      ValueListenableBuilder(
        builder: (BuildContext context, int blurTracker, Widget cachedChild) {
          SchedulerBinding.instance.addPostFrameCallback(increaseFramecount);
          return Stack(children: [
            Visibility(
                visible: !isPeeking,
                child: AnimatedBuilder(
                    animation: _peekAndPopController.animationController,
                    builder: (BuildContext context, Widget cachedChild) {
                      double sigma = _peekAndPopController.isComplete
                          ? 0
                          : willPeek || isPeeking || animation.value == 1.0
                              ? _peekAndPopController.sigma
                              : min(_peekAndPopController.animationController.value / _peekAndPopController.treshold * _peekAndPopController.sigma,
                                  _peekAndPopController.sigma);
                      double alpha = sigma / _peekAndPopController.sigma;
                      return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                          child: Container(
                              constraints: const BoxConstraints.expand(),
                              color: _peekAndPopController.backdropColor.withAlpha((alpha * _peekAndPopController.alpha).ceil())));
                    })),
            optimisationVersion == 0
                ? Image.memory(blurSnapshot, gaplessPlayback: true)
                : height > width
                    ? Row(
                        children: [SizedBox(width: width * upscaleCoefficient, height: height, child: Image.memory(blurSnapshot, fit: BoxFit.fill))],
                      )
                    : Column(
                        children: [SizedBox(width: width, height: height * upscaleCoefficient, child: Image.memory(blurSnapshot, fit: BoxFit.fill))],
                      )
          ]);
        },
        valueListenable: blurTrackerNotifier,
      ),
      AnimatedBuilder(
          animation: animation,
          child: ValueListenableBuilder(
              child: _peekAndPopController.useCache ? wrapper() : null,
              builder: (BuildContext context, int animationTracker, Widget cachedChild) {
                double secondaryScale = _peekAndPopController.peekScale +
                    _peekAndPopController.peekCoefficient * _peekAndPopController.animationController.value +
                    _peekAndPopController.secondaryAnimation.value;
                return Transform.scale(scale: secondaryScale, child: _peekAndPopController.useCache ? cachedChild : wrapper());
              },
              valueListenable: _peekAndPopController.animationTrackerNotifier),
          builder: (BuildContext context, Widget cachedChild) {
            double primaryScale = animation.value;
            return Transform.scale(scale: primaryScale, child: cachedChild);
          }),
      ValueListenableBuilder(
          builder: (BuildContext context, bool pressRerouted, Widget cachedChild) {
            return IgnorePointer(
                ignoring: !pressRerouted,
                child: MyGestureDetector.GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    startPressure: 0,
                    peakPressure: _peekAndPopController.peakPressure,
                    onForcePressStart: _peekAndPopController.supportsForcePress
                        ? (ForcePressDetails forcePressDetails) {
                            _peekAndPopController.updatePeekAndPop(forcePressDetails, isFromOverlayEntry: true);
                            _peekAndPopController.beginDrag(forcePressDetails);
                          }
                        : null,
                    onForcePressUpdate: _peekAndPopController.supportsForcePress
                        ? (ForcePressDetails forcePressDetails) {
                            _peekAndPopController.updatePeekAndPop(forcePressDetails, isFromOverlayEntry: true);
                            _peekAndPopController.updateDrag(forcePressDetails);
                          }
                        : null,
                    onForcePressEnd: _peekAndPopController.supportsForcePress
                        ? (ForcePressDetails forcePressDetails) {
                            _peekAndPopController.cancelPeekAndPop(forcePressDetails, isFromOverlayEntry: true);
                            _peekAndPopController.endDrag(forcePressDetails);
                          }
                        : null,
                    onForcePressPeak: _peekAndPopController.supportsForcePress
                        ? (ForcePressDetails forcePressDetails) {
                            _peekAndPopController.finishPeekAndPop(forcePressDetails, isFromOverlayEntry: true);
                          }
                        : null,
                    onLongPressStart: _peekAndPopController.supportsForcePress
                        ? null
                        : (LongPressStartDetails longPressStartDetails) {
                            //_peekAndPopController.beginDrag(longPressStartDetails);
                          },
                    onLongPressMoveUpdate: _peekAndPopController.supportsForcePress
                        ? null
                        : (LongPressMoveUpdateDetails longPressMoveUpdateDetails) {
                            //_peekAndPopController.updateDrag(longPressMoveUpdateDetails);
                          },
                    onLongPressEnd: _peekAndPopController.supportsForcePress
                        ? null
                        : (LongPressEndDetails longPressEndDetails) {
                            _peekAndPopController.cancelPeekAndPop(longPressEndDetails, isFromOverlayEntry: true);
                            //_peekAndPopController.endDrag(longPressEndDetails);
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
                    }));
          },
          valueListenable: _peekAndPopController.pressReroutedNotifier),
      if (_peekAndPopController.overlayBuilder != null) _peekAndPopController.overlayBuilder
    ]);
  }
}
