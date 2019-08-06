//@formatter:off
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'nav_bar.dart' as MyNavBar;
import 'package:peek_and_pop/peek_and_pop.dart';

PeekAndPopControllerState peekAndPopController;
GlobalKey<ScaffoldState> scaffold = GlobalKey<ScaffoldState>();
GlobalKey<PopUpState> popUp = GlobalKey<PopUpState>();
double screenHeight;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
			      title: 'Peek & Pop Demo',
			      theme: ThemeData(primarySwatch: Colors.blue,),
			      home: MyHomePage(title: 'Peek & Pop Demo'));
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
    return Scaffold(
		        appBar: AppBar(title: Text(widget.title)),
		        body: Body());
  }
}

class Body extends StatelessWidget{
	void setPeekAndPop(PeekAndPopControllerState _peekAndPopController){
		peekAndPopController=_peekAndPopController;
	}
	
	void move(Offset offset){
		if(peekAndPopController == null) return;
		if(popUp.currentState == null) return;
		
		if (offset.dy < -150 && popUp.currentState.animationController.status!=AnimationStatus.forward && popUp.currentState.animationController.status!=AnimationStatus.completed && popUp.currentState.animationController.value!=1){
			popUp.currentState.animationController.forward();
		}
		else if(offset.dy > -150 && popUp.currentState.animationController.status!=AnimationStatus.reverse && popUp.currentState.animationController.status!=AnimationStatus.dismissed && popUp.currentState.animationController.value!=0){
			popUp.currentState.animationController.reverse();
		}
	}
	
  @override
  Widget build(BuildContext context) {
  	return Column(
				    mainAxisAlignment: MainAxisAlignment.center,
				    crossAxisAlignment: CrossAxisAlignment.center,
				    children: [
				      Expanded(child:PeekAndPopController(
													    normalRow(
														    "Normal", 
														    Colors.redAccent),
													    normalPeekAndPopBuilder,
													    false,
													    onPushPeekAndPop: setPeekAndPop,
													    peekScale: 0.9)),
					    Expanded(child:PeekAndPopController(
													    normalRow(
														    "Moveable", 
														    Colors.deepPurpleAccent),
													    normalPeekAndPopBuilder,
													    false,
													    overlayBuiler: PopUp(popUp),
													    onPushPeekAndPop: setPeekAndPop,
													    peekScale: 0.9,
													    moveController: MoveController(
																						    Offset(0,-150),
																						    Offset(0, 150),
														                    Offset(0.0, 0.75),
														                    Offset(0.0, 0.75),
														                    clipTargets: [
														                    	Offset(0, -150)
														                    ],
														                    callback: move))),
					    Expanded(child:PeekAndPopController(
													    normalRow(
														    "Platform View", 
														    Colors.cyan),
													    platformViewPeekAndPopBuilder,
													    true,
													    onPushPeekAndPop: setPeekAndPop,
													    peekScale: 0.7,
													    peekCoefficient: 0.025)),
					    Expanded(child:PeekAndPopController(
													    heroRow(),
													    heroPeekAndPopBuilder,
													    false,
													    onPushPeekAndPop: setPeekAndPop,
													    isHero: true,
													    peekScale: 0.8))
				    ]);
  }
}

class PopUp extends StatefulWidget {
	PopUp(Key key):super(key:key);
	
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
    animationController = 
      AnimationController(
        vsync: this, 
        duration: const Duration(milliseconds: 333), 
        lowerBound: 0, 
        upperBound: 1);
  }


  @override
  Widget build(BuildContext context) {
  	if(screenHeight == -1){
	    screenHeight = MediaQuery.of(context).size.height;
	    animation = 
	      Tween(
	        begin: screenHeight, 
	        end: screenHeight-240)
	      .animate(CurvedAnimation(
	                parent: animationController, 
	                curve: Curves.decelerate));
  	}
    return AnimatedBuilder(
		        animation: animation,
		        builder: 
			      (BuildContext context, Widget cachedChild) {
		          return (Transform.translate(
									            offset: Offset(0,animation.value),
								              child: Padding(
									                      padding: EdgeInsets.all(20),
										                    child:ClipRRect(
																								borderRadius: const BorderRadius.all(const Radius.circular(40.0)),
																								child: Container(
																												height: 200,
																												color: Colors.transparent,
																												child: Column(
																																mainAxisAlignment: MainAxisAlignment.center,
																																crossAxisAlignment: CrossAxisAlignment.center,
																																children: [
																																	Expanded(child:GestureDetector(
																																									onTap: () => peekAndPopController.finishPeekAndPop(null, ignoreMoveOffset: true),
																																									child: Container(
																																																color: Color.fromARGB(126, 255,255,255),
																																													      child: Center(child:Text(
																																																								      "Pop!",
																																																								      style: TextStyle(
																																																												      color: Colors.black, 
																																																												      fontSize: 25)))))),
																																	Expanded(child:GestureDetector(
																																									onTap: () => peekAndPopController.cancelPeekAndPop(null, ignoreMoveOffset: true),
																																									child: Container(
																																																color: Color.fromARGB(126, 0,0,0),
																																													      child: Center(child:Text(
																																																								      "Dismiss",
																																																								      style: TextStyle(
																																																										          decoration: null,
																																																												      color: Colors.black, 
																																																												      fontSize: 25))))))
																																	]))))));
		        }
          );
  }
}

