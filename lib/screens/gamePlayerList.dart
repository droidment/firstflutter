import 'package:flutter/material.dart';
import '../models/GameModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamePlayerList extends StatefulWidget {
  const GamePlayerList({Key key, @required this.game, @required this.status})
      : super(key: key);

  final GameModel game;
  final String status;
  @override
  GamePlayerListState createState() => new GamePlayerListState(game, status);
}

class GamePlayerListState extends State<GamePlayerList> {
  GamePlayerListState(this.game, this.status);
  final String status;
  final GameModel game;
  final Firestore fireStore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    Firestore fireStore = Firestore.instance;
    List<DocumentSnapshot> snapshotList;
    return StreamBuilder<QuerySnapshot>(
      stream: fireStore
          .collection('GamePlayers')
          .where("Game", isEqualTo: game.reference)
          // .where("YesNoMaybe", isEqualTo: this.status)
          .orderBy("YesNoMaybe", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        snapshotList = snapshot.data.documents;
        Icon _bIcon = (this.status == 'Yes')
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.cancel, color: Colors.red);
        return new Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
                itemCount: snapshotList.length,
                padding: const EdgeInsets.all(0.0),
                itemBuilder: (BuildContext context, int index) {
                  var record = snapshotList[index].data;
                  var _bColor = Colors.green[50];
                  var _sYesNo = record["YesNoMaybe"];
                  if (_sYesNo == "No") {
                    _bColor = Colors.deepOrange[50];
                    _bIcon = Icon(Icons.thumb_down, color: Colors.deepOrange);
                  } else if (_sYesNo == "Maybe") {
                    _bColor = Colors.deepPurple[50];
                    _bIcon = Icon(Icons.all_inclusive, color: Colors.purple);
                  } else if (_sYesNo == "Yes") {
                    _bColor = Colors.green[50];
                    _bIcon = Icon(Icons.thumb_up, color: Colors.green);
                  } else {
                    _bColor = Colors.grey[50];
                    _bIcon =
                        Icon(Icons.notifications_paused, color: Colors.grey);
                  }
                  return Container(
                      color: _bColor,
                      child: ListTile(
                        leading: _bIcon,
                        title: Text(
                          record["PlayerName"],
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey),
                        ),
                        dense: true,
                      ));
                }));
      },
    );
  }
}