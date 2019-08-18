# example

Example Project for peek_and_pop.

Note: Don't forget to add <key>io.flutter.embedded_views_preview</key><string>YES</string> to your Info.plist. See
[webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) for more info.


# peek_and_pop

Peek & Pop implementation for Flutter based on the iOS functionality of the same name. 

**The "Indicator" feature is now added. See the [Media](#media) for examples.**

**Now up to 4x faster animations with the new optimised blur effect algorithm during the Peek & Pop process- regardless of what sigma value is 
selected!**

1. [Media](#media) 
2. [Description](#description) 
3. [Installation](#installation) 
4. [How-to-Use](#howtouse)


<a name="media"></a>
## Media
*Videos*

* [v0.1.7](https://youtu.be/wOWCV7HJzwc)
<br><br>
* [v0.1.0 Mixed](https://youtu.be/G5QLwGtcb1I)
* [v0.0.1 Normal](https://youtu.be/PaEpU31z_7Q) 
* [v0.0.1 Moveable](https://youtu.be/3TjCFwHoOiE)
* [v0.0.1 Platform View](https://youtu.be/489YB-QuJ3k)
* [v0.0.1 Hero](https://youtu.be/36DAwnFKSKI)

*GIFs*
<br><br>
<img src="https://www.cosmossoftware.coffee/Common/Portfolio/GIFs/FlutterPeekAndPop.gif"/>
<br><br>

**IMPORTANT**: Read more for installation details.


<a name="description"></a>
## Description
As a fan of the iOS Peek & Pop functionality, I decided to implement it for Flutter as well. Please note that this is 
still an early version so use with care. 

The package has been tested on iOS but not yet on Android as I don't have access to an Android device with Force Press 
capabilities. Help about this would be appreciated.

For devices that don't support Force Press, the package comes with an adaptation to Long Press *however* the Long Press 
version of this package is still under development and is not fully tested yet so consider it as a developers preview.

## 
The power move of this package is what I like to call "Gesture Recognition Rerouting". Normally, when a new widget
with GestureDetector or similar is pushed over an initial widget used for detecting Force Press, the user has to restart 
the gesture for Flutter to resume updating it. This package fixes that problem. As explained in the documentation:

```
///This function is called by the instantiated [PeekAndPopChild] once it is ready to be included in the Peek & Pop process. Perhaps the most
///essential functionality of this package also takes places in this function: The gesture recognition is rerouted from the  [PeekAndPopDetector]
///to the instantiated [PeekAndPopChild]. This is important for avoiding the necessity of having the user stop and restart their Force Press.
///Instead, the [PeekAndPopController] does this automatically so that the existing Force Press can continue to update even when if
///[PeekAndPopDetector] is blocked by the view which is often the case especially when using PlatformViews.
```


<a name="installation"></a>
## Installation
*It is easy. Don't worry.* 

* Step I (Optional)
For properly displaying PlatformViews, this package requires the latest Flutter [master](https://github.com/flutter/flutter) 
branch. *Maybe* it will work with some other version too but tests made with the 
[webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) seem to only properly display with the latest Flutter 
[master](https://github.com/flutter/flutter) branch which has improved the PlatformViews that allow better functionalities 
such as proper scaling and proper clipping.

    If you do not wish to use PlatformViews, you can skip this step.

    To use latest Flutter [master](https://github.com/flutter/flutter) branch, run the following command and then run 
    the Flutter doctor. That's it, it should  be fine.
    
    **Note**: Don't forget to add <key>io.flutter.embedded_views_preview</key><string>YES</string> to your Info.plist. See
    [webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) for more info.
    
```
$ git clone -b master https://github.com/flutter/flutter.git
$ ./flutter/bin/flutter --version
```

* Step II (Required)
This package uses a modified version of Flutter's normal "binding.dart". Nothing essential is changed so do not worry 
about the edited file interfering with your projects. The modifications are mostly about exposing variables that are by 
default private. The new "binding.dart" is otherwise identical to Flutter's normal "binding.dart".

    Overwrite the contents of 

    *(your_flutter_directory)/packages/flutter/lib/src/gestures/binding.dart*

    with the contents of "binding.dart" provided by this package. Then uncomment the parts marked "UNCOMMENT HERE" in 
    "peek_and_pop_controller.dart". These parts had to be commented for cosmetic reasons as Pub considers them to be errors 
    due to the previously explained "binding.dart" modifications. 


<a name="howtouse"></a>
## How-to-Use
*Also easy.* 

The example project is, I hope, very self-explanatory but there is one very important rule. As explained in the documentation:

```
///I noticed that a fullscreen blur effect via the [BackdropFilter] widget is not good to use while running the animations required for the Peek &
///Pop process as it causes a noticeable drop in the framerate- especially for devices with high resolutions. During a mostly static view, the
///drop is acceptable. However, once the animations start running, this drop causes a visual disturbance. To prevent this, a new optimised blur
///effect algorithm is implemented. Now, the [BackdropFilter] widget is only used until the animations are about to start. At that moment, it is
///replaced by a static image. Therefore, to capture this image, your root CupertinoApp/MaterialApp MUST be wrapped in a [RepaintBoundary] widget
///which uses the [background] key. As a result, the Peek & Pop process is now up to 4x more fluent.
```

TL;DR: Wrap your root CupertinoApp/MaterialApp in a RepaintBoundary widget and use the background key from "misc.dart". This is required for the new 
optimised blur effect algorithm.

Then start using the PeekAndPopController widget with your parameters! This widget is highly customisable so I **STRONGLY** recommend that you 
read the documentation for each file provided by this package for making full use of the capabilities.


## Notes
I started using and learning Flutter only some weeks ago so this package might have some parts that don't make sense, 
that should be completely different, that could be much better, etc. Please let me know! Nicely! 

Any help, suggestion or criticism is appreciated! 

Cheers.

<br><br>
<img align="right" src="https://www.cosmossoftware.coffee/Common/Images/CosmosSoftwareIconTransparent.png" width="150" height="150"/>
<br><br>