Widget normalRow(String text, Color color){
	return Container(
					color: Colors.transparent, 
					child: Padding(
									padding: EdgeInsets.all(25), 
									child: Container(
										      constraints: BoxConstraints.expand(),
											    decoration: BoxDecoration(
																	      color: color,
																		    borderRadius: const BorderRadius.all(const Radius.circular(10.0))),
										      child: Center(child:Text(
																					      text,
																					      style: TextStyle(
																									      color: Colors.white, 
																									      fontWeight: FontWeight.bold, 
																									      fontSize: 25))))));
}

Widget normalPeekAndPopBuilder(BuildContext context, PeekAndPopControllerState _peekAndPopController){
	return ClipRRect(
					borderRadius: BorderRadius.all(Radius.circular(!_peekAndPopController.isComplete
					                                               ? 10
					                                               : 0)),
					child: Scaffold(
									key: scaffold,
									backgroundColor: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete
									                 ? Colors.transparent
									                 : Colors.white, 
									appBar: MyNavBar.CupertinoNavigationBar(
														key: header,
														backgroundColor: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete
														                 ? Colors.transparent
														                 : const Color(0xff1B1B1B),
														middle: Text(
																			"Peek & Pop",
																			style: TextStyle(color: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete 
																			                        ? Colors.transparent 
																			                        : const Color(0xffFF9500))),
														leading: CupertinoButton(
																			padding: EdgeInsets.only(bottom: 2), 
																			onPressed: () {
																				HapticFeedback.mediumImpact();
																				_peekAndPopController.closePeekAndPop();
																			}, 
																			child: Icon(
																							CupertinoIcons.left_chevron, 
																							size: 25, 
																							color: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete
																							       ? Colors.transparent
																							       : const Color(0xffFF9500))),
														trailing: CupertinoButton(
																				padding: EdgeInsets.only(bottom: 2), 
																				onPressed: () {
																					HapticFeedback.mediumImpact();
																					showSnackbar();
																				}, 
																				child: Icon(
																								CupertinoIcons.heart_solid, 
																								size: 25, 
																								color: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete
																								       ? Colors.transparent
																								       : const Color(0xffFF9500)))), 
									body: Transform.translate(
													offset: Offset(0, _peekAndPopController.peekAndPopChild.getHeaderOffset(HeaderOffset.NegativeHalf)), 
													child: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete 
													       ? normalAtPeek() 
													       : normalAtPop())));
}

Widget normalAtPeek(){
	return Transform.scale(
			scale: 0.9,
			child: Center(child:Container(
								            constraints: const BoxConstraints.expand(height: 400),
								            decoration: BoxDecoration(
													                image: DecorationImage(
																	                image: AssetImage("assets/Scenery.jpeg"), 
																	                fit: BoxFit.cover),
													                borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
													                boxShadow: [
													                  BoxShadow(
													                    color: Colors.black,
													                    offset: Offset(0, 15),
													                    spreadRadius: -5,
													                    blurRadius: 20)
													                ]))));
}

Widget normalAtPop(){
	return Center(child:Container(
						            constraints: const BoxConstraints.expand(height: 400),
						            decoration: BoxDecoration(
											                image: DecorationImage(
															                image: AssetImage("assets/Scenery.jpeg"), 
															                fit: BoxFit.cover))));
}

