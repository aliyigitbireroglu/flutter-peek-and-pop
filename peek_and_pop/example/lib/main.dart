//Note: Don't forget to add <key>io.flutter.embedded_views_preview</key><string>YES</string> to your Info.plist. See
//[webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) for more info.

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// © Cosmos Software | Ali Yigit Bireroglu                                                                                                           /
// All material used in the making of this code, project, program, application, software et cetera (the "Intellectual Property")                     /
// belongs completely and solely to Ali Yigit Bireroglu. This includes but is not limited to the source code, the multimedia and                     /
// other asset files. If you were granted this Intellectual Property for personal use, you are obligated to include this copyright                   /
// text at all times.                                                                                                                                /
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//@formatter:off

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'nav_bar.dart' as MyNavBar;

import 'package:peek_and_pop/peek_and_pop.dart';
import 'package:peek_and_pop/misc.dart' as PeekAndPopMisc;

PeekAndPopControllerState peekAndPopController;

final GlobalKey<ScaffoldState> scaffold = GlobalKey<ScaffoldState>();
final GlobalKey header = GlobalKey();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: PeekAndPopMisc.background,
      child: MaterialApp(
        title: 'Peek & Pop Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MyHomePage(title: 'Peek & Pop Demo'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void onPushPeekAndPop(PeekAndPopControllerState _peekAndPopController) {
    peekAndPopController = _peekAndPopController;
  }

  void showSnackbar() {
    scaffold.currentState.showSnackBar(SnackBar(content: const Text("Everything works as usual.")));
  }

  Widget paddingWrapper(Widget child) {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(25),
        child: child,
      ),
    );
  }

  Widget atPeekWrapper(Widget child, PeekAndPopControllerState _peekAndPopController) {
     return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: [
          const BoxShadow(
            color: Colors.black,
            offset: const Offset(0, 15),
            spreadRadius: -5,
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        child: child,
      ),
    );
  }

  MyNavBar.CupertinoNavigationBar appBar(PeekAndPopControllerState _peekAndPopController) {
    return MyNavBar.CupertinoNavigationBar(
      key: header,
      backgroundColor: const Color(0xff1B1B1B),
      border: const Border(
        bottom: const BorderSide(
          color: Colors.black,
          width: 0.0,
          style: BorderStyle.solid,
        ),
      ),
      middle: const Text(
        "Peek & Pop",
        style: const TextStyle(color: const Color(0xffFF9500)),
      ),
      leading: CupertinoButton(
        padding: EdgeInsets.only(bottom: 2),
        onPressed: () {
          HapticFeedback.mediumImpact();
          _peekAndPopController.closePeekAndPop();
        },
        child: const Icon(
          CupertinoIcons.left_chevron,
          size: 25,
          color: const Color(0xffFF9500),
        ),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.only(bottom: 2),
        onPressed: () {
          HapticFeedback.mediumImpact();
          showSnackbar();
        },
        child: const Icon(
          CupertinoIcons.heart_solid,
          size: 25,
          color: const Color(0xffFF9500),
        ),
      ),
      transitionBetweenRoutes: false,
    );
  }

  Widget atPopWrapper(Widget child, PeekAndPopControllerState _peekAndPopController) {
    return Scaffold(
      key: scaffold,
      appBar: appBar(_peekAndPopController),
      body: SizedBox.expand(child: child),
    );
  }

  Widget normalRow(String text, Color color) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget specialRow(String text, Color color) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Hero(
            tag: "Hero",
            child: Image.asset(
              "assets/Hero.png",
              fit: BoxFit.contain,
              key: Key("Image"),
            ),
          ),
        ),
      ),
    );
  }

  Widget normalPeekAndPopBuilderAtPeek(BuildContext context, PeekAndPopControllerState _peekAndPopController) {
    return atPeekWrapper(
      Image.asset(
        "assets/Scenery.jpeg",
        fit: BoxFit.contain,
        key: Key("Image"),
      ),
      _peekAndPopController,
    );
  }

  Widget normalPeekAndPopBuilderAtPop(BuildContext context, PeekAndPopControllerState _peekAndPopController) {
    return atPopWrapper(
      Transform.translate(
        offset: Offset(0, -50),
        child: Image.asset(
          "assets/Scenery.jpeg",
          fit: BoxFit.contain,
          key: Key("Image"),
        ),
      ),
      _peekAndPopController,
    );
  }

  Widget platformViewPeekAndPopBuilder(BuildContext context, PeekAndPopControllerState _peekAndPopController) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: (_peekAndPopController.willBeDone || _peekAndPopController.isDone) ? null : const BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: (_peekAndPopController.willBeDone || _peekAndPopController.isDone)
            ? null
            : [
                const BoxShadow(
                  color: Colors.black,
                  offset: const Offset(0, 15),
                  spreadRadius: -5,
                  blurRadius: 20,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
            (_peekAndPopController.willBeDone || _peekAndPopController.isDone) ? const Radius.circular(0.0) : const Radius.circular(10.0)),
        child: Scaffold(
          key: scaffold,
          appBar: (_peekAndPopController.willBeDone || _peekAndPopController.isDone) ? appBar(_peekAndPopController) : null,
          body: SizedBox.expand(
            child: (peekAndPopController.stage == Stage.IsPeeking || _peekAndPopController.willBeDone || peekAndPopController.isDone) &&
                    DateTime.now().difference(_peekAndPopController.pushTime).inSeconds > 1
                ? InAppBrowser("https://flutter.dev")
                : peekAndPopController.stage == Stage.WillCancel || peekAndPopController.stage == Stage.IsCancelled
                    ? Container()
                    : const Center(child: const CupertinoActivityIndicator()),
          ),
        ),
      ),
    );
  }

  Widget specialPeekAndPopBuilder(BuildContext context, PeekAndPopControllerState _peekAndPopController) {
    if (_peekAndPopController.willBeDone || _peekAndPopController.isDone)
      return atPopWrapper(
        Transform.translate(
          offset: Offset(0, -50),
          child: Hero(
            tag: "Hero",
            child: Image.asset(
              "assets/Hero.png",
              fit: BoxFit.contain,
              key: Key("Image"),
            ),
          ),
        ),
        _peekAndPopController,
      );
    else
      return Image.asset(
        "assets/Hero.png",
        fit: BoxFit.contain,
        key: Key("Image"),
      );
  }

  Widget gridPeekAndPopBuilderAtPeek(int index, BuildContext context, PeekAndPopControllerState _peekAndPopController) {
    return atPeekWrapper(
      Image.asset(
        "assets/" + index.toString() + ".jpeg",
        fit: BoxFit.contain,
        key: Key("Image"),
      ),
      _peekAndPopController,
    );
  }

  Widget gridPeekAndPopBuilderAtPop(int index, BuildContext context, PeekAndPopControllerState _peekAndPopController) {
    return atPopWrapper(
      Transform.translate(
        offset: Offset(0, -50),
        child: Image.asset(
          "assets/" + index.toString() + ".jpeg",
          fit: BoxFit.contain,
          key: Key("Image"),
        ),
      ),
      _peekAndPopController,
    );
  }

  QuickActionsData moveableQuickActionsBuilder(PeekAndPopControllerState _peekAndPopController) {
    return QuickActionsData(
      const EdgeInsets.only(left: 12.5, top: 25, right: 12.5, bottom: 25),
      const BorderRadius.all(const Radius.circular(10.0)),
      [
        QuickAction(
          60,
          () {
            _peekAndPopController.peekAndPopChild.quickActions.currentState.animationController.reverse();
            Future.wait([_peekAndPopController.peekAndPopChild.snapController.currentState.move(const Offset(0.0, 0.0))]).then((_) {
              _peekAndPopController.finishPeekAndPop(null);
            });
          },
          const BoxDecoration(
            color: CupertinoColors.white,
            border: const Border(
              bottom: const BorderSide(
                color: CupertinoColors.inactiveGray,
                width: 0.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
          const Center(
            child: const Text(
              "Pop",
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.normal,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        QuickAction(
          60,
          () {},
          const BoxDecoration(
            color: CupertinoColors.white,
            border: const Border(
              bottom: const BorderSide(
                color: CupertinoColors.inactiveGray,
                width: 0.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
          const Center(
            child: const Text(
              "Do Nothing",
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.normal,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        QuickAction(
          60,
          () {
            _peekAndPopController.peekAndPopChild.quickActions.currentState.animationController.reverse();
            Future.wait([_peekAndPopController.peekAndPopChild.snapController.currentState.move(const Offset(0.0, 0.0))]).then((_) {
              _peekAndPopController.cancelPeekAndPop(null);
            });
          },
          const BoxDecoration(
            color: CupertinoColors.white,
            border: const Border(
              top: const BorderSide(
                color: CupertinoColors.inactiveGray,
                width: 0.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
          const Center(
            child: const Text(
              "Dismiss",
              style: const TextStyle(
                color: CupertinoColors.destructiveRed,
                fontWeight: FontWeight.normal,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  QuickActionsData gridQuickActionsBuilder(PeekAndPopControllerState _peekAndPopController) {
    return QuickActionsData(
      const EdgeInsets.only(left: 12.5, top: 25, right: 12.5, bottom: 25),
      const BorderRadius.all(const Radius.circular(10.0)),
      [
        QuickAction(
          60,
          () {
            _peekAndPopController.peekAndPopChild.quickActions.currentState.animationController.reverse();
            Future.wait([_peekAndPopController.peekAndPopChild.snapController.currentState.move(const Offset(0.0, 0.0))]).then((_) {
              _peekAndPopController.finishPeekAndPop(null);
            });
          },
          const BoxDecoration(
            color: CupertinoColors.white,
            border: const Border(
              bottom: const BorderSide(
                color: CupertinoColors.inactiveGray,
                width: 0.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
          const Center(
            child: const Text(
              "Pop",
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.normal,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        QuickAction(
          60,
          () {},
          const BoxDecoration(
            color: CupertinoColors.white,
            border: const Border(
              bottom: const BorderSide(
                color: CupertinoColors.inactiveGray,
                width: 0.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
          const Center(
            child: const Text(
              "Save",
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.normal,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        QuickAction(
          60,
          () {},
          const BoxDecoration(
            color: CupertinoColors.white,
            border: const Border(
              bottom: const BorderSide(
                color: CupertinoColors.inactiveGray,
                width: 0.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
          const Center(
            child: const Text(
              "Share",
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.normal,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        QuickAction(
          60,
          () {
            _peekAndPopController.peekAndPopChild.quickActions.currentState.animationController.reverse();
            Future.wait([_peekAndPopController.peekAndPopChild.snapController.currentState.move(const Offset(0.0, 0.0))]).then((_) {
              _peekAndPopController.cancelPeekAndPop(null);
            });
          },
          const BoxDecoration(
            color: CupertinoColors.white,
            border: const Border(
              top: const BorderSide(
                color: CupertinoColors.inactiveGray,
                width: 0.0,
                style: BorderStyle.solid,
              ),
            ),
          ),
          const Center(
            child: const Text(
              "Dismiss",
              style: const TextStyle(
                color: CupertinoColors.destructiveRed,
                fontWeight: FontWeight.normal,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: PeekAndPopMisc.scaleDownWrapper(
        PageView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: paddingWrapper(
                    PeekAndPopController(
                      normalRow(
                        "Normal with Overlap & without Alignment",
                        Colors.redAccent,
                      ),
                      true,
                      peekAndPopBuilderAtPeek: normalPeekAndPopBuilderAtPeek,
                      peekAndPopBuilderAtPop: normalPeekAndPopBuilderAtPop,
                      sigma: 10,
                      backdropColor: Colors.white,
                      useOverlap: true,
                      useAlignment: false,
                      indicatorScaleUpCoefficient: 0.01,
                      onPushPeekAndPop: onPushPeekAndPop,
                      peekScale: 0.95,
                      peekCoefficient: 0.025,
                    ),
                  ),
                ),
                Expanded(
                  child: paddingWrapper(
                    PeekAndPopController(
                      normalRow(
                        "Moveable with Alignment & without Overlap",
                        Colors.deepPurpleAccent,
                      ),
                      true,
                      peekAndPopBuilderAtPeek: normalPeekAndPopBuilderAtPeek,
                      peekAndPopBuilderAtPop: normalPeekAndPopBuilderAtPop,
                      quickActionsBuilder: moveableQuickActionsBuilder,
                      sigma: 10,
                      backdropColor: Colors.white,
                      useOverlap: false,
                      useAlignment: true,
                      indicatorScaleUpCoefficient: 0.01,
                      onPushPeekAndPop: onPushPeekAndPop,
                      peekScale: 0.95,
                      peekCoefficient: 0.025,
                    ),
                  ),
                ),
                Expanded(
                  child: paddingWrapper(
                    PeekAndPopController(
                      normalRow(
                        "Platform View with Custom Overlap Rect",
                        Colors.cyan,
                      ),
                      true,
                      peekAndPopBuilder: platformViewPeekAndPopBuilder,
                      peekAndPopBuilderUseCache: false,
                      sigma: 10,
                      backdropColor: Colors.white,
                      useOverlap: true,
                      customOverlapRect: Rect.fromLTRB(
                        MediaQuery.of(context).size.width * 0.25,
                        MediaQuery.of(context).size.height * 0.25,
                        MediaQuery.of(context).size.width * 0.25,
                        MediaQuery.of(context).size.height * 0.25,
                      ),
                      useAlignment: true,
                      indicatorScaleUpCoefficient: 0.01,
                      onPushPeekAndPop: onPushPeekAndPop,
                      peekScale: 0.75,
                      peekCoefficient: 0.025,
                    ),
                  ),
                ),
                Expanded(
                  child: paddingWrapper(
                    PeekAndPopController(
                      specialRow(
                        "Hero with Overlap & without Alignment",
                        Colors.greenAccent,
                      ),
                      true,
                      peekAndPopBuilder: specialPeekAndPopBuilder,
                      peekAndPopBuilderUseCache: false,
                      sigma: 10,
                      backdropColor: Colors.white,
                      useOverlap: true,
                      useAlignment: false,
                      indicatorScaleUpCoefficient: 0.01,
                      onPushPeekAndPop: onPushPeekAndPop,
                      peekScale: 0.95,
                      peekCoefficient: 0.025,
                    ),
                  ),
                ),
              ],
            ),
            GridView.count(
              padding: EdgeInsets.all(25),
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              crossAxisCount: 3,
              children: List.generate(30, (int index) {
                return PeekAndPopController(
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/" + index.toString() + ".jpeg",
                        ),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                    ),
                  ),
                  true,
                  peekAndPopBuilderAtPeek: (BuildContext context, PeekAndPopControllerState _peekAndPopController) =>
                      gridPeekAndPopBuilderAtPeek(index, context, _peekAndPopController),
                  peekAndPopBuilderAtPop: (BuildContext context, PeekAndPopControllerState _peekAndPopController) =>
                      gridPeekAndPopBuilderAtPop(index, context, _peekAndPopController),
                  quickActionsBuilder: gridQuickActionsBuilder,
                  sigma: 10,
                  backdropColor: Colors.white,
                  useOverlap: true,
                  useAlignment: false,
                  indicatorScaleUpCoefficient: 0.01,
                  onPushPeekAndPop: onPushPeekAndPop,
                  peekScale: 0.95,
                  peekCoefficient: 0.025,
                );
              }),
            ),
          ],
        ),
        0.04,
      ),
    );
  }
}

class InAppBrowser extends StatefulWidget {
  final String url;

  const InAppBrowser(
    this.url,
  );

  @override
  InAppBrowserState createState() {
    return InAppBrowserState(url);
  }
}

class InAppBrowserState extends State<InAppBrowser> {
  final String url;

  InAppBrowserState(
    this.url,
  );

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: url,
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (NavigationRequest request) => NavigationDecision.navigate,
      onPageFinished: (String url) {},
    );
  }
}
