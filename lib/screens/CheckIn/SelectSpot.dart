import 'dart:math';
import 'package:atlas/screens/CheckIn/validateSpot.dart';
import 'package:atlas/screens/LocationScreen.dart';
import 'package:flutter/material.dart';
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

  void _onMapCreated(MapboxMapController controller) {
    // when the map is created we can add our symbols.
    this.controller = controller;

    // Add a symbol tapped callback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Long Press to Select a Location"),
      ),
      body: MapboxMap(
        initialCameraPosition: const CameraPosition(
            target: LatLng(43.701017, -72.289265), zoom: 12),
        accessToken: ACCESS_TOKEN,
        styleString: STYLE,
        onMapCreated: _onMapCreated,
        onMapLongClick: _onMapLongClick,
      ),
    );
  }
}
