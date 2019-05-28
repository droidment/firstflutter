import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.amber,
          secondaryHeaderColor: Colors.amberAccent),
      navigatorObservers: <NavigatorObserver>[observer],
      home: TeamList(),
    );
  }
}

class TeamList extends StatefulWidget {
  TeamList({Key key, this.title, this.analytics, this.observer})
      : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  TeamListState createState() => new TeamListState(analytics, observer);
}

class TeamListState extends State<TeamList> {
  TeamListState(this.analytics, this.observer);
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
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

  // final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => new AlertDialog(
                    title: new Text("Add new game"),
                    content: _buildAddGame(context)));
          },
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.amberAccent,
          child: Container(height: 50.0),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                    expandedHeight: 100.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text("Katy Whackers",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              Shadow(
                                offset: Offset(3.0, 3.0),
                                blurRadius: 8.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ],
                          )),
                      background: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.asset("assets/volleyball_masthead.jpg",
                              fit: BoxFit.fill)),
                    )),
              ];
            },
            body: _buildBody(context)));
    // body: _buildBody(context));
  }

  Widget _buildAddGame(BuildContext _context) {
    TextEditingController fromDateController = TextEditingController();
    TextEditingController toDateController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController captain1Controller = TextEditingController();
    TextEditingController captain2Controller = TextEditingController();
    return Form(
      key: _addGameFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DateTimePickerFormField(
              controller: fromDateController,
              inputType: inputType,
              format: formats[inputType],
              editable: editable,
              decoration: InputDecoration(
                  labelText: 'From', hasFloatingPlaceholder: false),
              onChanged: (dt) {},
            ),
            DateTimePickerFormField(
              controller: toDateController,
              inputType: inputType,
              format: formats[inputType],
              editable: editable,
              decoration: InputDecoration(
                  labelText: 'To', hasFloatingPlaceholder: false),
              onChanged: (dt) => setState(() => date = dt),
            ),
            TextFormField(
              controller: locationController,
              decoration: InputDecoration(
                  labelText: 'Location', hasFloatingPlaceholder: true),
            ),
            TextFormField(
              controller: captain1Controller,
              decoration: InputDecoration(
                  labelText: 'Captain 1', hasFloatingPlaceholder: true),
            ),
            TextFormField(
              controller: captain2Controller,
              decoration: InputDecoration(
                  labelText: 'Captain 2', hasFloatingPlaceholder: true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: OutlineButton(
                highlightColor: Colors.amber,
                onPressed: () async {
                  _addGameFormKey.currentState.save();
                  DateFormat df = new DateFormat("EEE, MMM yyyy dd h:mma");
                  var fromDate = (fromDateController.text == "")
                      ? DateTime.now()
                      : df.parse(fromDateController.text);
                  var toDate = (toDateController.text == "")
                      ? DateTime.now()
                      : df.parse(toDateController.text);
                  GameModel gm = new GameModel(
                      fromDate,
                      toDate,
                      locationController.text,
                      captain1Controller.text,
                      captain2Controller.text);
                  await gm.addGame();
                  _scaffoldKey.currentState.showSnackBar(new SnackBar(
                    content: new Text("Added game successfully."),
                  ));
                  Navigator.of(_context, rootNavigator: true).pop();
                  // Navigator.pop(_context);
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: fireStore.collection('Game').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

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
        key: ValueKey(record.captain1),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Card(
          elevation: 3.0,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
                title: Text(toDateStr),
                trailing: Text(cap1Name + " vs " + cap2Name),
                subtitle: Text(yesCount + noCount + maybeCount + waitlistCount),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) =>
                          new AlertDialog(content: _viewGame(context, record)));
                }),
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
          new PlayerList(game: record, status: "No"),
          //  new PlayerList(game: record, status: "No"),
        ]));
    // ]);
  }
}

class PlayerList extends StatefulWidget {
  const PlayerList(
      {Key key,
      @required this.game,
      @required this.status})
      : super(key: key);

  final GameModel game;
  final String status;
  @override
  PlayerListState createState() =>
      new PlayerListState(game, status);
}

class PlayerListState extends State<PlayerList>{
  PlayerListState(this.game, this.status);
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
          .orderBy("YesNoMaybe",descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        snapshotList = snapshot.data.documents;
        Icon _bIcon = (this.status == 'Yes')
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.cancel, color: Colors.red);
        return  new Container(
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
                        _bIcon = Icon(Icons.all_inclusive,color: Colors.purple);
                      }else {
                        _bColor = Colors.green[50];
                        _bIcon = Icon(Icons.thumb_up, color: Colors.green);
                      }
                      return Container(
                          color: _bColor,
                          child: ListTile(
                            leading:  _bIcon,    
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

class SignInFab extends StatelessWidget {
  const SignInFab();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => print('Tapped on sign in'),
      icon: Image.asset('assets/google_g_logo.png', height: 24.0),
      label: const Text('Sign in'),
    );
  }
}

class Players {
  final String name;
  final String phone;
  Players(this.name, this.phone);
}

class RSVP {
  DocumentReference game;
  String playerName;
  String yesNoMaybe;
  int guestCount;
  RSVP(DocumentReference game, String playerName, String yesNoMaybe,
      [int guestCount = 0]) {
    this.game = game;
    this.playerName = playerName;
    this.yesNoMaybe = yesNoMaybe;
    this.guestCount = guestCount;
  }
  toMap() {
    return {
      "Game": game,
      "PlayerName": playerName,
      "YesNoMaybe": yesNoMaybe,
      "GuestCount": guestCount
    };
  }

