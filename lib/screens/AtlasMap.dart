import 'package:atlas/screens/LocationScreen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

// We will have an example list of spots that we will add as symbols
// In the future I think it would be really cool if using our indexing system of spots, the map would load all spots that
// are in the viewers map plus spots a bit outside what the viewer can see and then as the user scrolls they are loaded. This way we don't have to load all spots at once!
final List<List> spots = [
  [LatLng(37.928942, -122.577107), 'embassy-15'],
  [LatLng(37.921621, -122.584711), 'waterfall-15'],
  [LatLng(37.919886, -122.571459), 'castle-15']
];

/// This is the map that will be shown when a user clicks on the map tab.

class AtlasMap extends StatefulWidget {
  Position currentPosition;
  AtlasMap({this.currentPosition});

  //Instance vars for the MapBox map

  static const String ACCESS_TOKEN =
      //'pk.eyJ1Ijoic3Vkb3dvb2RvIiwiYSI6ImNraWc4bjZraDA4aHAyeG9pNnJpM2kzdmMifQ'
      //'.97alUuajzxtaLCkz2ura4g';
      'pk.eyJ1IjoiamFtZXNmbGVtaW5nYXRsYXMiLCJhIjoiY2tpamtuaWxxMDB1YjJ5bnhkcGJqN3B4aiJ9.VyziFfphnXZJG0awtLjefQ';

  static const String STYLE =
      'mapbox://styles/jamesflemingatlas/ckiuo5rsv1jzb19k6dwpw6ngk';

  @override
  _AtlasMapState createState() => _AtlasMapState();
}

class _AtlasMapState extends State<AtlasMap> {
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
    /// We want to return a Future builder of the map because we want to obtain
    /// position before we display map.

    return Scaffold(
      body: MapboxMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(widget.currentPosition.latitude,
                widget.currentPosition.longitude),
            zoom: 15),
        accessToken: AtlasMap.ACCESS_TOKEN,
        styleString: AtlasMap.STYLE,
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
