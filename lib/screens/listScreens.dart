import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/GameModel.dart';

import 'team.dart';
import '../widgets/AddGameWidget.dart';
import "package:firstflut/widgets/AppDrawer.dart";

class ListScreen extends StatefulWidget {
  ListScreen({Key key, this.title}) : super(key: key);

  final String title;
  // final FirebaseAnalytics analytics;
  // final FirebaseAnalyticsObserver observer;

  ListScreenState createState() => new ListScreenState();
}

 class ListScreenState extends State<ListScreen> {
  ListScreenState();
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
                    content: new AddGameWidget(
                        addGameFormKey: _addGameFormKey,
                        inputType: inputType,
                        formats: formats,
                        editable: editable,
                        scaffoldKey: _scaffoldKey,
                        context: context)));
          },
        ),
        drawer: new AppDrawer(addGameFormKey: _addGameFormKey, inputType: inputType, formats: formats, editable: editable, scaffoldKey: _scaffoldKey),
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
    // return ListView(
    //   padding: const EdgeInsets.only(top: 20.0),
    //   children: snapshot
    //       .map((documentSnapshot) => _buildListItem(context, documentSnapshot))
    //       .toList(),
    // );
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
              ),
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  DropdownButton<String>(
                    value: dropdownValue,
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
                  ),
                  OutlineButton(
                    highlightColor: Colors.amber,
                    textTheme: ButtonTextTheme.normal,
                    child: const Text('No',
                        style: TextStyle(color: Colors.orange)),
                  ),
                  OutlineButton(
                      highlightColor: Colors.amber,
                      textTheme: ButtonTextTheme.normal,
                      child: const Text('Maybe',
                          style: TextStyle(color: Colors.grey)))
                ],
              ),
            ),
          ]),
        ));
  }
}


