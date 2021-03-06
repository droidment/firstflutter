import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firstflut/screens/teamList.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'gamePlayerList.dart';
import '../widgets/AppHeader.dart';
import '../widgets/AppDrawer.dart';
import '../widgets/AddGameWidget.dart';
import '../models/GameModel.dart';
import '../models/Rsvp.dart';
import 'addGame.dart';

class GameList extends StatefulWidget {
  GameList({Key key, this.title})
      : super(key: key);

  final String title;
  // final FirebaseAnalytics analytics;
  // final FirebaseAnalyticsObserver observer;

  GameListState createState() => new GameListState();
}

class GameListState extends State<GameList> {
  GameListState();
  // final FirebaseAnalyticsObserver observer;
  // final FirebaseAnalytics analytics;
  final Firestore fireStore = Firestore.instance;
  final _addGameFormKey = GlobalKey<FormState>();

  final formats = {
    InputType.both: DateFormat("EEE, MMM yyyy dd h:mma"),
    InputType.date: DateFormat('yy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };
  InputType inputType = InputType.both;
  bool editable = true;
  DateTime date;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  String teamName = "Katy Whackers";

  // final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
Navigator.push(context, MaterialPageRoute<DismissDialogAction>(
                builder: (BuildContext context) => AddGameScreen(),
                fullscreenDialog: true,
              ));
            // showDialog(
            //     context: context,
            //     builder: (_) => new AlertDialog(
            //         title: new Text("Add new game"),
            //         content: new AddGameWidget(addGameFormKey: _addGameFormKey, inputType: inputType, formats: formats, editable: editable, scaffoldKey: _scaffoldKey, context: context)));
          },
        ),
        // bottomNavigationBar: BottomAppBar(
        //   color: Colors.amberAccent,
        //   child: Container(height: 40.0),
        // ),
        drawer: new AppDrawer(addGameFormKey: _addGameFormKey, inputType: inputType, formats: formats, editable: editable, scaffoldKey: _scaffoldKey),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
               return <Widget>[
                new AppHeader(title:teamName),
              ];
            },
            body: _buildBody(context)));
    // body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: fireStore.collection('Game').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot
          .map((documentSnapshot) => _buildListItem(context, documentSnapshot))
          .toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot gameData) {
    final record = GameModel.fromSnapshot(gameData);
    var toDateStr = (record.timeFrom == null)
        ? ""
        : new DateFormat.yMMMMEEEEd("en_US").format(record.timeFrom.toDate());
    // var fromDateStr = new DateFormat.yMMMMEEEEd("en_US").format(record.timeTo.toDate()) ?? "";
    var yesCount =
        (record.yesCount == null) ? "" : record.yesCount.toString() + " Yes | ";
    var noCount =
        (record.noCount == null) ? "" : record.noCount.toString() + " No | ";
    var maybeCount = (record.maybeCount == null)
        ? ""
        : record.maybeCount.toString() + " Maybe | ";
    var waitlistCount = (record.waitlistCount == null)
        ? ""
        : record.waitlistCount.toString() + " Waitlist |";
    var cap1Name = record.captain1Name ?? "";
    var cap2Name = record.captain2Name ?? "";
    

    String dropdownValue = '+0';
    return Padding(
        // key: ValueKey(record.captain1),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Card(
          elevation: 3.0,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Material(
              child: InkWell(
                  child: ListTile(
                    title: Text(toDateStr),
                    trailing: Text(cap1Name + " vs " + cap2Name),
                    subtitle:
                        Text(yesCount + noCount + maybeCount + waitlistCount),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => new AlertDialog(
                            content: _viewGame(context, record)));
                  }),
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String newValue) async {
                      int iGuestCount = int.tryParse(newValue) ?? 0;
                      RSVP rsvpUser = new RSVP(
                          record.reference, "Raj", "Guest", iGuestCount);
                      await rsvpUser.doRSVP(rsvpUser, gameData);
                    },
                    items: <String>['+0', '1', '2', '3', '4']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  OutlineButton(
                    highlightColor: Colors.amber,
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.teal),
                    ),
                    onPressed: () async {
                      RSVP rsvpUser = new RSVP(record.reference, "Raj", "Yes");
                      await rsvpUser.doRSVP(rsvpUser, gameData);
                    },
                  ),
                  OutlineButton(
                    highlightColor: Colors.amber,
                    textTheme: ButtonTextTheme.normal,
                    child: const Text('No',
                        style: TextStyle(color: Colors.orange)),
                    onPressed: () async {
                      RSVP rsvpUser = new RSVP(record.reference, "Raj", "No");
                      await rsvpUser.doRSVP(rsvpUser, gameData);
                    },
                  ),
                  OutlineButton(
                    highlightColor: Colors.amber,
                    textTheme: ButtonTextTheme.normal,
                    child: const Text('Maybe',
                        style: TextStyle(color: Colors.grey)),
                    onPressed: () async {
                      RSVP rsvpUser =
                          new RSVP(record.reference, "Raj", "Maybe", 0);
                      await rsvpUser.doRSVP(rsvpUser, gameData);
                    },
                  ),
                ],
              ),
            ),
          ]),
        ));
  }

  Widget _viewGame(BuildContext context, GameModel record) {
    var timeStr = " ";
    var toDateStr;
    if (record.timeFrom != null) {
      toDateStr =
          new DateFormat.yMMMMEEEEd("en_US").format(record.timeFrom.toDate());
      var fromTimeStr =
          new DateFormat.Hm("en_US").format(record.timeFrom.toDate());
      var toTimeStr = new DateFormat.Hm("en_US").format(record.timeTo.toDate());
      timeStr = "From " + fromTimeStr + " to " + toTimeStr;
    }
    // var fromDateStr = new DateFormat.yMMMMEEEEd("en_US").format(record.timeTo.toDate()) ?? "";
    var yesCount = (record.yesCount == null) ? "0" : record.yesCount.toString();
    var noCount = (record.noCount == null) ? "0" : record.noCount.toString();
    var maybeCount =
        (record.maybeCount == null) ? "0" : record.maybeCount.toString();
    var waitlistCount = (record.waitlistCount == null)
        ? ""
        : record.waitlistCount.toString() + " Waitlist |";
    var cap1Name = record.captain1Name ?? "";
    var cap2Name = record.captain2Name ?? "";
    var locationStr = record.location ?? "";

    return new SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: new Column(children: <Widget>[
          new ListTile(
              leading:
                  const Icon(Icons.access_time, color: Colors.indigoAccent),
              title: Text(toDateStr),
              subtitle: Text(timeStr)),
          new ListTile(
              leading:
                  const Icon(Icons.location_on, color: Colors.indigoAccent),
              title: Text(locationStr)),
          new ListTile(
            leading:
                const Icon(Icons.thumbs_up_down, color: Colors.indigoAccent),
            title: Text("Yes : " + yesCount),
            subtitle: Text("No : " + noCount + " | Maybe : " + maybeCount),
          ),
          new ListTile(
              leading:
                  const Icon(Icons.people_outline, color: Colors.indigoAccent),
              title: Text(cap1Name + " versus " + cap2Name)),
          new GamePlayerList(game: record, status: "No"),
          //  new PlayerList(game: record, status: "No"),
        ]));
    // ]);
  }
}


