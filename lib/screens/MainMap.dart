/*


READY TO BE DELETED
import 'package:atlas/screens/LocationScreen.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:utm/utm.dart';

// We will have an example list of spots that we will add as symbols
// In the future I think it would be really cool if using our indexing system of spots, the map would load all spots that
// are in the viewers map plus spots a bit outside what the viewer can see and then as the user scrolls they are loaded. This way we don't have to load all spots at once!



final List<List> spots = [
  [LatLng(37.928942, -122.577107), 'embassy-15'],
  [LatLng(37.921621, -122.584711), 'waterfall-15'],
  [LatLng(37.919886, -122.571459), 'castle-15']
];

class MainMap extends StatefulWidget {
  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  static const String ACCESS_TOKEN =
      //'pk.eyJ1Ijoic3Vkb3dvb2RvIiwiYSI6ImNraWc4bjZraDA4aHAyeG9pNnJpM2kzdmMifQ'
      //'.97alUuajzxtaLCkz2ura4g';
      'pk.eyJ1IjoiamFtZXNmbGVtaW5nYXRsYXMiLCJhIjoiY2tpamtuaWxxMDB1YjJ5bnhkcGJqN3B4aiJ9.VyziFfphnXZJG0awtLjefQ';

  static const String STYLE =
      'mapbox://styles/jamesflemingatlas/ckiuo5rsv1jzb19k6dwpw6ngk';
  //'mapbox://styles/sudowoodo/ckig8qtzi539p19pb08ricter';
  MapboxMapController controller;

  void _onSymbolTapped(Symbol symbol) {
    // when we tap a symbol we want to go to that locations page where we can see photos and a description of it!

    // We can grab the coordinate from the symbol that we tapped on
    String coord = symbol.options.geometry.toString();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          // Send user to LocationScreen.
          return LocationScreen(coord);
        },
      ),
    );
  }

// Not really sure what this does.
  @override
  void dispose() {
    controller?.onSymbolTapped?.remove(_onSymbolTapped);
    super.dispose();
  }

// Function returns a symbol options give a desired image and location
  SymbolOptions _getSymbolOptions(String iconImage, LatLng geometry) {
    return SymbolOptions(
      geometry: geometry,
      iconImage: iconImage,
      // Just using this to see them better
      iconSize: 2,
    );
  }

  void _onMapCreated(MapboxMapController controller) {
    // when the map is created we can add our symbols.
    this.controller = controller;

    // Add a symbol tapped callback
    controller.onSymbolTapped.add(_onSymbolTapped);

    // Go through all the spots and add each symbol
    spots.forEach((spot) {
      controller.addSymbol(_getSymbolOptions(spot[1], spot[0]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapboxMap(
        initialCameraPosition: const CameraPosition(
            target: LatLng(37.928942, -122.577107), zoom: 12),
        accessToken: ACCESS_TOKEN,
        styleString: STYLE,
        onMapCreated: _onMapCreated,
        onMapClick: (point, coordinate) {
          var utm = UTM.fromLatLon(
              lat: coordinate.latitude, lon: coordinate.longitude);
          print('zone: ${utm.zone}');
          print('N: ${utm.northing}');
          print('E: ${utm.easting}');
        },
      ),
    );
  }
}
*/
