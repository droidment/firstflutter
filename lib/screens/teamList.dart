import 'dart:async';

import 'package:firstflut/mixins/AppConstants.dart';
import 'package:firstflut/widgets/AddPlayersToTeam.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/TeamModel.dart';
import 'package:intl/intl.dart';
import '../widgets/Dialogs.dart';
import 'team.dart';
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
  Dialogs dialogs = Dialogs();

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
                    title: new Text("Add new Team"), content: new Team()));
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

  final List<PopupMenuItem<String>> _popupMenuItems =
      AppConstantsMixin.editMenuItems
          .map((String value) => PopupMenuItem<String>(
                value: value,
                child: Text(value),
              ))
          .toList();

  void editDeleteTeam(DocumentSnapshot teamSnapshot, String action) {
    var teamName = teamSnapshot.data["TeamName"];
    // var teamRef = teamSnapshot.reference;
    if (action == AppConstantsMixin.editMenuItems[0]) {
      showDialog(
          context: context,
          builder: (_) => new AlertDialog(
              title: new Text("Player list for $teamName"),
              content: AddPlayersToTeamWidget(
                  teamDocument: teamSnapshot,
                  scaffoldKey: _scaffoldKey,
                  context: context)));
    } else if (action == AppConstantsMixin.editMenuItems[1]) {
      print("Edit Team");
    } else if (action == AppConstantsMixin.editMenuItems[2]) {
      dialogs
          .confirmDialog(context, "Delete $teamName?",
              "Are you sure you want to delete $teamName?")
          .then((onValue) {
        if (onValue == ConfirmAction.ACCEPT) {
          //print("Deleting Team");
          Firestore.instance
              .collection('Team')
              .document(teamSnapshot.documentID)
              .delete()
              .catchError((e) {
            print(e);
          });
        }
      });
    }
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot teamData) {
    final record = TeamModel.fromSnapshot(teamData);
    var teamName = record.teamName ?? "";
    var homeCourt = record.homeCourt ?? "";
    var adminName = record.adminName ?? "";
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
        child: Card(
          elevation: 3.0,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Material(
              child: InkWell(
                child: ListTile(
                    title: Text(teamName),
                    trailing: PopupMenuButton<String>(
                        itemBuilder: (BuildContext context) => _popupMenuItems,
                        onSelected: (action) {
                          editDeleteTeam(teamData, action);
                        }),
                    subtitle: Text("At $homeCourt")),
              ),
            ),
            getPlayerChips(record.playerNames)
          ]),
        ));
  }

  Widget getPlayerChips(List playerNames) {
    return (playerNames != null)
        ? Wrap(alignment: WrapAlignment.start, spacing: 5, children: <Widget>[
            for (var item in playerNames) getPlayerChip(item)
          ])
        : getPlayerChip("No Players found");
  }

  Widget getPlayerChip(String playerName) {
    return Chip(
        label: Text(playerName), backgroundColor: Colors.lightGreen[100]);
  }
}
