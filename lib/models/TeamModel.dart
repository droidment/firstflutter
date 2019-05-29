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

  TeamModel(List<String> this.playerNames, String this.teamName, String this.homeCourt,
      String this.adminName, bool this.allowMaybe, bool this.allowGuest,int this.maxGamePlayerCount, bool this.allowWaitlist) ;


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
  } 

  TeamModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);

  @override
  String toString() => "Team<$teamName:$playerNames>";
}