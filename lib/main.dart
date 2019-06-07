import 'package:flutter/material.dart';
import 'package:launcher_assist/launcher_assist.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

var installedApps;
var numberOfInstalledApps;
var labelList = [];
var bottomToTopPref = false;
var themeColors = [
  Colors.blue,
  Colors.orange,
  Colors.green,
  Colors.pink,
  Colors.black
];
var colorPref = 0;
var nextColorPref = 1;
//var recents = [1, 2, 3, 4, 5];
var searchField = new TextEditingController();

_readFile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bottomToTopPref = prefs.getBool('dir') != null ? prefs.getBool('dir') : false;
  colorPref = prefs.getInt('theme') != null ? prefs.getInt('theme') : 0;
  //print('read $bottomToTopPref and $colorPref');
}

_writeFile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('dir', bottomToTopPref);
  prefs.setInt('theme', colorPref);
  print('saved $bottomToTopPref and $colorPref');
}

class MyState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    final whyDoesThisNeedToBeAString = _readFile(); // check for user prefs

    LauncherAssist.getAllApps().then((_appDetails) {
      setState(() {
        installedApps = _appDetails;
        numberOfInstalledApps = _appDetails.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SelectScreen(),
    );
  }
}

class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Launcher'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        color: Colors.black12,
        child: Center(
          child: Column(
            children: <Widget>[
              Spacer(),
              Card(
                elevation: 5.0,
                child: Container(
                  margin: EdgeInsets.all(20.0),
                  child: Text(
                    'Card Launcher v0.1.0',
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 5.0,
                child: Container(
                  margin: EdgeInsets.all(20.0),
                  child: Text(
                    'Developed by Jack Paine using Flutter.\n\nUses launcher_assist plugin by hathibelagal-dev.',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Spacer(),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectScreen extends StatefulWidget {
  createState() => SelectScreenContents();
}

Future<bool> _willPopCallback() async {
  // await showDialog or Show add banners or whatever
  // then
  print('back successfuly intercepted');
  return false; // return true if the route to be popped
}

class SelectScreenContents extends State<SelectScreen> {
  var searchValue = '';

  @override
  Widget build(BuildContext context) {
    final numApps = numberOfInstalledApps -
        1; // account for the fact the launcher itself is missing from the app list
    if (installedApps != null) {
      return WillPopScope(
        onWillPop: _willPopCallback,
        child: Container(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: themeColors[colorPref],
              title: Text('$numApps apps found'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.brightness_1),
                  color: themeColors[nextColorPref],
                  onPressed: () {
                    setState(() {
                      if (colorPref == 0) {
                        // there's a better way of doing this but i cba rn
                        colorPref = 1;
                        nextColorPref = 2;
                      } else if (colorPref == 1) {
                        colorPref = 2;
                        nextColorPref = 3;
                      } else if (colorPref == 2) {
                        colorPref = 3;
                        nextColorPref = 4;
                      } else if (colorPref == 3) {
                        colorPref = 4;
                        nextColorPref = 0;
                      } else if (colorPref == 4) {
                        colorPref = 0;
                        nextColorPref = 1;
                      }
                    });

                    var whyDoesThisNeedToBeAString =
                        _writeFile(); // save user prefs locally for next launch
                  },
                ),
                IconButton(
                  icon: bottomToTopPref
                      ? Icon(Icons.arrow_downward)
                      : Icon(Icons.arrow_upward),
                  onPressed: () {
                    setState(() {
                      bottomToTopPref = !bottomToTopPref; // toggle value
                    });

                    var whyDoesThisNeedToBeAString =
                        _writeFile(); // save user prefs locally for next launch
                  },
                ),
                IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InfoScreen()),
                    );
                  },
                ),
              ],
            ),
            body: Container(
              color: colorPref != 4 ? Colors.black12 : Colors.black,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: numberOfInstalledApps + 1,
                reverse: bottomToTopPref,
                itemBuilder: (context, i) {
                  var j = i - 1;
                  if (i == 0) {
                    return Card(
                        elevation: 10.0,
                        color: colorPref != 4 ? Colors.white : Colors.black,
                        shape: colorPref == 4
                            ? RoundedRectangleBorder(
                                side: new BorderSide(
                                    color: Colors.white, width: 2.0),
                                borderRadius: BorderRadius.circular(4.0))
                            : null,
                        margin: EdgeInsets.all(5.0),
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          child: TextField(
                              controller: searchField,
                              style: TextStyle(
                                  color: colorPref == 4
                                      ? Colors.white
                                      : null),
                              decoration: InputDecoration(
                                hintText: 'Search packages...',
                                hintStyle: TextStyle(
                                    color: colorPref == 4
                                        ? Colors.white
                                        : null),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchValue = value;
                                });
                              })));
                  }

                  /*if (i == 1) {
                    return Card(
                      // Favourites tray
                      margin: EdgeInsets.all(5.0),
                      color: colorPref != 4 ? Colors.white : Colors.black,
                      shape: colorPref == 4
                          ? RoundedRectangleBorder(
                              side:
                                  new BorderSide(color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(4.0))
                          : null,
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: recents.length > 0
                            ? Row(
                                children: <Widget>[
                                  //ListView(
                                    //children: <Widget>[
                                      recents.length <= 1 ?
                                        FlatButton(
                                          child: Image.memory(
                                              installedApps[recents[0]]['icon'],
                                              fit: BoxFit.scaleDown,
                                              width: 42.0,
                                              height: 42.0),
                                          onPressed: () {
                                            LauncherAssist.launchApp(
                                                installedApps[recents[0]]
                                                    ['package']);
                                          }
                                        )
                                      : null,
                                      recents.length <= 2 ?
                                        FlatButton(
                                          child: Image.memory(
                                              installedApps[recents[1]]['icon'],
                                              fit: BoxFit.scaleDown,
                                              width: 42.0,
                                              height: 42.0),
                                          onPressed: () {
                                            LauncherAssist.launchApp(
                                                installedApps[recents[1]]
                                                    ['package']);
                                          }
                                        )
                                      : null,
                                    //],
                                  //),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.backspace),
                                    color: Colors.grey,
                                    onPressed: () {
                                      setState(() {
                                        recents = [];
                                      });
                                    },
                                  ),
                                ],
                              )
                            : Center(
                                child: Text(
                                  'Your recently opened apps will show here.',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: colorPref != 4
                                        ? themeColors[colorPref]
                                        : Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    );
                  }
                  */

                  if (j >= 0) {
                    if ((installedApps[j]['package']
                                .toLowerCase()
                                .contains(searchValue.toLowerCase()) ||
                            installedApps[j]['label']
                                .toLowerCase()
                                .contains(searchValue.toLowerCase())) &&
                        installedApps[j][
                                    'package'] // don't display the launcher in the list of apps to choose
                                .toLowerCase()
                                .contains('jckpn.cardlauncher') ==
                            false) {
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title:
                                    new Text("Long press options coming soon!"),
                                content: new Text(
                                    "For now you'll have to manually find the app in your settings."),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text("Close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          elevation: 5.0,
                          shape: colorPref == 4
                              ? RoundedRectangleBorder(
                                  side: new BorderSide(
                                      color: Colors.white, width: 2.0),
                                  borderRadius: BorderRadius.circular(4.0))
                              : null,
                          margin: EdgeInsets.all(5.0),
                          color:
                              colorPref != 4 ? Colors.grey[100] : Colors.black,
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              children: <Widget>[
                                FlatButton(
                                    padding: EdgeInsets.all(0.0),
                                    child: Row(
                                      children: <Widget>[
                                        Card(
                                            elevation: 3.0,
                                            child: Container(
                                                padding: EdgeInsets.all(5.0),
                                                child: Image.memory(
                                                    installedApps[j]['icon'],
                                                    fit: BoxFit.scaleDown,
                                                    width: 48.0,
                                                    height: 48.0))),
                                        Container(
                                          margin: EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    115),
                                                child: MarqueeWidget(
                                                  direction: Axis.horizontal,
                                                  child: Text(
                                                    installedApps[j]['label'],
                                                    style: TextStyle(
                                                      fontSize: 20.0,
                                                      color: colorPref != 4
                                                          ? themeColors[
                                                              colorPref]
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    115),
                                                child: MarqueeWidget(
                                                  direction: Axis.horizontal,
                                                  child: Text(
                                                    installedApps[j]['package'],
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      color: colorPref != 4
                                                          ? themeColors[
                                                              colorPref]
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    onPressed: () {
                                      /*setState(() {
                                        recents.insert(0,
                                            j); // put this app at front of recents
                                      });*/

                                      LauncherAssist.launchApp(
                                          installedApps[j]['package']);
                                    }),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }
                },
              ),
            ),
          ),
        ),
      );
    } else {
      return Center();
    }
  }
}

// Marquee text widget made by 01leo on StackOverflow
// https://stackoverflow.com/questions/51772543/how-to-make-a-text-widget-act-like-marquee-when-the-text-overflows-in-flutter/51776987
// I did not write any of the following code!

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration, backDuration, pauseDuration;

  MarqueeWidget({
    @required this.child,
    this.direction: Axis.horizontal,
    this.animationDuration: const Duration(milliseconds: 3000),
    this.backDuration: const Duration(milliseconds: 800),
    this.pauseDuration: const Duration(milliseconds: 800),
  });

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scroll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: widget.child,
      scrollDirection: widget.direction,
      controller: scrollController,
    );
  }

  void scroll() async {
    while (true) {
      await Future.delayed(widget.pauseDuration);
      await scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: widget.animationDuration,
          curve: Curves.easeIn);
      await Future.delayed(widget.pauseDuration);
      await scrollController.animateTo(0.0,
          duration: widget.backDuration, curve: Curves.easeOut);
    }
  }
}
