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

import 'package:snap/snap.dart';
import 'package:peek_and_pop/peek_and_pop.dart';
import 'package:peek_and_pop/misc.dart' as PeekAndPopMisc;

PeekAndPopControllerState peekAndPopController;

final GlobalKey<SnapControllerState> snapController = GlobalKey<SnapControllerState>();
final GlobalKey view = GlobalKey();
final GlobalKey bound = GlobalKey();

final GlobalKey<ScaffoldState> scaffold = GlobalKey<ScaffoldState>();
final GlobalKey<PopUpState> popUp = GlobalKey<PopUpState>();

double screenHeight;

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.title)), body: Body());
  }
}

class Body extends StatelessWidget {
  bool willUpdatePeekAndPop(PeekAndPopControllerState _peekAndPopController) {
    return snapController.currentState == null || !snapController.currentState.isMoved(25);
  }

  bool willCancelPeekAndPop(PeekAndPopControllerState _peekAndPopController) {
    return snapController.currentState == null || !snapController.currentState.isMoved(25);
  }

  bool willFinishPeekAndPop(PeekAndPopControllerState _peekAndPopController) {
    if (snapController.currentState == null)
      return true;
    else if (snapController.currentState.isMoved(25))
      return false;
    else {
      snapController.currentState.move(Offset.zero);
      return true;
    }
  }

  void onPushPeekAndPop(PeekAndPopControllerState _peekAndPopController) {
    peekAndPopController = _peekAndPopController;
  }

  void onPressStart(dynamic pressDetails) {
    if (snapController.currentState != null) snapController.currentState.beginDrag(pressDetails);
  }

  void onPressUpdate(dynamic pressDetails) {
    if (snapController.currentState != null) snapController.currentState.updateDrag(pressDetails);
  }

  void onPressEnd(dynamic pressDetails) {
    if (snapController.currentState != null) snapController.currentState.endDrag(pressDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: PeekAndPopController(
            normalRow(
              "Normal",
              Colors.redAccent,
            ),
            true,
            staticNormalPeekAndPopBuilder,
            false,
            sigma: 5,
            onPushPeekAndPop: onPushPeekAndPop,
            peekScale: 0.9,
          ),
        ),
        Expanded(
          child: PeekAndPopController(
            normalRow(
              "Moveable",
              Colors.deepPurpleAccent,
            ),
            true,
            moveableNormalPeekAndPopBuilder,
            false,
            overlayBuiler: PopUp(popUp),
            sigma: 5,
            willUpdatePeekAndPop: willUpdatePeekAndPop,
            willCancelPeekAndPop: willCancelPeekAndPop,
            willFinishPeekAndPop: willFinishPeekAndPop,
            onPushPeekAndPop: onPushPeekAndPop,
            onPressStart: onPressStart,
            onPressUpdate: onPressUpdate,
            onPressEnd: onPressEnd,
            peekScale: 0.9,
          ),
        ),
        Expanded(
          child: PeekAndPopController(
            normalRow(
              "Platform View",
              Colors.cyan,
            ),
            true,
            platformViewPeekAndPopBuilder,
            false,
            sigma: 5,
            onPushPeekAndPop: onPushPeekAndPop,
            peekScale: 0.7,
            peekCoefficient: 0.025,
          ),
        ),
        Expanded(
          child: PeekAndPopController(
            heroRow(),
            true,
            heroPeekAndPopBuilder,
            false,
            sigma: 5,
            onPushPeekAndPop: onPushPeekAndPop,
            useIndicator: true,
            isHero: true,
            peekScale: 0.8,
          ),
        ),
      ],
    );
  }
}

void onMove(Offset offset) {
  if (popUp.currentState == null) return;

  if (offset.dy < -125 &&
      popUp.currentState.animationController.status != AnimationStatus.forward &&
      popUp.currentState.animationController.status != AnimationStatus.completed &&
      popUp.currentState.animationController.value != 1) {
    popUp.currentState.animationController.forward();
  } else if (offset.dy > -125 &&
      popUp.currentState.animationController.status != AnimationStatus.reverse &&
      popUp.currentState.animationController.status != AnimationStatus.dismissed &&
      popUp.currentState.animationController.value != 0) {
    popUp.currentState.animationController.reverse();
  }
}

void onSnap(Offset offset) {
  if (!snapController.currentState.isMoved(25)) {
    peekAndPopController.cancelPeekAndPop(null);
  }
}

Widget normalRow(String text, Color color) {
  return Container(
    color: Colors.transparent,
    child: Padding(
      padding: EdgeInsets.all(25),
      child: Container(
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
          ),
        ),
      ),
    ),
  );
}

