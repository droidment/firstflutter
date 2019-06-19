import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerModel  {
  String playerName;
  String phoneNumber;
  DocumentReference playerReference;
  PlayerModel(this.playerName,this.phoneNumber) ;


  
}