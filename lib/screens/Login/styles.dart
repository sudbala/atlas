import 'package:flutter/material.dart';

/// [DecorationImage]s are used as variables to hold the image.
DecorationImage backgroundImage = DecorationImage(
  image: ExactAssetImage('images/landscape.jpg'),
  fit: BoxFit.cover,
);

DecorationImage profileSetupBackground = DecorationImage(
  image: ExactAssetImage('images/boRidge.JPG'),
  fit: BoxFit.cover,
);

DecorationImage tick = new DecorationImage(
  image: new ExactAssetImage('assets/tick.png'),
  fit: BoxFit.cover,
);