Widget staticNormalPeekAndPopBuilder(BuildContext context, PeekAndPopControllerState _peekAndPopController) {
  return ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(!_peekAndPopController.isComplete ? 10 : 0)),
    child: Scaffold(
      key: scaffold,
      backgroundColor: _peekAndPopController.stage != Stage.Done ? Colors.transparent : Colors.white,
      appBar: MyNavBar.CupertinoNavigationBar(
        key: header,
        backgroundColor: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xff1B1B1B),
        border: Border(
          bottom: BorderSide(
            color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : Colors.black,
            width: 0.0,
            style: BorderStyle.solid,
          ),
        ),
        middle: Text(
          "Peek & Pop",
          style: TextStyle(color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xffFF9500)),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.only(bottom: 2),
          onPressed: () {
            HapticFeedback.mediumImpact();
            _peekAndPopController.closePeekAndPop();
          },
          child: Icon(
            CupertinoIcons.left_chevron,
            size: 25,
            color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xffFF9500),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.only(bottom: 2),
          onPressed: () {
            HapticFeedback.mediumImpact();
            showSnackbar();
          },
          child: Icon(
            CupertinoIcons.heart_solid,
            size: 25,
            color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xffFF9500),
          ),
        ),
      ),
      body: Transform.translate(
        offset: Offset(0, _peekAndPopController.peekAndPopChild.getHeaderOffset(HeaderOffset.NegativeHalf)),
        child: _peekAndPopController.stage != Stage.Done ? normalAtPeek() : normalAtPop(),
      ),
    ),
  );
}

Widget moveableNormalPeekAndPopBuilder(BuildContext context, PeekAndPopControllerState _peekAndPopController) {
  return ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(!_peekAndPopController.isComplete ? 10 : 0)),
    child: Scaffold(
      key: scaffold,
      backgroundColor: _peekAndPopController.stage != Stage.Done ? Colors.transparent : Colors.white,
      appBar: MyNavBar.CupertinoNavigationBar(
        key: header,
        backgroundColor: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xff1B1B1B),
        border: Border(
          bottom: BorderSide(
            color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : Colors.black,
            width: 0.0,
            style: BorderStyle.solid,
          ),
        ),
        middle: Text(
          "Peek & Pop",
          style: TextStyle(color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xffFF9500)),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.only(bottom: 2),
          onPressed: () {
            HapticFeedback.mediumImpact();
            _peekAndPopController.closePeekAndPop();
          },
          child: Icon(
            CupertinoIcons.left_chevron,
            size: 25,
            color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xffFF9500),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.only(bottom: 2),
          onPressed: () {
            HapticFeedback.mediumImpact();
            showSnackbar();
          },
          child: Icon(
            CupertinoIcons.heart_solid,
            size: 25,
            color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xffFF9500),
          ),
        ),
      ),
      body: Transform.translate(
        offset: Offset(0, _peekAndPopController.peekAndPopChild.getHeaderOffset(HeaderOffset.NegativeHalf)),
        child: _peekAndPopController.stage != Stage.Done ? moveableAtPeek() : moveableAtPop(),
      ),
    ),
  );
}

Widget moveableAtPeek() {
  return Container(
    key: bound,
    constraints: BoxConstraints.expand(),
    color: Colors.transparent,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SnapController(
          normalAtPeek(),
          true,
          view,
          bound,
          const Offset(0.0, 0.0),
          const Offset(1.0, 1.0),
          const Offset(0.0, 0.75),
          const Offset(0.0, 0.75),
          snapTargets: [
            const SnapTarget(Pivot.topLeft, Pivot.topLeft),
            const SnapTarget(Pivot.topRight, Pivot.topRight),
            const SnapTarget(Pivot.center, Pivot.center),
          ],
          animateSnap: true,
          useFlick: false,
          onMove: onMove,
          onSnap: onSnap,
          key: snapController,
        ),
      ],
    ),
  );
}

Widget moveableAtPop() {
  return normalAtPop();
}

class PopUp extends StatefulWidget {
  PopUp(Key key) : super(key: key);

  @override
  PopUpState createState() {
    return PopUpState();
  }
}

