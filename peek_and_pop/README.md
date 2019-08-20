# peek_and_pop

Peek & Pop implementation for Flutter based on the iOS functionality of the same name.

[Media](#media) | [Description](#description) | [Installation](#installation) | [How-to-Use](#howtouse)

<img src="https://img.shields.io/badge/Cosmos%20Software-Love%20Code-red"/>
<br>


[![Pub](https://img.shields.io/pub/v/peek_and_pop?color=g)](https://pub.dev/packages/peek_and_pop)
[![License](https://img.shields.io/github/license/aliyigitbireroglu/flutter-peek-and-pop?color=blue)](https://github.com/aliyigitbireroglu/flutter-peek-and-pop/blob/master/LICENSE)

## Notice
* **v0.1.9 no longer requires any modifications to Flutter's normal "binding.dart"! You can leave your Flutter source code alone and happy.** 
 
* **If you are updating from an earlier version, you can revert your "binding.dart" to its original format.** 
* * *

## Recent
* **The "Indicator" feature is now added. See [Media](#media) for examples.**

* **Animations are now up to 4x faster with the new optimised blur effect algorithm during the Peek & Pop process.**
* * *


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


<a name="description"></a>
## Description
As a fan of the iOS Peek & Pop functionality, I decided to implement it for Flutter as well.

The package has been tested on iOS but not yet on Android as I don't have access to an Android device with Force Press capabilities. Help about this 
would be appreciated.

For devices that don't support Force Press, the package comes with an adaptation to Long Press *however* the Long Press version of this package is 
still under development and is not fully tested yet so consider it as a developers preview.

##
The power move of this package is what I like to call "Gesture Recognition Rerouting". Normally, when a new widget with GestureDetector or similar 
is pushed over an initial widget used for detecting Force Press or when Navigator is used to pop a new page, the user has to restart the gesture 
for Flutter to resume updating it. This package fixes that problem. As explained in the documentation:

```
This function is called by the instantiated [PeekAndPopChild] once it is ready to be included in the Peek & Pop process. Perhaps the most
essential functionality of this package also takes places in this function: The gesture recognition is rerouted from the [PeekAndPopDetector]
to the instantiated [PeekAndPopChild]. This is important for avoiding the necessity of having the user stop and restart their Force Press.
Instead, the [PeekAndPopController] does this automatically so that the existing Force Press can continue to update even when if
[PeekAndPopDetector] is blocked by the view which is often the case especially when using PlatformViews.
```


<a name="installation"></a>
## Installation
*It is easy. Don't worry.*

**If you do not wish to use PlatformViews and if you are using a version of this package equal to or newer than v0.1.9, you can skip the 
Installation instructions**  

* Step I (Optional)
For properly displaying PlatformViews, this package requires the latest Flutter [master](https://github.com/flutter/flutter) 
branch. *Maybe* it will work with some other version too but tests made with the [webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) 
seem to only properly display with the latest Flutter [master](https://github.com/flutter/flutter) branch which has improved the PlatformViews that 
allow better functionalities such as proper scaling and proper clipping.

    If you do not wish to use PlatformViews, you can skip this step.

    To use latest Flutter [master](https://github.com/flutter/flutter) branch, run the following command and then run the Flutter doctor. That's 
    it, it should  be fine.
    
    **Note**: Don't forget to add <key>io.flutter.embedded_views_preview</key><string>YES</string> to your Info.plist. See
    [webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) for more info.
    
```
$ git clone -b master https://github.com/flutter/flutter.git
$ ./flutter/bin/flutter --version
```

* Step II (Required **ONLY** for versions older than v0.1.9)
This package uses a modified version of Flutter's normal "binding.dart". Nothing essential is changed so do not worry about the edited file 
interfering with your projects. The modifications are mostly about exposing variables that are by default private. The new "binding.dart" is 
otherwise identical to Flutter's normal "binding.dart".

    Overwrite the contents of 

    *(your_flutter_directory)/packages/flutter/lib/src/gestures/binding.dart*

    with the contents of "binding.dart" provided by this package. Then uncomment the parts marked "UNCOMMENT HERE" in "peek_and_pop_controller.dart". 
    These parts had to be commented for cosmetic reasons as Pub considers them to be errors due to the previously explained "binding.dart" 
    modifications. 


<a name="howtouse"></a>
## How-to-Use
*Also easy.* 

First of all, as explained in the documentation:

```
I noticed that a fullscreen blur effect via the [BackdropFilter] widget is not good to use while running the animations required for the Peek &
Pop process as it causes a noticeable drop in the framerate- especially for devices with high resolutions. During a mostly static view, the
drop is acceptable. However, once the animations start running, this drop causes a visual disturbance. To prevent this, a new optimised blur
effect algorithm is implemented. Now, the [BackdropFilter] widget is only used until the animations are about to start. At that moment, it is
replaced by a static image. Therefore, to capture this image, your root CupertinoApp/MaterialApp MUST be wrapped in a [RepaintBoundary] widget
which uses the [background] key. As a result, the Peek & Pop process is now up to 4x more fluent.
```

TL;DR: Wrap your root CupertinoApp/MaterialApp in a RepaintBoundary widget and use the background GlobalKey from "misc.dart". This is required for 
the new optimised blur effect algorithm:

```
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: PeekAndPopMisc.background,
      child: MaterialApp(
        title: 'Peek & Pop Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MyHomePage(title: 'Peek & Pop Demo')));
  }
}
```

Then, create a SnapController as shown in the example project:

```
PeekAndPopController(
  normalRow("Normal", Colors.redAccent), 
  staticNormalPeekAndPopBuilder, 
  false,
  sigma: 5, 
  onPushPeekAndPop: onPushPeekAndPop, 
  peekScale: 0.9)
```

In this excerpt, the normalRow widget is what will be displayed on your regular UI. Once the Peek & Pop process reaches the Peek stage, the 
staticNormalPeekAndPopBuilder build function will be called. As useCache is set to false, this function will be called continuously so that it can 
adapt to the stage of the Peek & Pop process. Once the Peek & Pop process is initiated, it will invoke the onPushPeekAndPop callback from which the
instance of the created PeekAndPopController can be retrieved for further actions. The maximum scale of the widget created by the  
staticNormalPeekAndPopBuilder build function  will not exceed 0.9 during the Peek stage.

* * *
##It is highly recommended to read the documentation and the example project.

<br>

## Notes
I started using and learning Flutter only some weeks ago so this package might have some parts that don't make sense, that should be completely 
different, that could be much better, etc. Please let me know! Nicely! 

Any help, suggestion or criticism is appreciated! 

Cheers.

<br><br>
<img align="right" src="https://www.cosmossoftware.coffee/Common/Images/CosmosSoftwareIconTransparent.png" width="150" height="150"/>
<br><br>