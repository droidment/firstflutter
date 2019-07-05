import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstflut/models/Player.dart';
import 'package:firstflut/widgets/AddPlayersToTeam.dart';
import 'package:flutter/material.dart';

import '../widgets/Dialogs.dart';
import '../mixins/validation_mixin.dart';
import '../models/TeamModel.dart';

class TeamWidget extends StatefulWidget {
  TeamWidget({
    Key key,
    @required this.teamDocument,
    @required GlobalKey<ScaffoldState> scaffoldKey,
    @required BuildContext context,
  })  : _scaffoldKey = scaffoldKey,
        _context = context,
        super(key: key);

  DocumentSnapshot teamDocument;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final BuildContext _context;
  @override
  TeamState createState() => TeamState();
}

class TeamState extends State<TeamWidget> with ValidationMixin {
  DocumentReference currentTeamReference;
  TextEditingController teamNameController = TextEditingController();
  TextEditingController homeCourtController = TextEditingController();
  TextEditingController adminContactController = TextEditingController();
  TextEditingController waitlistController = TextEditingController();
  Dialogs dialogs = Dialogs();
  TeamModel teamModel, contextModel;
  bool isUpdate = false;
  @override
  Widget build(BuildContext _context) {
     return Scaffold(body: _buildAddTeam(context));
    // return _buildAddTeam(_context);
  }

  Widget _buildAddTeam(BuildContext _context) {
    if (widget.teamDocument != null) {
      isUpdate = true;
      contextModel = TeamModel.fromSnapshot(widget.teamDocument);
      teamNameController.text = contextModel.teamName;
      homeCourtController.text = contextModel.homeCourt;
      adminContactController.text = contextModel.adminName;
      waitlistController.text = contextModel.waitlistCount;
      
    } else {
      contextModel = new TeamModel(
          new List(),
          teamNameController.text,
          homeCourtController.text,
          adminContactController.text,
          true,
          true,
          waitlistController.text);
    }

    return Form(
      // key: _scaffoldKey,
      child: ListView(children: <Widget>[
        TextFormField(
          controller: teamNameController,
          keyboardType: TextInputType.text,
          validator: validateInput,
          maxLength: 32,
          decoration: InputDecoration(
              labelText: 'Team Name', hasFloatingPlaceholder: true),
        ),
        TextFormField(
          controller: homeCourtController,
          maxLength: 100,
          keyboardType: TextInputType.text,
          validator: validateInput,
          decoration: InputDecoration(
              labelText: 'Home Court Address', hasFloatingPlaceholder: true),
        ),
        TextFormField(
          controller: adminContactController,
          maxLength: 40,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              labelText: 'Admin Contact', hasFloatingPlaceholder: true),
        ),

        SwitchListTile(
            value: true,
            title: const Text("Allow Maybe"),
            onChanged: (value) {
              contextModel.allowMaybe = value;
              // setState(() {});
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green),
        SwitchListTile(
            value: true,
            title: const Text("Allow Guest"),
            onChanged: (value) {
              contextModel.allowGuest = value;
              // setState(() {});
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green),
        TextFormField(
          controller: waitlistController,
          maxLength: 2,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: 'Waitlist Count', hasFloatingPlaceholder: true),
        ),
        Wrap(spacing: 9.0,
            // child: ButtonBar(
            //     mainAxisSize: MainAxisSize.max,
            //     alignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                color: Colors.greenAccent,
                highlightColor: Colors.amber,
                onPressed: () async {
                  DocumentReference teamRef =
                      await onSaveTeam(contextModel, _context);
                  // dialogs
                  //     .confirmDialog(context, "Add Players",
                  //         "Do you want to add members to this team?")
                  //     .then((onValue) {
                  //   if (onValue == ConfirmAction.ACCEPT) {
                  //     String teamName = currentTeamReference.toString();
                  //     showDialog(
                  //         context: context,
                  //         builder: (_) => new AlertDialog(
                  //             title:
                  //                 new Text("Add players to the team $teamName"),
                  //             content: AddPlayersToTeamWidget(
                  //                 teamReference: teamRef, scaffoldKey: _scaffoldKey,context: _context )));
                  //   }
                  // });
                },
                child: Text('Save'),
              ),
              // RaisedButton(
              //   color: Colors.greenAccent,
              //   highlightColor: Colors.amber,
              //   onPressed: () {
              //     String teamName = currentTeamReference.toString();
              //     showDialog(
              //         context: context,
              //         builder: (_) => new AlertDialog(
              //             title: new Text("Add players to the team $teamName"),
              //             content:
              //                 _buildAddPlayers(context, currentTeamReference)));
              //   },
              //   child: Text('Add Players'),
              // )
            ]),
        // ),
        // _buildList(_context, team.playerNames),
      ]),
    );
  }

  Future<DocumentReference> onSaveTeam(
      TeamModel team, BuildContext _context) async {
    DocumentReference teamReference = await saveTeamDetails(team);
    
    String teamName = team.teamName;
    dialogs.information(
        context, "Team $teamName", "Team $teamName created successfully.");
    Navigator.of(_context, rootNavigator: true).pop();
    return teamReference;
  }

  Future<DocumentReference> saveTeamDetails(TeamModel team) async {
    if (team.teamName.isEmpty) {
      throw Exception;
    }
    if(isUpdate){
      await team.updateTeam(widget.teamDocument.reference);
    }else{
      await team.addTeam;
    }
    return currentTeamReference;
  }

  // Widget _buildList(BuildContext context, List<String> playerNames) {
  //   if (playerNames == null || playerNames.length == 0) {
  //     return Spacer();
  //   } else {
  //     return ListView.builder(
  //         itemCount: playerNames.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           return ListTile(
  //               title: Text(
  //             playerNames[index],
  //           ));
  //         });
  //   }
  // }

  Future addPlayersToTeam(
      DocumentReference teamReference, PlayerModel player) async {
    // Future<DocumentSnapshot> team = teamReference.get();
    // team.
    // String playerNames[];

    teamReference.updateData({
      "PlayerNames": [player.playerName]
    });
    // currentTeamReference.updateData({"PlayerNames": player.name});
  }
}
// }
