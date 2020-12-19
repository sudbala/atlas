import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

/// This is the map that will be shown when a user clicks on the map tab.

class AtlasMap extends StatefulWidget {
  Position currentPosition;
  AtlasMap({this.currentPosition});
  /// Instance vars for the MapBox map
  static const String ACCESS_TOKEN =
      'pk.eyJ1Ijoic3Vkb3dvb2RvIiwiYSI6ImNraWc4bjZraDA4aHAyeG9pNnJpM2kzdmMifQ'
      '.97alUuajzxtaLCkz2ura4g';
  static const String STYLE =
      'mapbox://styles/sudowoodo/ckig8qtzi539p19pb08ricter';
  @override
  _AtlasMapState createState() => _AtlasMapState();
}

class _AtlasMapState extends State<AtlasMap> {
  @override
  Widget build(BuildContext context) {
    /// We want to return a Future builder of the map because we want to obtain
    /// position before we display map.

    return  Scaffold(
          body: MapboxMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(
                    widget.currentPosition.latitude, widget.currentPosition.longitude),
                zoom: 15),
            accessToken: AtlasMap.ACCESS_TOKEN,
            styleString: AtlasMap.STYLE,
          ),
        );
  }
}
