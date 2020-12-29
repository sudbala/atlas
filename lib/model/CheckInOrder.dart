class CheckInOrder {
  String checkInId;
  String zone;
  String northing;
  String easting;
  String spotId;
  String area;
  DateTime postDate;
  String userId;
  //zone + ";" + spotId + ";" + spotName + ";" + DateTime.now().toString();

  CheckInOrder(String checkInId) {
    this.checkInId = checkInId;
    var split = checkInId.split(";");
    zone = split[0];
    northing = split[1];
    easting = split[2];
    area = "${northing.substring(0, 3)};${easting.substring(0, 2)}";
    spotId = "$northing;$easting";
    postDate = DateTime.parse(split[4]);
  }
}
