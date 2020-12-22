import 'package:atlas/screens/LocationScreen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utm/utm.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

// We will have an example list of spots that we will add as symbols
// In the future I think it would be really cool if using our indexing system of spots, the map would load all spots that
// are in the viewers map plus spots a bit outside what the viewer can see and then as the user scrolls they are loaded. This way we don't have to load all spots at once!
final List<List> spots = [
  [LatLng(37.928942, -122.577107), 'embassy-15'],
  [LatLng(37.921621, -122.584711), 'waterfall-15'],
  [LatLng(37.919886, -122.571459), 'castle-15']
];

final Map<String, String> genreToSymbol = {
  "Viewpoint": "attraction-15",
  "Campsite": "campsite-15",
  "Skate Spot": "skateboard-15",
};

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

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          // Send user to LocationScreen.
          return LocationScreen(symbol.data);
        },
      ),
    );
  }

  // Function returns a symbol options give a desired image and location
  SymbolOptions _getSymbolOptions(
      String iconImage, LatLng geometry, bool explored) {
    return SymbolOptions(
      geometry: geometry,
      iconImage: iconImage,
      // Just using this to see them better
      iconSize: 1.5,
    );
    //textOpacity: 0);
  }

// Loads symbols for all the spots in a given zone.
  void loadSymbolsOfZone(String zone) async {
    String zoneLetter = zone.substring(2);

    int zoneNumber = int.parse(zone.substring(0, 2));

    CollectionReference areas = FirebaseFirestore.instance
        .collection("Users")
        .doc(myId)
        .collection("visibleZones")
        .doc(zone)
        .collection("Area");

    QuerySnapshot areaSnaps = await areas.get();

    // go through every area in this zone
    areaSnaps.docs.forEach((areaDoc) async {
      QuerySnapshot spotSnaps =
          await areas.doc(areaDoc.id).collection("Spots").get();

      // go through every spot in this area.
      spotSnaps.docs.forEach((spotDoc) {
        var data = spotDoc.data();
        // Turn the information we have into a utm which will give us the coordinates.
        var utm = UTM.fromUtm(
            easting: double.parse(data["Easting"]),
            northing: double.parse(data["Northing"]),
            zoneNumber: zoneNumber,
            zoneLetter: zoneLetter);

        LatLng coords = LatLng(utm.lat, utm.lon);
        bool haveVisited = data["havePersonallyExplored"];
        data["zone"] = zone;
        // add a symbol.
        String symbol = genreToSymbol["${data["Genre"]}"];
        symbol ??= 'castle-15';
        controller.addSymbol(
            _getSymbolOptions(
              symbol,
              coords,
              haveVisited,
            ),
            // Go ahead and just send al the data!
            data = data);
      });
    });
  }

  void _onMapCreated(MapboxMapController controller) async {
    // when the map is created we can add our symbols.
    this.controller = controller;

    // Add a symbol tapped callback
    controller.onSymbolTapped.add(_onSymbolTapped);

    //LatLngBounds bounds = await controller.getVisibleRegion();
    //bounds.northeast.

    // This listener will be called when the user moves or zooms the camera
    controller.addListener(() {
      //print(
      // "userMoving camera. Camera bounds are ${controller.getVisibleRegion().toString()})}");
    });

    // Go through all zones and add each symbol... I think in the future we will only add spots that are in the zones of the users visible region.. Not really sure

    CollectionReference zones = FirebaseFirestore.instance
        .collection("Users")
        .doc(myId)
        .collection("visibleZones");

    QuerySnapshot allZones = await zones.get();
    allZones.docs.forEach((doc) {
      // call loadSymbolsOfZone to load all the symbols of the zone which is just the docId!

      loadSymbolsOfZone(doc.id);
    });
  }

// Give a visible region we will convert into zones and see which zones are in between the two points.
  void getZonesInVisibleRegion() {}

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
        myLocationEnabled: true,
        /*onUserLocationUpdated: (location) {
          controller.moveCamera(CameraUpdate.newLatLng(location.position));
        },*/
        trackCameraPosition: false,
        compassEnabled: true,
        onCameraIdle: () async {
          if (controller != null) {
            LatLngBounds region = await controller.getVisibleRegion();
            print(
                // Get region of viewer. Find all the zones. IF the number of zones is too high then the user is too zooomed out
                // Don't load anything.

                // If the number of zones is not too high then load the zones if the zone is not in a list of "alreadyLoadedZone"
                // add zones to alreadyLoaded Zone as we go.
                "cameraIdle,  Camera bounds are northeast: ${region.northeast}, southwest:${region.southwest})}");
          }
        },
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
