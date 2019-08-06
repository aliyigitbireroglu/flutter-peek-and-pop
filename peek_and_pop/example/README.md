# example

Example Project for peek_and_pop

# peek_and_pop

Peek & Pop implementation for Flutter based on the iOS functionality of the same name. 

## Media
*Videos*

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

## Description

As a fan of the iOS Peek & Pop functionality, I decided to implement it for Flutter as well. Please note that this is 
still a 0.1.0 version so use with care. 

The package has been tested on iOS but not yet on Android as I don't have access 
to an Android device with Force Press capabilities. Help about this would be appreciated.

For devices that don't support Force Press, the package comes with an adaptation to Long Press *however* the Long Press 
version of this package is still under development and is not fully tested yet so consider it as a developers preview.

## 
The power move of this package is its "gesture recognition rerouting" functionality. Normally, when a new widget
with GestureDetector or similar is pushed over an initial widget used for detecting Force Press, the user has to restart 
the gesture for Flutter to resume updating it. This package fixes that problem. As explained in the documentation:

```
///This function is called by the instantiated [PeekAndPopChildState] once it is ready to be included in the Peek & Pop process. Perhaps the most
///essential functionality of this package also takes places in this function: The gesture recognition is rerouted from the  [PeekAndPopDetector]
///to the instantiated [PeekAndPopChildState]. This is important for avoiding the necessity of having the user stop and restart their Force Press.
///Instead, the [PeekAndPopControllerState] does this automatically so that the existing Force Press can continue to update even when if
///[PeekAndPopDetector] is blocked by the view which is often the case especially when using PlatformViews. 
```

## Installation
*It is easy. Don't worry.* 

* Step I (Optional)
For properly displaying PlatformViews, this package requires the latest Flutter [master](https://github.com/flutter/flutter) 
branch. *Maybe* it will work with some other version too but tests made with the 
[webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) seem to only properly display with the latest Flutter 
[master](https://github.com/flutter/flutter) branch which has improved PlatformViews that allow better functionalities 
such as proper scaling and proper clipping.

    If you do not wish to use PlatformViews, you can skip this step.

    To use latest Flutter [master](https://github.com/flutter/flutter) branch, run the following command and then run 
    the Flutter doctor. And that's it, it should  be fine.
    
```
$ git clone -b master https://github.com/flutter/flutter.git
$ ./flutter/bin/flutter --version
```

* Step II (Required)
This package uses a modified version of Flutter's 'binding.dart' file. Nothing essential is changed so do not worry 
about the edited file interfering with your projects. The modifications are mostly about exposing variables that are by 
default private.

    Overwrite the contents of 

    *(your_flutter_directory)/packages/flutter/lib/src/gestures/binding.dart*

    with the contents of 'binding.dart' provided by this package. Then uncomment the parts marked "UNCOMMENT HERE" in 
    'peek_and_pop_controller.dart'. These parts had to be commented for cosmetic reasons as Pub considers them to be errors 
    due to the previously explained 'binding.dart' modifications. 

## Notes
I started using and learning Flutter only some weeks ago so this package might have some parts that don't make sense, 
that should be completely different, that could be much better, etc. Let me know! Nicely! 

Any help, suggestion or criticism is appreciated! 

Cheers.

<br><br>
<img src="https://www.cosmossoftware.coffee/Common/Images/CosmosSoftwareIconRounded.png" width="200" height="200"/>
<br><br>