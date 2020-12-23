import 'package:atlas/model/CheckIn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:geolocator/geolocator.dart';

/// The view of a [CheckInPost]. This widget will be used in various places
class CheckInPost extends StatefulWidget {
  /// One final instance variable is the checkIn object, which will hold all information
  final CheckIn checkIn;

  const CheckInPost({
    Key key,
    @required this.checkIn,
  }) : super(key: key);
  @override
  _CheckInPostState createState() => _CheckInPostState();
}

class _CheckInPostState extends State<CheckInPost> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

/// Widget that holds the header media for the [CheckInPost]. Subject to change.
class CheckInHeader extends StatelessWidget {
  final List<String> images;
  final bool isLiked;
  final Function onLikePress, onBackPressed;

  /// Constructor of the [CheckInHeader]
  const CheckInHeader(
      {Key key,
      @required this.images,
      this.isLiked = false,
      @required this.onLikePress,
      @required this.onBackPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Media Query to fit the entire width and height of the current context
    /// the height will be restricted, but width will most likely be the entire
    /// phone
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height / 2,
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: RoundClipper(),
            child: Swiper(
              itemBuilder: (context, index) {
                return Image.asset(
                  images[index],
                  fit: BoxFit.fill,
                );
              },
              indicatorLayout: PageIndicatorLayout.COLOR,
              itemCount: images.length,
              pagination: SwiperPagination(),
              control: SwiperControl(),
            ),
          ),
          Positioned(
            top: 25,
            left: 3,
            child: Container(
                width: 50,
                height: 50,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: FlatButton(
                  splashColor: Colors.green.withOpacity(0.3),
                  padding: EdgeInsets.all(10),
                  onPressed: this.onBackPressed,
                  child: Icon(Icons.arrow_back, size: 25),
                )),
          ),
          Positioned(
            bottom: 12,
            right: 25,
            child: Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: Offset(1, 5),
                    spreadRadius: 5.0,
                  ),
                ],
              ),
              child: FlatButton(
                padding: EdgeInsets.all(10),
                onPressed: this.onLikePress,
                child: SvgPicture.asset(
                  "assets/heart.svg",
                  color:
                      this.isLiked ? Colors.red : Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RoundClipper extends CustomClipper<Path> {
  /// getClip() gives back the rounded clipping patter you see on the images.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 1.5, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    /// Necessary but has no purpose
    return false;
  }
}
