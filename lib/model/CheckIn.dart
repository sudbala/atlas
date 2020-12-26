import 'package:cloud_firestore/cloud_firestore.dart';

/// Class to hold a [CheckIn]. Has a title, url for photos, a description,
/// a check-in ID, and more information to come
class CheckIn {
  /// Instance vars/getters/setters

  /// The checkIn id. This is the ID of the checkin from the database that is
  /// also the document ID
  ///
  String checkInID;
  String get id => checkInID;
  set id(String id) {
    this.checkInID = id;
  }

  Timestamp timeStamp;

  /// The url for the location of photos in the database
  List<String> photoURLs;
  List<String> get url => photoURLs;
  set url(List<String> url) {
    this.photoURLs = url;
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

  String checkInUserName;
  String get userName => checkInUserName;
  set userName(String userName) {
    this.checkInUserName = userName;
  }

  String checkInProfileId;
  String get profileId => checkInProfileId;
  set profileId(String profileId) {
    this.checkInProfileId = profileId;
  }

  /// Constructor
  CheckIn(
      {this.checkInTitle,
      this.checkInDescription,
      this.photoURLs,
      this.checkInID,
      this.checkInDate,
      this.checkInUserName,
      this.checkInProfileId,
      this.timeStamp});

  String toString() {
    return checkInTitle + " on " + checkInDate;
  }
}
