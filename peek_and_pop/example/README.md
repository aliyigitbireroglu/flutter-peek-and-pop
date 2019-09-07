# example

Example Project for peek_and_pop.

Note: Don't forget to add <key>io.flutter.embedded_views_preview</key><string>YES</string> to your Info.plist. See
[webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) for more info.


# peek_and_pop

[comment]: <> (Badges)
<a href="https://www.cosmossoftware.coffee">
   <img alt="Cosmos Software" src="https://img.shields.io/badge/Cosmos%20Software-Love%20Code-red" />
</a>
<a href="https://www.cosmossoftware.coffee">
   <img alt="Cosmos Software" src="https://img.shields.io/badge/Developer's-Choice-yellow" />
</a>
<br>

<a href="https://github.com/Solido/awesome-flutter">
   <img alt="Awesome Flutter" src="https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square" />
</a>
<br>

[![Pub](https://img.shields.io/pub/v/peek_and_pop?color=g)](https://pub.dev/packages/peek_and_pop)
[![License](https://img.shields.io/github/license/aliyigitbireroglu/flutter-peek-and-pop?color=blue)](https://github.com/aliyigitbireroglu/flutter-peek-and-pop/blob/master/LICENSE)

[comment]: <> (Introduction)
<img src="https://www.cosmossoftware.coffee/Common/Portfolio/Images/FlutterPeekAndPopMockUp.jpg" max-height="450"/>
<br><br>
Peek & Pop implementation for Flutter based on the iOS functionality of the same name.

**Finally, the v1.0.0 release! More fluent, more optimised and more beautiful than ever. Very customisable and very easy to use.**

**It is highly recommended to read the documentation and run the example project on a real device to fully understand and inspect the full range of
 capabilities.**

[comment]: <> (ToC)
[Media](#media) | [Description](#description) | [Installation](#installation) | [How-to-Use](#howtouse)

[comment]: <> (Notice)
## Notice
* **v0.1.9 and higher no longer requires any modifications to Flutter's normal "binding.dart"! You can leave your Flutter source code alone and happy.** 
 
* **If you are updating from an earlier version, you can revert your "binding.dart" to its original format.** 
* * *
[comment]: <> (Recent)
## Recent
* **The "Quick Actions" feature is now added. It is highly customisable and you can show a dynamic menu with quick action buttons as the view is 
    dragged and snapped very easily. The drag and snap limits will be automatically set according to the menu and the view. 
    [snap](https://pub.dev/packages/snap) is now implemented directly to the package. See [Media](#media) for examples.**
    
* **The "Overlap" and "Alignment" features are now added. These two features create a much more fluent Peek & Pop process that is much more similar 
    to the actual iOS version. See [Media](#media) for examples.**
    
* **The "Scale Up" and "Scale Down" features are now added. You can use these features to scale a widget down or up as the Peek & Pop process 
    proceeds. "Scale Up" is also supported for the "Indicator" feature out of the box.See [Media](#media) for examples.**

* **Improved enumeration for the stage of the Peek & Pop process.**

* **The "Indicator" feature is now added. See [Media](#media) for examples.**

* **Animations are now up to 4x faster with the new optimised blur effect algorithm during the Peek & Pop process.**
* * *
[comment]: <> (Warning)
## Warning
* **"isHero" is now removed. It wasn't playing well with the package algorithm and it is considered to be unnecessary for the Peek & Pop process. 
    However, this shouldn't be a problem due to the addition of the new "Overlap" and "Alignment" features. If you must use a Hero widget, only use it 
    while "willBeDone" or "isDone" is true.**
    
* **Old installation instructions are removed. If you wish (for some reason) to use a version older than v0.1.9, see the README of that version for 
    the relevant installation instructions.** 
* * *


[comment]: <> (Media)
<a name="media"></a>
## Media

Watch on **Youtube**:
  
[**v1.0.0 Showcase Demo**](https://youtu.be/IQq_ty5mRYU) | [**v1.0.0 Technical Preview**](https://youtu.be/hIjoWfP0krA)
<br><br>
[v0.1.7](https://youtu.be/wOWCV7HJzwc)

[v0.1.0 Mixed](https://youtu.be/G5QLwGtcb1I)
 
[v0.0.1 Normal](https://youtu.be/PaEpU31z_7Q) | [v0.0.1 Moveable](https://youtu.be/3TjCFwHoOiE) | [v0.0.1 Platform View](https://youtu.be/489YB-QuJ3k) | [v0.0.1 Hero](https://youtu.be/36DAwnFKSKI)
<br><br>
<img src="https://www.cosmossoftware.coffee/Common/Portfolio/GIFs/FlutterPeekAndPopShowcase.gif" max-height="450"/>
<img src="https://www.cosmossoftware.coffee/Common/Portfolio/GIFs/FlutterPeekAndPopTechnical.gif" max-height="450"/>
<br><br>


[comment]: <> (Description)
<a name="description"></a>
## Description
As a fan of the iOS Peek & Pop functionality, I decided to implement it for Flutter as well.

The package has been tested on iOS but not yet on Android as I don't have access to an Android device with Force Press capabilities. Help about 
this would be appreciated.

~~For devices that don't support Force Press, the package comes with an adaptation to Long Press *however* the Long Press version of this package is 
still under development and is not yet fully tested so consider it as a developers preview.~~ 

(The Long Press version is temporarily removed. It will be added back soon.)

##
The power move of this package is what I like to call "Gesture Recognition Rerouting". Normally, when a new widget with GestureDetector or similar 
is pushed over an initial widget used for detecting Force Press or when Navigator is used to pop a new page, the user has to restart the gesture 
for Flutter to resume updating it. This package fixes that problem as explained in the documentation:

```
//This function is called by the instantiated [PeekAndPopChild] once it is ready to be included in the Peek & Pop process. Perhaps the most
//essential functionality of this package also takes places in this function: The gesture recognition is rerouted from the [PeekAndPopDetector]
//to the instantiated [PeekAndPopChild]. This is important for avoiding the necessity of having the user stop and restart their Force Press.
//Instead, the [PeekAndPopController] does this automatically so that the existing Force Press can continue to update even when if
//[PeekAndPopDetector] is blocked by the view which is often the case especially when using PlatformViews.
```


[comment]: <> (Installation)
<a name="installation"></a>
## Installation
*It is easy. Don't worry.*

**If you do not wish to use PlatformViews you can skip the installation instructions.**

**Old installation instructions are removed. If you wish (for some reason) to use a version older than v0.1.9, see the README of that version for 
the relevant installation instructions.** 

For properly displaying PlatformViews, this package requires the latest Flutter [master](https://github.com/flutter/flutter) 
branch. *Maybe* it will work with some other version too but tests made with the [webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) 
seem to only properly display with the latest Flutter [master](https://github.com/flutter/flutter) branch which has improved the PlatformViews that 
allow better functionalities such as proper scaling and proper clipping.

If you do not wish to use PlatformViews, you can skip this step.

To use latest Flutter [master](https://github.com/flutter/flutter) branch, run the following command.

**Note**: Don't forget to add <key>io.flutter.embedded_views_preview</key><string>YES</string> to your Info.plist. See
[webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) for more info.
    
```
$ git clone -b master https://github.com/flutter/flutter.git
$ flutter channel master
$ flutter upgrade
$ flutter doctor
$ ./flutter/bin/flutter --version
```


[comment]: <> (How-to-Use)
<a name="howtouse"></a>
## How-to-Use
*Also easy.* 

First of all, as explained in the documentation:

```
//I noticed that a fullscreen blur effect via the [BackdropFilter] widget is not good to use while running the animations required for the Peek &
//Pop process as it causes a noticeable drop in the framerate- especially for devices with high resolutions. During a mostly static view, the
//drop is acceptable. However, once the animations start running, this drop causes a visual disturbance. To prevent this, a new optimised blur
//effect algorithm is implemented. Now, the [BackdropFilter] widget is only used until the animations are about to start. At that moment, it is
//replaced by a static image. Therefore, to capture this image, your root CupertinoApp/MaterialApp MUST be wrapped in a [RepaintBoundary] widget
//which uses the [background] key. As a result, the Peek & Pop process is now up to 4x more fluent.
```

TL;DR: Wrap your root CupertinoApp/MaterialApp in a RepaintBoundary widget and use the background GlobalKey from "misc.dart". 

This is required for the new optimised blur effect algorithm:

```
import 'package:peek_and_pop/misc.dart' as PeekAndPopMisc;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: PeekAndPopMisc.background,
      child: MaterialApp(
        title: 'Peek & Pop Demo',
        home: MyHomePage(title: 'Peek & Pop Demo')
      )
    );
  }
}
```

If you wish to use the "ScaleUp" or the "Scale Down" features, wrap the widgets you wish to scale down or scale up during the Peek & Pop process with 
the scaleUpWrapper and scaleDownWrapper functions from "misc.dart":

```
@override
Widget build(BuildContext context) {
return Scaffold(
  appBar: AppBar(title: Text(widget.title)),
  body: PeekAndPopMisc.scaleDownWrapper(
        ...,
        0.04,
        ),
    );    
}
```

Then, create a PeekAndPopController such as:

```
PeekAndPopController(
  uiChild(),            //Widget uiChild
  false,                //bool uiChildUseCache
 {Key key,
  peekAndPopBuilder,
  peekAndPopBuilderUseCache,
  peekAndPopBuilderAtPeek       : peekAndPopBuilderAtPeek,
  peekAndPopBuilderAtPop        : peekAndPopBuilderAtPop,
  quickActionsBuilder           : quickActionsBuilder,
  sigma                         : 10,
  backdropColor                 : Colors.black,
  alpha                         : 126,
  overlayBuilder                : overlayBuilder,
  useOverlap                    : true,
  customOverlapRect,
  useAlignment,                 : false,
  useIndicator                  : true,
  indicatorScaleUpCoefficient   : 0.01,
  willPeekAndPopComplete        : _willPeekAndPopComplete,
  willPushPeekAndPop            : _willPushPeekAndPop,
  willUpdatePeekAndPop          : _willUpdatePeekAndPop,
  willCancelPeekAndPop          : _willCancelPeekAndPop,
  willFinishPeekAndPop          : _willFinishPeekAndPop,
  willClosePeekAndPop           : _willClosePeekAndPop,
  onPeekAndPopComplete          : _onPeekAndPopComplete,
  onPushPeekAndPop              : _onPushPeekAndPop,
  onUpdatePeekAndPop            : _onUpdatePeekAndPop,
  onCancelPeekAndPop            : _onCancelPeekAndPop,
  onFinishPeekAndPop            : _onFinishPeekAndPop,
  onClosePeekAndPop             : _onFinishPeekAndPop,
  onPressStart                  : _onPressStart,
  onPressUpdate                 : _onPressUpdate,
  onPressEnd                    : _onPressEnd,
  treshold                      : 0.5,
  startPressure                 : 0.125,
  peakPressure                  : 1.0,
  peekScale                     : 0.5,
  peekCoefficient               : 0.05,
  popTransition,
  useHaptics                    : true})
  
Widget uiChild() {}

Widget peekAndPopBuilderAtPeek(BuildContext context, PeekAndPopControllerState _peekAndPopController);
Widget peekAndPopBuilderAtPop(BuildContext context, PeekAndPopControllerState _peekAndPopController);

QuickActionsData quickActionsBuilder(PeekAndPopControllerState _peekAndPopController);

WidgetBuilder overlayBuiler(BuildContext context);

bool _willPeekAndPopComplete(PeekAndPopControllerState _peekAndPopController);
bool _willPushPeekAndPop(PeekAndPopControllerState _peekAndPopController);
bool _willUpdatePeekAndPop(PeekAndPopControllerState _peekAndPopController);
bool _willCancelPeekAndPop(PeekAndPopControllerState _peekAndPopController);
bool _willFinishPeekAndPop(PeekAndPopControllerState _peekAndPopController);
bool _willClosePeekAndPop(PeekAndPopControllerState _peekAndPopController);

void _onPeekAndPopComplete(PeekAndPopControllerState _peekAndPopController);
void _onPushPeekAndPop(PeekAndPopControllerState _peekAndPopController);
void _onUpdatePeekAndPop(PeekAndPopControllerState _peekAndPopController);
void _onCancelPeekAndPop(PeekAndPopControllerState _peekAndPopController);
void _onFinishPeekAndPop(PeekAndPopControllerState _peekAndPopController);
void _onClosePeekAndPop(PeekAndPopControllerState _peekAndPopController);

void _onPressStart(dynamic dragDetails);
void _onPressUpdate(dynamic dragDetails);
void _onPressEnd(dynamic dragDetails);
 
```

**Further Explanations:**

*For a complete set of descriptions for all parameters and methods, see the [documentation](https://pub.dev/documentation/peek_and_pop/latest/).* 

* Set [uiChildUseCache] to true if your [uiChild] doesn't change during the Peek & Pop process.
* Set [peekAndPopBuilderUseCache] to true if your [peekAndPopBuilder] doesn't change during the Peek & Pop process.
* If [peekAndPopBuilderAtPop] and [peekAndPopBuilderAtPeek] are set, [peekAndPopBuilder] and [peekAndPopBuilderUseCache] are ignored.
* If one of [peekAndPopBuilderAtPop] and [peekAndPopBuilderAtPeek] is set, the other one must be set too.
* If [quickActionsBuilder] is set, it is recommended that [peekAndPopBuilderAtPop] and [peekAndPopBuilderAtPop] are set too.
* [overlayBuilder] is an optional second view to be displayed  during the Peek & Pop process. This entire widget is built after everything else.
* For all [PeekAndPopProcessNotifier] callbacks such as [willPeekAndPopComplete], you can return false to prevent the default action.
* All [PeekAndPopProcessNotifier] and [PeekAndPopProcessCallback] callbacks will return a reference to the created [PeekAndPopController] state.
You can save this instance for further actions.
* [pageTransition] is the transition to be used when the view is opened directly or when the view is closed. A default [SlideTransition] is provided.
* Use [PeekAndPopControllerState]'s [void closePeekAndPop()] method to close the Peek & Pop process. Do not call [Navigator.of(context).pop()] 
directly.
* Use [PeekAndPopControllerState]'s [stage] variable to get enumeration for the stage of the Peek & Pop process. If you want to only know when the 
Peek & Pop process will be or is completed, you can also use [willBeDone] or [isDone] variables.


[comment]: <> (Notes)
## Notes
I started using and learning Flutter only some weeks ago so this package might have some parts that don't make sense, that should be completely 
different, that could be much better, etc. Please let me know! Nicely! 

Any help, suggestion or criticism is appreciated! 

Cheers.

[comment]: <> (CosmosSoftware)
<br><br>
<img align="right" src="https://www.cosmossoftware.coffee/Common/Images/CosmosSoftwareIconTransparent.png" width="150" height="150"/>
<br><br>