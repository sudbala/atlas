import 'package:flutter/material.dart';

// A simply page to see one's images in all their glory. Similar to what strava does. Implement imageViewers so one can zoom in on each image.
class PhotoPage extends StatelessWidget {
  List photoUrls;
  String title;
  PhotoPage(List photoUrls, String title) {
    this.photoUrls = photoUrls;
    this.title = title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView.builder(
            itemCount: photoUrls.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(child: Image.network(photoUrls[index])));
            }));
  }
}
