// © Cosmos Software | Ali Yigit Bireroglu All material used in the making of this code, project, program, application,
// software et cetera (the "Intellectual Property") belongs completely and solely to Ali Yigit Bireroglu. This includes but
// is not limited to the source code, the multimedia and other asset files. If you were granted this Intellectual Property
// for personal use, you are obligated to include this copyright text at all times.
// Copyright © 2019 Ali Yigit Bireroglu (https://www.cosmossoftare.coffee) All rights reserved.

//@formatter:off
import 'dart:ui';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'gesture_detector.dart' as MyGestureDetector;
import 'Export.dart';

///The widget that is responsible of detecting Peek & Pop related gestures after the gesture recognition is rerouted and of ALL Peek & Pop related UI.
///It is automatically created by the [PeekAndPopControllerState]. It uses [MyGestureDetector.GestureDetector] for reasons
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
	///The [Animation] controlled by the [animationController].
	Animation<double> animation;

	PeekAndPopChildState(this._peekAndPopController);

	void animationStatusListener(AnimationStatus animationStatus) {
		switch (animationStatus) {
			case AnimationStatus.forward:
				HapticFeedback.heavyImpact();
				break;
			default:
				break;
		}
	}

	void buildComplete(Duration duration) {}

	@override
	void initState() {
		super.initState();
		
		animationController = 
			AnimationController(
				vsync: this, 
				duration: const Duration(milliseconds: 333), 
				lowerBound: 0, upperBound: 1)
			..addListener(() {})
			..addStatusListener(animationStatusListener);
		animation = 
			Tween(
				begin: 0.0, 
				end: 1.0)
			.animate(CurvedAnimation(
								parent: animationController, 
								curve: _peekAndPopController.supportsForcePress ? Curves.fastOutSlowIn : Curves.decelerate));
		
		SchedulerBinding.instance.addPostFrameCallback(buildComplete);
		
		if (_peekAndPopController.isHero || _peekAndPopController.isDirect) animationController.value = 1;
		else if (!_peekAndPopController.supportsForcePress) animationController.forward(from: 0.5);
		
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
	
	void reset(){
		animationController.value = 0;
	}
	
	///Test conducted by Swiss scientists have shown that when an [AppBar] or a [CupertinoNavigationBar] is built with full transparency, their height
	///is not included in the layout of a [Scaffold] or a [CupertinoPageScaffold]. Therefore, moving from a Peek stage with a transparent header to a
	///Pop stage with a non-transparent header causes visual conflicts. Use this function with [getHeaderOffset] to prevent such problems. See the 
	///provided example for further clarification.
	///IMPORTANT: It is essential that you use the provided [header] key for the header for this function to work.
	Size get headerSize {
		if (header.currentContext == null) return Size(0, 0);
		
		RenderBox renderBox = header.currentContext.findRenderObject();
		return renderBox.size;
	}

	///Test conducted by Swiss scientists have shown that when an [AppBar] or a [CupertinoNavigationBar] is built with full transparency, their height
	///is not included in the layout of a [Scaffold] or a [CupertinoPageScaffold]. Therefore, moving from a Peek stage with a transparent header to a
	///Pop stage with a non-transparent header causes visual conflicts. Use this function with [headerSize] to prevent such problems. See the 
	///provided example for further clarification.
	///IMPORTANT: It is essential that you use the provided [header] key for the header for this function to work.
	double getHeaderOffset(HeaderOffset headerOffset){
		switch (headerOffset){
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
	
	///A simple widget for positioning the view properly. At the moment it only uses [Center] but further developments might be added.
	Widget wrapper() {
		return Center(child: _peekAndPopController.peekAndPopBuilder(context, _peekAndPopController));
	}

	///The build function for a [PeekAndPopChildState] returns a [Stack] with three or optionally four sub widgets:
	///I) A [Backdrop] widget for obvious reasons. The blurriness is controlled by the [PeekAndPopControllerState.animationController].
	///II) The view provided by your [PeekAndPopController.peekAndPopBuilder]. This entire widget is continuously rescaled by three different values: 
	///   a) [animation] controls the scaling of the widget when it is initially pushed to the Navigator.
	///   b) [PeekAndPopControllerState.animationController] controls the scaling of the widget during the Peek stage.
	///   c) [PeekAndPopControllerState.secondaryAnimationController] controls the scaling of the widget during the Pop stage.
	///III) An optional second view provided by your [PeekAndPopController.overlayBuiler] that is not blurred by the [Backdrop] widget.   
	///IV) A [MyGestureDetector.GestureDetector] widget, again, for obvious reasons. 
	@override
	Widget build(BuildContext context) {
		return Stack(children: [
						AnimatedBuilder(
							animation: _peekAndPopController.animationController, 
							builder: 
							(BuildContext context, Widget cachedChild) {
								double sigma = _peekAndPopController.isComplete 
								               ? 0 
								               : animation.value == 1.0 
								                 ? 10 
								                 : min(_peekAndPopController.animationController.value / _peekAndPopController.treshold * 10, 10);
								return Backdrop(
												sigma, 
												sigma, 
												_peekAndPopController.backdropColor.withAlpha((_peekAndPopController.animationController.value * 126).ceil()));
							}
						),
						AnimatedBuilder(
			        animation: animation,
			        child: ValueListenableBuilder(
		                  child: _peekAndPopController.useCache 
		                         ? wrapper() 
		                         : null,
		                  builder: 
			                (BuildContext context, double animationTracker, Widget cachedChild) {
		                    double secondaryScale = 
			                    _peekAndPopController.peekScale + 
			                    _peekAndPopController.peekCoefficient * 
			                    _peekAndPopController.animationController.value + 
			                    _peekAndPopController.secondaryAnimation.value;
		                    return Transform.scale(
			                          scale: secondaryScale,
			                          child: Transform.translate(
							                          offset: _peekAndPopController.moveController != null && !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete ? _peekAndPopController.moveController.delta : Offset.zero,
							                          child:_peekAndPopController.useCache 
							                                ? cachedChild 
							                                : wrapper()));
		                  },
		                  valueListenable: _peekAndPopController.animationTrackerNotifier),
			        builder: 
				      (BuildContext context, Widget cachedChild) {
			          double primaryScale = animation.value;
			          return Transform.scale(
						            scale: primaryScale,
					              child: cachedChild);
			        }
			      ),
						ValueListenableBuilder(
							builder: 
							(BuildContext context, bool pressRerouted, Widget cachedChild) {
								return IgnorePointer(
												ignoring: !pressRerouted,
												child: MyGestureDetector.GestureDetector(
																behavior: HitTestBehavior.opaque,
						                    startPressure: _peekAndPopController.startPressure,
						                    peakPressure: _peekAndPopController.peakPressure,
						                    onForcePressStart: _peekAndPopController.supportsForcePress
						                                       ? (ForcePressDetails forcePressDetails) {_peekAndPopController.updatePeekAndPop(forcePressDetails, isFromOverlayEntry: true);}
						                                       : null,
						                    onForcePressUpdate: _peekAndPopController.supportsForcePress
						                                        ? (ForcePressDetails forcePressDetails) {_peekAndPopController.updatePeekAndPop(forcePressDetails, isFromOverlayEntry: true);}
						                                        : null,
						                    onForcePressEnd: _peekAndPopController.supportsForcePress
						                                     ? (ForcePressDetails forcePressDetails) {_peekAndPopController.cancelPeekAndPop(forcePressDetails, isFromOverlayEntry: true);}
						                                     : null,
						                    onForcePressPeak: _peekAndPopController.supportsForcePress
						                                      ? (ForcePressDetails forcePressDetails) {_peekAndPopController.finishPeekAndPop(forcePressDetails, isFromOverlayEntry: true);}
						                                      : null,
						                    onLongPressStart: (LongPressStartDetails longPressStartDetails) {},
						                    onLongPressEnd: _peekAndPopController.supportsForcePress
						                                    ? null
						                                    : (LongPressEndDetails longPressEndDetails) {_peekAndPopController.cancelPeekAndPop(longPressEndDetails, isFromOverlayEntry: true);},
																onVerticalDragStart: (DragStartDetails dragStartDetails) {_peekAndPopController.beginDrag(dragStartDetails);},
																onVerticalDragUpdate: (DragUpdateDetails dragUpdateDetails) {_peekAndPopController.updateDrag(dragUpdateDetails);},
																onVerticalDragEnd: (DragEndDetails dragEndDetails) {_peekAndPopController.endDrag(dragEndDetails);},
																onHorizontalDragStart: (DragStartDetails dragStartDetails) {_peekAndPopController.beginDrag(dragStartDetails);},
																onHorizontalDragUpdate: (DragUpdateDetails dragUpdateDetails) {_peekAndPopController.updateDrag(dragUpdateDetails);},
																onHorizontalDragEnd: (DragEndDetails dragEndDetails) {_peekAndPopController.endDrag(dragEndDetails);}));
							}, 
							valueListenable: _peekAndPopController.pressReroutedNotifier),
						_peekAndPopController.overlayBuilder != null 
						? _peekAndPopController.overlayBuilder 
						: Container(),
					]);
	}
}

///A simple widget for applying blur during the Peek stage. It is basically a BackdropFilter wrapped in a cooler way.
class Backdrop extends StatelessWidget {
	final double sigmaX;
	final double sigmaY;
	final Color color;

	const Backdrop(this.sigmaX, this.sigmaY, this.color);

	@override
	Widget build(BuildContext context) {
		return Container(
						constraints: const BoxConstraints.expand(),
						child: BackdropFilter(
										filter: ImageFilter.blur(
															sigmaX: sigmaX, 
															sigmaY: sigmaY),
										child: Container(
												constraints: const BoxConstraints.expand(),
												color: color)));
	}
}