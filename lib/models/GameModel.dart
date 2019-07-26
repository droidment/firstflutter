import 'package:cloud_firestore/cloud_firestore.dart';
import 'Rsvp.dart';


class GameModel  {
  DocumentReference captain1;
  DocumentReference captain2;
  Timestamp timeFrom;
  Timestamp timeTo;
  String score;
  String captain1Name;
  String captain2Name;
  String winner;
  String location;
  int yesCount;
  int noCount;
  int maybeCount;
  int waitlistCount;
  int guestCount;
  List<RSVP> rsvps; 
  CollectionReference gamePlayerReference;
  DocumentReference reference;

  GameModel(DateTime from, DateTime to, String locationStr, String cap1Name,
      String cap2Name) {
    timeFrom = new Timestamp.fromDate(from);
    timeTo = new Timestamp.fromDate(to);
    location = locationStr;
    captain1Name = cap1Name;
    captain2Name = cap2Name;
    // rsvps = rsvpList;
  }

  Map<String, dynamic> toMap() {
    return {
      "Captain1": captain1,
      "Captain2": captain2,
      "TimeFrom": timeFrom,
      "TimeTo": timeTo,
      "Score": score,
      "Captain1Name": captain1Name,
      "Captain2Name": captain2Name,
      "Winner": winner,
      "Location": location,
      "YesCount": 0,
      "NoCount": 0,
      "MaybeCount": 0,
      "WaitlistCount": 0,
      "GuestCount": 0,
      "Reference": reference
      // "Rsvp":
    };
  }

  GameModel.fromMap(Map<String, dynamic> map, {this.reference}) {
    // assert(map['Captain1'] != null);
    // assert(map['Captain2'] != null);
    captain1 = map['Captain1'];
    captain2 = map['Captain2'];
    timeFrom = map["TimeFrom"];
    timeTo = map["TimeTo"];
    captain1Name = map['Captain1Name'];
    captain2Name = map['Captain2Name'];
    winner = map["Winner"];
    score = map["Score"];
    yesCount = map["YesCount"];
    noCount = map["NoCount"];
    maybeCount = map["MaybeCount"];
    waitlistCount = map["WaitlistCount"];
    guestCount = map["GuestCount"];
    location = map["Location"];
  }

  addGame() async {
    Firestore fireStore = Firestore.instance;
    CollectionReference gameReference = fireStore.collection("Game");
    gameReference.add(this.toMap()).then((result) {
      return result;
    });
  }

  addRsvp(String yesNoMaybe, int count) {
    if (yesNoMaybe == 'yes') yesCount = yesCount += count;
    if (yesNoMaybe == 'no') noCount = noCount += count;
    if (yesNoMaybe == 'maybe') maybeCount = maybeCount += count;
  }

  GameModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "GameModel<$captain1:$score>";
}