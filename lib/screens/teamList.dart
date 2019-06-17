import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/TeamModel.dart';
import 'package:intl/intl.dart';
import '../widgets/AddGameWidget.dart';
import '../widgets/AppHeader.dart';
import '../widgets/AppDrawer.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class TeamList extends StatefulWidget {
  TeamList({Key key, this.title}) : super(key: key);

  final String title;
  TeamListState createState() => new TeamListState();
}

class TeamListState extends State<TeamList> {
  TeamListState();
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
                    title: new Text("Add new Team"),
                    content: new Team(
                        scaffoldKey: _scaffoldKey,
                        context: context)));
          },
        ),
        drawer: new AppDrawer(
            addGameFormKey: _addGameFormKey,
            inputType: inputType,
            formats: formats,
            editable: editable,
            scaffoldKey: _scaffoldKey),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new AppHeader(),
              ];
            },
            body: _buildBody(context)));
    // body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: fireStore.collection('Team').snapshots(),
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

  Widget _buildListItem(BuildContext context, DocumentSnapshot teamData) {
    final record = TeamModel.fromSnapshot(teamData);
    var teamName = record.teamName ?? "";
    var homeCourt = record.homeCourt ?? "";
    var adminName = record.adminName ?? "";

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
                  title: Text(teamName),
                  trailing: Text(homeCourt),
                  subtitle: Text("Admin Name $adminName"),
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
                    textTheme: ButtonTextTheme.normal,
                    child: const Text('Edit',
                        style: TextStyle(color: Colors.orange)),
                  ),
                  OutlineButton(
                      highlightColor: Colors.amber,
                      textTheme: ButtonTextTheme.normal,
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.grey)))
                ],
              ),
            ),
          ]),
        ));
  }
}