  doRSVP(RSVP rsvpUser, DocumentSnapshot gameData) async {
    //If this user RSVP already exists for this Game, update the response,
    // If not add.
    Firestore fireStore = Firestore.instance;

    CollectionReference gamePlayerReference =
        fireStore.collection("GamePlayers");
    Query gamePlayerQuery = gamePlayerReference
        .where("PlayerName", isEqualTo: rsvpUser.playerName)
        .where("Game", isEqualTo: rsvpUser.game);

    // String sYesNoMayCount = rsvpUser.yesNoMaybe + "Count";
    int iYesCount = gameData.data["YesCount"];
    int iNoCount = gameData.data["NoCount"];
    int iMaybeCount = gameData.data["MaybeCount"];
    int iGuestCount = gameData.data["GuestCount"];
    bool bUserPreviouslyHasGuest = false;
    bool bUserHasGuestNow = false;
    int iWaitlistCount = gameData.data["WaitlistCount"];

    await gamePlayerQuery.getDocuments().then((results) {
      if (results.documents.isNotEmpty) {
        results.documents.forEach((player) {
          String dbYesNoSelection = player.data['YesNoMaybe'].toString();
          //If the player had a previous guest selection

          if (rsvpUser.yesNoMaybe != dbYesNoSelection) {
            // Continue only if user changed the selection

            int playerGuestCount = player.data["GuestCount"];
            if (playerGuestCount is int && playerGuestCount > 0) {
              bUserPreviouslyHasGuest = true;
            }
            if (rsvpUser.guestCount is int && rsvpUser.guestCount > -1) {
              iGuestCount = rsvpUser.guestCount;
              bUserHasGuestNow = true;
            }
            if (rsvpUser.yesNoMaybe == "Guest") {
              rsvpUser.yesNoMaybe = "Yes";

              if (bUserPreviouslyHasGuest) {
                iYesCount = iYesCount - playerGuestCount;
              } else {
                if (player.data["YesNoMaybe"] != "Yes")
                  iYesCount = iYesCount + 1;
              }
              if (bUserHasGuestNow) {
                iYesCount = iYesCount + iGuestCount;
                player.data['GuestCount'] = iGuestCount;
              }
              if (dbYesNoSelection == "No") {
                iNoCount = iNoCount - 1;
              } else if (dbYesNoSelection == "Maybe") {
                iMaybeCount = iMaybeCount - 1;
              }
            } else if (rsvpUser.yesNoMaybe == "Yes") {
              iYesCount = iYesCount + 1;
              // if (bUserHasGuestNow) {
              //   iYesCount = iYesCount + iGuestCount;
              //   player.data['GuestCount'] = iGuestCount;
              // }
              if (dbYesNoSelection == "No") {
                iNoCount = iNoCount - 1;
              } else {
                iMaybeCount = iMaybeCount - 1;
              }
            } else if (rsvpUser.yesNoMaybe == "No") {
              iNoCount = iNoCount + 1;
              player.data['GuestCount'] = 0;
              if (dbYesNoSelection == "Yes") {
                iYesCount = iYesCount - 1;
                if (bUserPreviouslyHasGuest) {
                  iYesCount = ((iYesCount - playerGuestCount) > 0)
                      ? (iYesCount - playerGuestCount)
                      : 0;
                }
              } else {
                iMaybeCount = iMaybeCount - 1;
              }
            } else if (rsvpUser.yesNoMaybe == "Maybe") {
              iMaybeCount = iMaybeCount + 1;
              player.data['GuestCount'] = 0;
              if (dbYesNoSelection == "Yes") {
                iYesCount = iYesCount - 1;
                if (bUserPreviouslyHasGuest) {
                  iYesCount = ((iYesCount - playerGuestCount) > 0)
                      ? (iYesCount - playerGuestCount)
                      : 0;
                }
              } else {
                iNoCount = iNoCount - 1;
              }
            }
            player.data['YesNoMaybe'] = rsvpUser.yesNoMaybe;
            player.reference.updateData(player.data).then((result) {
              gameData.reference.updateData({
                "YesCount": iYesCount,
                "NoCount": iNoCount,
                "MaybeCount": iMaybeCount,
                "GuestCount": iGuestCount
              });
            });
          }
        });
      } else {
        if (rsvpUser.yesNoMaybe == "Guest") {
          rsvpUser.yesNoMaybe = "Yes";
          iYesCount = iYesCount + 1 + rsvpUser.guestCount;
        } else if (rsvpUser.yesNoMaybe == "Yes") {
          iYesCount = iYesCount + 1;
        } else if (rsvpUser.yesNoMaybe == "No") {
          iNoCount = iNoCount + 1;
        } else if (rsvpUser.yesNoMaybe == "Maybe") {
          iMaybeCount = iMaybeCount + 1;
        }
        gamePlayerReference.add(rsvpUser.toMap()).then((result) {
          gameData.reference.updateData({
            "YesCount": iYesCount,
            "NoCount": iNoCount,
            "MaybeCount": iMaybeCount,
            "GuestCount": rsvpUser.guestCount
          });
        });
      }
    });
  }
}

class GameModel extends Model {
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
  DocumentReference reference;

  GameModel(DateTime from, DateTime to, String locationStr, String cap1Name,
      String cap2Name) {
    timeFrom = new Timestamp.fromDate(from);
    timeTo = new Timestamp.fromDate(to);
    location = locationStr;
    captain1Name = cap1Name;
    captain2Name = cap2Name;
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
