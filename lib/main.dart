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

  // final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  Widget _buildAddGame(BuildContext context) {
    TextEditingController fromDateController = TextEditingController();
    TextEditingController toDateController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    return Form(
      key: _addGameFormKey,
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
            decoration:
                InputDecoration(labelText: 'To', hasFloatingPlaceholder: false),
            onChanged: (dt) => setState(() => date = dt),
          ),
          TextFormField(
            controller: locationController,
            decoration: InputDecoration(
                labelText: 'Location', hasFloatingPlaceholder: true),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: OutlineButton(
              highlightColor: Colors.amber,
              onPressed: () async {
                print(_addGameFormKey.currentState);
                _addGameFormKey.currentState.save();
                DateFormat df = new DateFormat("EEE, MMM yyyy dd h:mma");
                var fromDate = df.parse(fromDateController.text);
                var toDate = df.parse(fromDateController.text);
                GameModel gm =  new GameModel(fromDate,toDate, locationController.text);
                  gm.addGame();
              },
              child: Text('Submit'),
            ),
          ),
        ],
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
    String dropdownValue = '+0';
    return Padding(
      key: ValueKey(record.captain1),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Card(
          elevation: 3.0,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: Text(
                  new DateFormat.yMMMMEEEEd("en_US").format(record.timeFrom.toDate())),
              trailing:
                  Text(record.captain1Name + " vs " + record.captain2Name),
              subtitle: Text(record.yesCount.toString() +
                  " Yes | " +
                  record.noCount.toString() +
                  " No  | " +
                  record.maybeCount.toString() +
                  " Maybe | " +
                  record.waitlistCount.toString() +
                  " Waitlist"),
              onTap: () => print(record),
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
          ])),
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
  GeoPoint location;
  int yesCount;
  int noCount;
  int maybeCount;
  int waitlistCount;
  int guestCount;
  DocumentReference reference;

  GameModel(DateTime from, DateTime to, String location){
    timeFrom = new Timestamp.fromDate(from);
    timeTo = new Timestamp.fromDate(to);
    location = location;
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

  addGame() {
    Firestore fireStore = Firestore.instance;
    CollectionReference gameReference = fireStore.collection("Game");
    gameReference
        .add({"From": timeFrom, "To": timeTo, "Location": location}).then((result) {
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
