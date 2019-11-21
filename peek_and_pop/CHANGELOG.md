## [1.0.3] - 21.11.2019

* Minor changes.

## [1.0.2] - 07.09.2019

* Two new PeekAndPopBuilders are added to [PeekAndPopController]. Use [PeekAndPopController.peekAndPopBuilderAtPeek] and 
[PeekAndPopController.peekAndPopBuilderAtPop] for both convenience and improved performance.

* Improved performance.

* [1.0.2+1] Support for latest dependencies.

## [1.0.1] - 03.09.2019

* Minor changes.

## [1.0.0] - 30.08.2019

* The "Quick Actions" feature is now added. It is highly customisable and you can show a dynamic menu with quick action buttons as the view is 
dragged and snapped very easily. The drag and snap limits will be automatically set according to the menu and the view. 
[snap](https://pub.dev/packages/snap) is now implemented directly to the package. See this [video](https://youtu.be/IQq_ty5mRYU) for examples.

* The "Overlap" and "Alignment" features are now added. These two features create a much more fluent Peek & Pop process that is much more similar 
to the actual iOS version. See this [video](https://youtu.be/IQq_ty5mRYU) for examples.

* The "Scale Up" and "Scale Down" features are now added. You can use these features to scale a widget down or up as the Peek & Pop process 
proceeds. "Scale Up" is also supported for the "Indicator" feature out of the box. See this [video](https://youtu.be/IQq_ty5mRYU) for examples.

* "isHero" is now removed. It wasn't playing well with the package algorithm and it is considered to be unnecessary for the Peek & Pop process. 
However, this shouldn't be a problem due to the addition of the new "Overlap" and "Alignment" features. If you must use a Hero widget, only use it 
while "willBeDone" or "isDone" is true.

* A workaround is implemented to avoid a Flutter Engine bug that was causing trouble with the optimised blur effect algorithm.

* Improved enumeration for the stage of the Peek & Pop process.

* Improved performance.

* Fine tuning.

* Improved code style.

* Improved example project.

* Updated README.

* Old installation instructions are removed. If you wish (for some reason) to use a version older than v0.1.9, see the README of that version for 
the relevant installation instructions.

## [0.2.0] - 23.08.2019

* Improved performance.

* Minor changes.

* Improved code style with trailing commas.

* [0.2.0+1] Minor changes.

## [0.1.9] - 20.08.2019

* Modifications to Flutter's normal "binding.dart" are no longer required!

* The Long Press version is temporarily removed. It will be added back soon.

* Code excerpt added to the README.

* Updated README.

* [0.1.9+1] Updated README.

## [0.1.8] - 18.08.2019

* Example project adapted to the updated [snap](https://pub.dev/packages/snap).

* Minor changes.

* [0.1.8+1] Updated README.

## [0.1.7] - 14.08.2019

* The "Indicator" feature added. See this [video](https://youtu.be/wOWCV7HJzwc) for examples.

* Improved performance.

* Fine tuning.

## [0.1.6] - 12.08.2019

* Improved Long Press version (still under development).

* Fine tuning.

* Improved documentation.

* Updated README.

## [0.1.5] - 11.08.2019

* Improved performance.

* Improved code style.

## [0.1.4] - 11.08.2019

* A minor bug is fixed.

## [0.1.3] - 07.08.2019

* A minor bug in the example project is fixed.

* Updated README: 
  
  **Note**: Don't forget to add <key>io.flutter.embedded_views_preview</key><string>YES</string> to your Info.plist. See
  [webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) for more info.

## [0.1.2] - 07.08.2019

* [snap](https://pub.dev/packages/snap) is now implemented directly to the example.

* More callbacks added for better control.

* Simple enumeration for the stage of the Peek & Pop process added.

* Improved animations.

* Improved documentation.

## [0.1.1] - 06.08.2019

* Improved code style.

## [0.1.0] - 06.08.2019

* Improved Long Press version (still under development).

* Improved documentation.

## [0.0.1] - 05.08.2019

* Initial release.