Widget platformViewPeekAndPopBuilder(BuildContext context, PeekAndPopControllerState _peekAndPopController){
	return ClipRRect(
					borderRadius: BorderRadius.all(Radius.circular(!_peekAndPopController.isComplete
					                                               ? 10
					                                               : 0)),
					child: Container(
									decoration: BoxDecoration(
		                boxShadow: [
		                  BoxShadow(
		                    color: Colors.black,
		                    offset: Offset(0, 15),
		                    spreadRadius: -5,
		                    blurRadius: 30)
		                ]), 
									child:Scaffold(
													key: scaffold,
													backgroundColor:  Colors.white, 
													appBar: MyNavBar.CupertinoNavigationBar(
																		key: header,
																		backgroundColor: const Color(0xff1B1B1B),
																		middle: Text(
																				"Peek & Pop",
																				style: TextStyle(color: const Color(0xffFF9500))),
																		leading: CupertinoButton(
																							padding: EdgeInsets.only(bottom: 2), 
																							onPressed: () {
																								HapticFeedback.mediumImpact();
																								_peekAndPopController.closePeekAndPop();
																							}, 
																							child: Icon(
																											CupertinoIcons.left_chevron, 
																											size: 25, 
																											color: const Color(0xffFF9500))),
																		trailing: CupertinoButton(
																								padding: EdgeInsets.only(bottom: 2), 
																								onPressed: () {
																									HapticFeedback.mediumImpact();
																									showSnackbar();
																								}, 
																								child: Icon(
																												CupertinoIcons.heart_solid, 
																												size: 25, 
																												color: const Color(0xffFF9500)))), 
													body: Center(child: platformViewPeekAndPop()))));
}

Widget platformViewPeekAndPop(){
	return InAppBrowser("https://flutter.dev");
}

class InAppBrowser extends StatefulWidget {
	final String url;

	InAppBrowser(this.url);

	@override
	InAppBrowserState createState() =>  InAppBrowserState();
}

class InAppBrowserState extends State<InAppBrowser> {
	@override
	Widget build(BuildContext context) {
		return WebView(
						initialUrl: widget.url, 
						javascriptMode: JavascriptMode.unrestricted,
						navigationDelegate: (NavigationRequest request) => NavigationDecision.navigate,
						onPageFinished: (String url) {});
	}
}

Widget heroRow(){
	return Container(
					color: Colors.transparent, 
					child: Padding(
								    padding: EdgeInsets.all(25), 
								    child: Container(
											      constraints: BoxConstraints.expand(),
												    decoration: BoxDecoration(
																			    color: Colors.greenAccent, 
																			    borderRadius: const BorderRadius.all(const Radius.circular(10.0))),
											      child: Center(
															      child:Row(
																			      mainAxisAlignment: MainAxisAlignment.center,
																			      crossAxisAlignment: CrossAxisAlignment.center,
																			      children: [
																			        Text(
																					      "Hero",
																					      style: TextStyle(
																									      color: Colors.white, 
																									      fontWeight: FontWeight.bold, 
																									      fontSize: 25)),
																			        Padding(
																				        padding: EdgeInsets.all(50),
																				        child: Hero(
																								        tag:"Superhero", 
																								        child:Image.asset("assets/Hero.png")))
																			      ])))));
}

Widget heroPeekAndPopBuilder(BuildContext context, PeekAndPopControllerState _peekAndPopController){
	return ClipRRect(
					borderRadius: BorderRadius.all(Radius.circular(!_peekAndPopController.isComplete
					                                               ? 10
					                                               : 0)),
					child: Scaffold(
									key: scaffold,
									backgroundColor: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete
									                 ? Colors.transparent
									                 : Colors.white, 
									appBar: MyNavBar.CupertinoNavigationBar(
														key: header,
														backgroundColor: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete
														                 ? Colors.transparent
														                 : const Color(0xff1B1B1B),
														middle: Text(
																			"Peek & Pop",
																			style: TextStyle(color: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete
																                        ? Colors.transparent
																                        : const Color(0xffFF9500))),
														leading: CupertinoButton(
																			padding: EdgeInsets.only(bottom: 2), 
																			onPressed: () {
																				HapticFeedback.mediumImpact();
																				_peekAndPopController.closePeekAndPop();
																			}, 
																			child: Icon(
																							CupertinoIcons.left_chevron, 
																							size: 25, 
																							color: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete
																							       ? Colors.transparent
																							       : const Color(0xffFF9500))),
														trailing: CupertinoButton(
																				padding: EdgeInsets.only(bottom: 2), 
																				onPressed: () {
																					HapticFeedback.mediumImpact();
																					showSnackbar();
																				}, 
																				child: Icon(
																								CupertinoIcons.heart_solid, 
																								size: 25, 
																								color: !_peekAndPopController.secondaryAnimationController.isAnimating && !_peekAndPopController.isComplete
																								       ? Colors.transparent
																								       : const Color(0xffFF9500)))), 
									body: Transform.translate(
													offset: Offset(0, _peekAndPopController.peekAndPopChild.getHeaderOffset(HeaderOffset.NegativeHalf)), 
													child: heroPeekAndPop())));
}

Widget heroPeekAndPop(){
	return Center(
					child: Hero(
									tag:"Superhero", 
									child:Image.asset(
													"assets/Hero.png", 
													scale: 0.8)));
}

void showSnackbar() {
	scaffold.currentState.showSnackBar(SnackBar(content: Text("Everything works as usual.")));
}
//@formatter:on