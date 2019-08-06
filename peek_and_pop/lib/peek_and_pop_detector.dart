// © Cosmos Software | Ali Yigit Bireroglu All material used in the making of this code, project, program, application,
// software et cetera (the "Intellectual Property") belongs completely and solely to Ali Yigit Bireroglu. This includes but
// is not limited to the source code, the multimedia and other asset files. If you were granted this Intellectual Property
// for personal use, you are obligated to include this copyright text at all times.
// Copyright © 2019 Ali Yigit Bireroglu (https://www.cosmossoftare.coffee) All rights reserved.

//@formatter:off
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'gesture_detector.dart' as MyGestureDetector;
import 'Export.dart';

///The widget that is responsible of detecting Peek & Pop related gestures until the gesture recognition is rerouted to the instantiated 
///[PeekAndPopChildState]. It is automatically created by the [PeekAndPopControllerState]. It uses [MyGestureDetector.GestureDetector] for reasons
///explained at [PeekAndPopController.startPressure] and [PeekAndPopController.peakPressure]
class PeekAndPopDetector extends StatelessWidget {
  final PeekAndPopControllerState _peekAndPopController;
  final Widget child;

  const PeekAndPopDetector(this._peekAndPopController, this.child);
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        child: child,
        builder: (BuildContext context, bool pressRerouted, Widget cachedChild) {
          return IgnorePointer(
              ignoring: pressRerouted,
              child: MyGestureDetector.GestureDetector(
                      startPressure: _peekAndPopController.startPressure,
                      peakPressure: _peekAndPopController.peakPressure,
                      onTap: () {HapticFeedback.mediumImpact();_peekAndPopController.peekAndPopComplete();},
                      onForcePressStart: _peekAndPopController.supportsForcePress 
                                         ? (ForcePressDetails forcePressDetails) {_peekAndPopController.pushPeekAndPop(forcePressDetails);} 
                                         : null,
                      onForcePressUpdate: _peekAndPopController.supportsForcePress 
                                          ? (ForcePressDetails forcePressDetails) {_peekAndPopController.updatePeekAndPop(forcePressDetails);} 
                                          : null,
                      onForcePressEnd: (ForcePressDetails forcePressDetails) {},
                      onForcePressPeak: _peekAndPopController.supportsForcePress 
                                        ? (ForcePressDetails forcePressDetails) {_peekAndPopController.finishPeekAndPop(forcePressDetails);} 
                                        : null,
                      onLongPressStart: _peekAndPopController.supportsForcePress 
                                        ? null 
                                        : (LongPressStartDetails longPressStartDetails) {_peekAndPopController.pushPeekAndPop(longPressStartDetails);},
                      onLongPressEnd: (LongPressEndDetails longPressEndDetails) {},
                      child: cachedChild));
        },
        valueListenable: _peekAndPopController.pressReroutedNotifier);
  }
}