class PopUpState extends State<PopUp> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;
  double screenHeight = -1;

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
  Widget build(BuildContext context) {
    if (screenHeight == -1) {
      screenHeight = MediaQuery.of(context).size.height;
      animation = Tween(begin: screenHeight, end: screenHeight - 240).animate(CurvedAnimation(parent: animationController, curve: Curves.decelerate));
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget cachedChild) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
              child: Container(
                height: 200,
                color: Colors.transparent,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            animationController.reverse();
                            Future.wait([snapController.currentState.move(const Offset(1, 1))]).then((_) {
                              peekAndPopController.finishPeekAndPop(null);
                            });
                          },
                          child: Container(
                            color: Color.fromARGB(189, 255, 255, 255),
                            child: Center(
                              child: Text(
                                "Pop",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            animationController.reverse();
                            Future.wait([snapController.currentState.move(Offset(1, 1))]).then((_) {
                              peekAndPopController.cancelPeekAndPop(null);
                            });
                          },
                          child: Container(
                            color: Color.fromARGB(189, 189, 189, 189),
                            child: Center(
                              child: Text(
                                "Dismiss",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget normalAtPeek() {
  return Transform.scale(
    key: view,
    scale: 0.9,
    child: Center(
      child: Container(
        constraints: const BoxConstraints.expand(height: 400),
        decoration: const BoxDecoration(
          image: const DecorationImage(
            image: const AssetImage("assets/Scenery.jpeg"),
            fit: BoxFit.cover,
          ),
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(0, 15),
              spreadRadius: -5,
              blurRadius: 20,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget normalAtPop() {
  return Center(
    child: Container(
      constraints: const BoxConstraints.expand(height: 400),
      decoration: const BoxDecoration(
        image: const DecorationImage(
          image: const AssetImage("assets/Scenery.jpeg"),
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

Widget platformViewPeekAndPopBuilder(BuildContext context, PeekAndPopControllerState _peekAndPopController) {
  return ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(!_peekAndPopController.isComplete ? 10 : 0)),
    child: Container(
      decoration: const BoxDecoration(
        boxShadow: [
          const BoxShadow(
            color: Colors.black,
            offset: const Offset(0, 15),
            spreadRadius: -5,
            blurRadius: 30,
          ),
        ],
      ),
      child: Scaffold(
        key: scaffold,
        backgroundColor: Colors.white,
        appBar: MyNavBar.CupertinoNavigationBar(
          key: header,
          backgroundColor: const Color(0xff1B1B1B),
          border: Border(
            bottom: BorderSide(
              color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : Colors.black,
              width: 0.0,
              style: BorderStyle.solid,
            ),
          ),
          middle: Text(
            "Peek & Pop",
            style: const TextStyle(color: const Color(0xffFF9500)),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.only(bottom: 2),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _peekAndPopController.closePeekAndPop();
            },
            child: Icon(
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
            child: Icon(
              CupertinoIcons.heart_solid,
              size: 25,
              color: const Color(0xffFF9500),
            ),
          ),
        ),
        body: _peekAndPopController.peekAndPopChild.animationController.status == AnimationStatus.completed ||
                _peekAndPopController.peekAndPopChild.animationController.status == AnimationStatus.reverse
            ? platformViewPeekAndPop()
            : Container(
                color: Colors.white,
                child: const Center(child: CupertinoActivityIndicator()),
              ),
      ),
    ),
  );
}

Widget platformViewPeekAndPop() {
  return InAppBrowser("https://flutter.dev");
}

class InAppBrowser extends StatefulWidget {
  final String url;

  InAppBrowser(this.url);

  @override
  InAppBrowserState createState() => InAppBrowserState();
}

class InAppBrowserState extends State<InAppBrowser> {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (NavigationRequest request) => NavigationDecision.navigate,
      onPageFinished: (String url) {},
    );
  }
}

Widget heroRow() {
  return Container(
    color: Colors.transparent,
    child: Padding(
      padding: EdgeInsets.all(25),
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: const BoxDecoration(
          color: Colors.greenAccent,
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Hero",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(50),
                child: Hero(
                  tag: "Superhero",
                  child: Image.asset("assets/Hero.png"),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget heroPeekAndPopBuilder(BuildContext context, PeekAndPopControllerState _peekAndPopController) {
  return ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(!_peekAndPopController.isComplete ? 10 : 0)),
    child: Scaffold(
      key: scaffold,
      backgroundColor: _peekAndPopController.stage != Stage.Done ? Colors.transparent : Colors.white,
      appBar: MyNavBar.CupertinoNavigationBar(
        key: header,
        backgroundColor: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xff1B1B1B),
        border: Border(
          bottom: BorderSide(
            color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : Colors.black,
            width: 0.0,
            style: BorderStyle.solid,
          ),
        ),
        middle: Text(
          "Peek & Pop",
          style: TextStyle(color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xffFF9500)),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.only(bottom: 2),
          onPressed: () {
            HapticFeedback.mediumImpact();
            _peekAndPopController.closePeekAndPop();
          },
          child: Icon(
            CupertinoIcons.left_chevron,
            size: 25,
            color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xffFF9500),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.only(bottom: 2),
          onPressed: () {
            HapticFeedback.mediumImpact();
            showSnackbar();
          },
          child: Icon(
            CupertinoIcons.heart_solid,
            size: 25,
            color: _peekAndPopController.stage != Stage.Done ? Colors.transparent : const Color(0xffFF9500),
          ),
        ),
      ),
      body: Transform.translate(
        offset: Offset(0, _peekAndPopController.peekAndPopChild.getHeaderOffset(HeaderOffset.NegativeHalf)),
        child: heroPeekAndPop(),
      ),
    ),
  );
}

Widget heroPeekAndPop() {
  return Center(
    child: Hero(
      tag: "Superhero",
      child: Image.asset(
        "assets/Hero.png",
        scale: 0.8,
      ),
    ),
  );
}

void showSnackbar() {
  scaffold.currentState.showSnackBar(SnackBar(content: Text("Everything works as usual.")));
}