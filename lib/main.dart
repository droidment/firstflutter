import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

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

  // final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            print("FAB Pressed");
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
                      background: Image.asset("assets/volleyball_masthead.jpg",
                          fit: BoxFit.fill)),
                ),
              ];
            },
            body: _buildBody(context)));
    // body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('GameModel').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = GameModel.fromSnapshot(data);
    String dropdownValue = '+0';
    return Padding(
      key: ValueKey(record.captain1),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Card(
          elevation: 3.0,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: Text(
                  new DateFormat.yMMMMEEEEd("en_US").format(record.timeFrom)),
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
              // : Text("12 Yes   3 No  1 Maybe"),
              onTap: () => print(record),
            ),
            ButtonTheme.bar(
              // make buttons use the appropriate styles for cards
              child: ButtonBar(
                children: <Widget>[
                  DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String newValue) {
                      int guestNum = int.tryParse(newValue) ?? 0;
                      record.yesCount += guestNum;
                      print("DropDown Value is " + record.yesCount.toString());
                      setState(() {
                        dropdownValue = newValue;
                      });
                      
                    },
                    items: <String>['+0', '1', '2', '3', '4']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  FlatButton(
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.teal),
                    ),
                    onPressed: () {/* ... */},
                  ),
                  FlatButton(
                    textTheme: ButtonTextTheme.normal,
                    child: const Text('No',
                        style: TextStyle(color: Colors.orange)),
                    onPressed: () {/* ... */},
                  ),
                  FlatButton(
                    textTheme: ButtonTextTheme.normal,
                    child: const Text('Maybe',
                        style: TextStyle(color: Colors.grey)),
                    onPressed: () {/* ... */},
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
  DateTime timeFrom;
  String yesNoMaybe;
}

class GameModel extends Model{
  DocumentReference captain1;
  DocumentReference captain2;
  DateTime timeFrom;
  DateTime timeTo;
  String score;
  String captain1Name;
  String captain2Name;
  String winner;
  int yesCount;
  int noCount;
  int maybeCount;
  int waitlistCount;
  DocumentReference reference;

  GameModel.fromMap(Map<String, dynamic> map, {this.reference}) {
    assert(map['Captain1'] != null);
    assert(map['Captain2'] != null);
    captain1 = map['Captain1'];
    captain2 = map['Captain2'];
    timeFrom = map["TimeFrom"];
    captain1Name = map['Captain1Name'];
    captain2Name = map['Captain2Name'];
    timeTo = map["TimeTo"];
    winner = map["Winner"];
    score = map["Score"];
    yesCount = map["YesCount"];
    noCount = map["NoCount"];
    maybeCount = map["MaybeCount"];
    waitlistCount = map["WaitlistCount"];
  }

  addRsvp(String yesNoMaybe, int count){
    if (yesNoMaybe == 'yes') yesCount = yesCount += count;
    if (yesNoMaybe == 'no') noCount = noCount += count;
    if (yesNoMaybe == 'maybe') maybeCount = maybeCount += count;
  }

  GameModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "GameModel<$captain1:$score>";
}
