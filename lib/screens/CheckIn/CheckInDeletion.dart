import 'package:atlas/model/CheckIn.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Master Deletion.
Future<bool> deletePost(CheckIn checkIn) async {
  await deleteFromZones(checkIn);
  await deleteFromCheckins(checkIn);
  deleteImage(checkIn);
  deleteFromLikes(checkIn);
  return Future.value(true);
}

Future<void> deleteImage(CheckIn checkIn) async {
  // Go through each image and delete it.
  // Deletes from firebase, currently does not delete from cache.
  int i = 0;
  for (String url in checkIn.photoURLs) {
    print(url);
    Reference photoRef = FirebaseStorage.instance
        .ref()
        .child('checkInPhotos/${checkIn.checkInID};$i.jpg');
    i++;
    await photoRef.delete();
  }
}

//Deletes checkIn from a users checkIn collection in firestore.
// Super important to clear the feeds

Future<void> deleteFromCheckins(CheckIn checkIn) async {
  DocumentReference checkInRef =
      FirebaseFirestore.instance.collection("CheckIns").doc(checkIn.profileId);
  await checkInRef.update({
    "CheckIns": FieldValue.arrayRemove([checkIn.checkInID])
  });
}

//Deletes checkIn from Likes
Future<void> deleteFromLikes(CheckIn checkIn) async {
  DocumentReference checkInRef =
      FirebaseFirestore.instance.collection("Likes").doc(checkIn.checkInID);
  await checkInRef.delete();
}

// Deletes a checkIn from the Zones collection in firestore.
Future<void> deleteFromZones(CheckIn checkIn) async {
  var splitId = checkIn.checkInID.split(";");
  String zone = splitId[0];
  String area = "${splitId[1].substring(0, 3)};${splitId[2].substring(0, 2)}";
  String spot = "${splitId[1]};${splitId[2]}";
  // Man I probably did not organize this whole thing very well lmao.
  DocumentReference checkInRef = FirebaseFirestore.instance
      .collection("Zones")
      .doc(zone)
      .collection("Area")
      .doc(area)
      .collection("Spots")
      .doc(spot)
      .collection("VisitedUsers")
      .doc("${checkIn.profileId}")
      .collection("CheckIns;${checkIn.profileId}")
      .doc("${checkIn.checkInID}");
  await checkInRef.delete();
}
