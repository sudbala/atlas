import 'package:atlas/screens/ExploreScreen.dart';
import 'package:atlas/screens/Feed.dart';
import 'package:atlas/screens/MainMap.dart';
import 'package:atlas/screens/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'AtlasMap.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String id = currentUser.uid;

class MainScreen extends StatefulWidget {
  /// Location Variables

  /// Instance vars for the MapBox map

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions;
  Position pos;

  Future<void> _getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    print("called");

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location service are disabled.');
    }

    /// Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions');
    }

    /// Check if just denied for now and request permissions
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            ('Location permissions are denied (actual value: $permission).'));
      }
    }

    /// Return position if we got here past all checks and requests
    await Geolocator.getCurrentPosition().then((value) => pos = value);
  }

  @override
  void initState() {
    _widgetOptions = <Widget>[
      Feed(),
      FutureBuilder(
        future: _getPosition(),
        builder: (context, snapshot) {
          return AtlasMap(
            currentPosition: pos,
          );
        },
      ),
      ExploreScreen(),
      ProfileScreen(id),
    ];
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomBarHeight = MediaQuery.of(context).size.height / 15;
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: SizedBox(
        height: bottomBarHeight,
        child: BottomNavigationBar(
          // Must set to fixed here if you don't want icons moving. I dont think we want icons moving
          type: BottomNavigationBarType.fixed,

          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SizedBox(height: 0, child: Icon(Icons.home)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(height: 0, child: Icon(Icons.map)),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(height: 0, child: Icon(Icons.explore_rounded)),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(height: 0, child: Icon(Icons.person)),
              label: 'Profile',
            )
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.cyan[700],
          unselectedItemColor: Colors.grey[500],
          //unselectedItemColor: Colors.green[200],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

//import 'package:flutter/material.dart';
//import 'package:mapbox_gl_example/full_map.dart';
//
//import 'animate_camera.dart';
//import 'full_map.dart';
//import 'line.dart';
//import 'map_ui.dart';
//import 'move_camera.dart';
//import 'page.dart';
//import 'place_circle.dart';
//import 'place_source.dart';
//import 'place_symbol.dart';
//import 'place_fill.dart';
//import 'scrolling_map.dart';
//
//final List<ExamplePage> _allPages = <ExamplePage>[
//  MapUiPage(),
//  FullMapPage(),
//  AnimateCameraPage(),
//  MoveCameraPage(),
//  PlaceSymbolPage(),
//  PlaceSourcePage(),
//  LinePage(),
//  PlaceCirclePage(),
//  PlaceFillPage(),
//  ScrollingMapPage(),
//];
//
//class MapsDemo extends StatelessWidget {
//
//  //FIXME: Add your Mapbox access token here
//  static const String ACCESS_TOKEN = "pk.eyJ1IjoidG9icnVuIiwiYSI6ImNrMnQ0MThpMjEzd3gzZHA3cjQ4YXNsYnMifQ.I-RxwxYFak7V6ezMtOOQTA";
//
//  void _pushPage(BuildContext context, ExamplePage page) async {
//    if (!kIsWeb) {
//      final location = Location();
//      final hasPermissions = await location.hasPermission();
//      if (hasPermissions != PermissionStatus.GRANTED) {
//        await location.requestPermission();
//      }
//    }
//    Navigator.of(context).push(MaterialPageRoute<void>(
//        builder: (_) => Scaffold(
//          appBar: AppBar(title: Text(page.title)),
//          body: page,
//        )));
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(title: const Text('MapboxMaps examples')),
//      body: ListView.builder(
//        itemCount: _allPages.length,
//        itemBuilder: (_, int index) => ListTile(
//          leading: _allPages[index].leading,
//          title: Text(_allPages[index].title),
//          onTap: () => _pushPage(context, _allPages[index]),
//        ),
//      ),
//    );
//  }
//}

//class MainScreen extends StatefulWidget {
//  MainScreen({Key key, this.title}) : super(key: key);
//
//  // This widget is the home page of your application. It is stateful, meaning
//  // that it has a State object (defined below) that contains fields that affect
//  // how it looks.
//
//  // This class is the configuration for the state. It holds the values (in this
//  // case the title) provided by the parent (in this case the App widget) and
//  // used by the build method of the State. Fields in a Widget subclass are
//  // always marked "final".
//
//  final String title;
//
//  @override
//  _MainScreenState createState() => _MainScreenState();
//}
//
//class _MainScreenState extends State<MainScreen> {
//  int _counter = 0;
//
//  void _incrementCounter() {
//    setState(() {
//      // This call to setState tells the Flutter framework that something has
//      // changed in this State, which causes it to rerun the build method below
//      // so that the display can reflect the updated values. If we changed
//      // _counter without calling setState(), then the build method would not be
//      // called again, and so nothing would appear to happen.
//      _counter++;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // This method is rerun every time setState is called, for instance as done
//    // by the _incrementCounter method above.
//    //
//    // The Flutter framework has been optimized to make rerunning build methods
//    // fast, so that you can just rebuild anything that needs updating rather
//    // than having to individually change instances of widgets.
//    return Scaffold(
//      appBar: AppBar(
//        // Here we take the value from the MyHomePage object that was created by
//        // the App.build method, and use it to set our appbar title.
//        title: Text(widget.title),
//      ),
//      body: Center(
//        // Center is a layout widget. It takes a single child and positions it
//        // in the middle of the parent.
//        child: Column(
//          // Column is also a layout widget. It takes a list of children and
//          // arranges them vertically. By default, it sizes itself to fit its
//          // children horizontally, and tries to be as tall as its parent.
//          //
//          // Invoke "debug painting" (press "p" in the console, choose the
//          // "Toggle Debug Paint" action from the Flutter Inspector in Android
//          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//          // to see the wireframe for each widget.
//          //
//          // Column has various properties to control how it sizes itself and
//          // how it positions its children. Here we use mainAxisAlignment to
//          // center the children vertically; the main axis here is the vertical
//          // axis because Columns are vertical (the cross axis would be
//          // horizontal).
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text(
//              'You have pushed the button this many times:',
//            ),
//            Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.headline4,
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
//    );
//  }
//}
