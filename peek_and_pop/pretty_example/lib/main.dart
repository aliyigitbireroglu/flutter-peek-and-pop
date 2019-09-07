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
        title: 'Showcase',
        home: MyHomePage(title: 'Showcase'),
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
  ScrollController scrollController;
  ValueNotifier<double> scrollControllerNotifier;
  List<int> verticalImages = [2, 3, 7, 15, 17, 18, 21];

  void onScroll() {
    scrollControllerNotifier.value = scrollController.offset * 1.0;
  }

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController(initialScrollOffset: 0);
    scrollController.addListener(onScroll);
    scrollControllerNotifier = ValueNotifier<double>(0.0);
  }

  void showSnackbar() {
    scaffold.currentState.showSnackBar(SnackBar(content: const Text("Photo is saved your favourites.")));
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
        "Photo",
        style: const TextStyle(color: const Color(0xffFF9500)),
      ),
      leading: CupertinoButton(
        padding: EdgeInsets.only(bottom: 2),
        onPressed: () {
          HapticFeedback.mediumImpact();
          _peekAndPopController.closePeekAndPop();
        },
        child: const Icon(
          CupertinoIcons.clear_circled,
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
      backgroundColor: CupertinoColors.darkBackgroundGray,
      appBar: appBar(_peekAndPopController),
      body: SizedBox.expand(child: child),
    );
  }

  Widget gridPeekAndPopBuilderAtPeek(int index, BuildContext context, PeekAndPopControllerState _peekAndPopController) {
    return atPeekWrapper(
      Image.asset(
        "assets/" + index.toString() + ".jpeg",
        fit: BoxFit.contain,
        key: Key("Image"),
        scale: verticalImages.contains(index) ? 0.5 : 1.0,
      ),
      _peekAndPopController,
    );
  }

  Widget gridPeekAndPopBuilderAtPop(int index, BuildContext context, PeekAndPopControllerState _peekAndPopController) {
    return atPopWrapper(
      Transform.translate(
        offset: Offset(0, verticalImages.contains(index) ? 0.0 : -50),
        child: Image.asset(
          "assets/" + index.toString() + ".jpeg",
          fit: BoxFit.contain,
          key: Key("Image"),
        ),
      ),
      _peekAndPopController,
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
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      child: PeekAndPopMisc.scaleDownWrapper(
        CustomScrollView(
          controller: scrollController,
          slivers: [
            MyNavBar.CupertinoSliverNavigationBar(
              largeTitle: Text(
                widget.title,
                style: const TextStyle(color: const Color(0xffFF9500)),
              ),
              backgroundColor: const Color(0xff1B1B1B),
              border: const Border(
                bottom: const BorderSide(
                  color: Colors.black,
                  width: 0.0,
                  style: BorderStyle.solid,
                ),
              ),
              transitionBetweenRoutes: false,
            ),
            SliverPadding(
              padding: EdgeInsets.all(10),
              sliver: SliverGrid.count(
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                crossAxisCount: 3,
                children: List.generate(30, (int index) {
                  return PeekAndPopController(
                    ValueListenableBuilder(
                      builder: (BuildContext context, double scrollController, Widget cachedChild) {
                        double height = MediaQuery.of(context).size.width / 3.0;
                        double position = index % 3 * height;
                        double alignment = ((scrollController - position) / (position + height)).clamp(-1.0, 1.0);

                        return Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                "assets/" + index.toString() + ".jpeg",
                              ),
                              alignment: Alignment(alignment, alignment),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                          ),
                        );
                      },
                      valueListenable: scrollControllerNotifier,
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
                    peekScale: 0.95,
                    peekCoefficient: 0.025,
                  );
                }),
              ),
            )
          ],
        ),
        0.04,
      ),
    );
  }
}
