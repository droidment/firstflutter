import 'package:cloud_firestore/cloud_firestore.dart';


class TeamModel  {
  DocumentReference team;
  DocumentReference player;
  List<String> playerNames;
  String teamName;
  String homeCourt;
  String adminName;
  bool allowMaybe;
  bool allowGuest;
  int maxGamePlayerCount;
  bool allowWaitlist;

  TeamModel(this.playerNames,this.teamName,this.homeCourt,
      this.adminName, this.allowMaybe,this.allowGuest,this.maxGamePlayerCount, this.allowWaitlist) ;


  Map<String, dynamic> toMap() {
    return {
      "PlayerName": playerNames,
      "TeamName": teamName,
      "HomeCourt": homeCourt,
      "adminName": adminName,
      "allowMaybe": allowMaybe,
      "allowGuest": allowGuest,
      "maxGamePlayerCount": maxGamePlayerCount,
      "allowWaitlist": allowWaitlist,
    };
  }

  TeamModel.fromMap(Map<String, dynamic> map) {
      playerNames = map["PlayerName"];
      teamName = map["TeamName"];
      homeCourt = map["HomeCourt"];
      adminName = map["AdminName"];
      allowMaybe = map["AllowMaybe"];
      allowGuest = map["AllowGuest"];
      maxGamePlayerCount = map["MaxGamePlayerCount"];
      allowWaitlist = map["AllowWaitlist"];
  }

  addTeam() async {
    Firestore fireStore = Firestore.instance;
    CollectionReference teamReference = fireStore.collection("Team");
    teamReference.add(this.toMap()).then((result) {
      return result;
    });
  }

  addPlayersToTeam(String sPlayerName){
    this.playerNames.add(sPlayerName);
    Firestore fireStore = Firestore.instance;
    CollectionReference teamReference = fireStore.collection("Team");
    teamReference.document().updateData(this.toMap()).then((result) {
      return result;
    });
  } 

  TeamModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);

  @override
  String toString() => "Team<$teamName:$playerNames>";
}