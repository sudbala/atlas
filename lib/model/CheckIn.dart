/// Class to hold a [CheckIn]. Has a title, url for photos, a description,
/// a check-in ID, and more information to come
class CheckIn {
  /// Instance vars/getters/setters

  /// The checkIn id. This is the ID of the checkin from the database that is
  /// also the document ID
  String checkInID;
  String get id => checkInID;
  set id(String id) {
    this.checkInID = id;
  }

  /// The url for the location of photos in the database
  String photosURL;
  String get url => photosURL;
  set url(String url) {
    this.photosURL = url;
  }

  /// The description for a check in from the database
  String checkInDescription;
  String get description => checkInDescription;
  set description(String description) {
    this.checkInDescription = description;
  }

  /// The title for a check in from the database
  String checkInTitle;
  String get title => checkInTitle;
  set title(String title) {
    this.checkInTitle = title;
  }

  String checkInDate;
  String get date => checkInDate;
  set date(String date) {
    this.checkInDate = date;
  }

  /// Constructor
  CheckIn(
      {this.checkInTitle,
      this.checkInDescription,
      this.photosURL,
      this.checkInID,
      this.checkInDate});

  String toString() {
    return checkInTitle + " on " + checkInDate;
  }


}
