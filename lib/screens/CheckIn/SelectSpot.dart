import 'dart:collection';
import 'dart:math';
import 'package:atlas/screens/CheckIn/validateSpot.dart';
import 'package:atlas/screens/CustomAppBar.dart';
import 'package:atlas/screens/LocationScreen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:utm/utm.dart';

class SelectSpot extends StatefulWidget {
  @override
  _SelectSpotState createState() => _SelectSpotState();
}

class _SelectSpotState extends State<SelectSpot> {
  static const String ACCESS_TOKEN =
      'pk.eyJ1IjoiamFtZXNmbGVtaW5nYXRsYXMiLCJhIjoiY2tpamtuaWxxMDB1YjJ5bnhkcGJqN3B4aiJ9.VyziFfphnXZJG0awtLjefQ';
  static const String STYLE =
      'mapbox://styles/jamesflemingatlas/ckiuo5rsv1jzb19k6dwpw6ngk';
  MapboxMapController controller;

  void _onMapLongClick(Point<double> point, LatLng coordinate) {
    UtmCoordinate utm =
        UTM.fromLatLon(lat: coordinate.latitude, lon: coordinate.longitude);
    print(utm.toString());
    // Send us to validateSpot
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return ValidateSpot(utm);
    }));
  }

  LatLng initCamera = LatLng(32.9, -130.16);
  LatLng userStart = LatLng(0, 0);

  // Just pulled this over.. kinda lazy
  Future<bool> _getPosition() async {
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
    await Geolocator.getCurrentPosition()
        .then((value) => userStart = LatLng(value.latitude, value.longitude));
    return Future.value(true);
  }

  void _onMapCreated(MapboxMapController controller) async {
    // when the map is created we can add our symbols.
    this.controller = controller;
    // Add a symbol tapped callback
    //await _getPosition();
    //controller.moveCamera(CameraUpdate.newLatLng(userStart));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getPosition(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: CustomAppBar("Tap On a Location!", null, context, null),
              body: MapboxMap(
                initialCameraPosition:
                    CameraPosition(target: userStart, zoom: 15),
                accessToken: ACCESS_TOKEN,
                styleString: STYLE,
                myLocationEnabled: true,
                onMapCreated: _onMapCreated,
                onMapClick: _onMapLongClick,
                compassEnabled: true,
                //trackCameraPosition: ,
              ),
            );
          } else {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
