import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstflut/models/Players.dart';
import 'package:flutter/material.dart';

import '../mixins/validation_mixin.dart';
import '../models/TeamModel.dart';

class Team extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TeamState();
}

class TeamState extends State<Team> with ValidationMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DocumentReference currentTeamReference;
  TextEditingController teamNameController = TextEditingController();
    TextEditingController homeCourtController = TextEditingController();
    TextEditingController adminContactController = TextEditingController();
    TextEditingController waitlistController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey, body: _buildAddTeam(context));
  }

  Widget _buildAddTeam(BuildContext _context) {
    
    TeamModel team = new TeamModel(
        new List(),
        teamNameController.text,
        homeCourtController.text,
        adminContactController.text,
        true,
        true,
        waitlistController.text);
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
        TextFormField(
          controller: waitlistController,
          maxLength: 2,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: 'Waitlist Count', hasFloatingPlaceholder: true),
        ),
        SwitchListTile(
            
            value: true,
            title: const Text("Allow Maybe"),
            onChanged: (value) {
              team.allowMaybe = value;
              // setState(() {});
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green),
        SwitchListTile(
            value: true,
            title: const Text("Allow Guest"),
            onChanged: (value) {
              team.allowGuest = value;
              // setState(() {});
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green),

        Wrap(spacing: 9.0,
            // child: ButtonBar(
            //     mainAxisSize: MainAxisSize.max,
            //     alignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                color: Colors.greenAccent,
                highlightColor: Colors.amber,
                onPressed: () async {
                  String teamName = await saveTeamDetails(team);
                  _scaffoldKey.currentState.showSnackBar(new SnackBar(
                    content: new Text("Team $teamName created successfully."),
                  ));
                  Navigator.of(_context, rootNavigator: true).pop();
                },
                child: Text('Save'),
              ),
              RaisedButton(
                color: Colors.greenAccent,
                highlightColor: Colors.amber,
                onPressed: () {
                  String teamName = currentTeamReference.toString();
                  showDialog(
                      context: context,
                      builder: (_) => new AlertDialog(
                          title: new Text("Add players to the team $teamName"),
                          content:
                              _buildAddPlayers(context, currentTeamReference)));
                },
                child: Text('Add Players'),
              )
            ]),
        // ),
        // _buildList(_context, team.playerNames),
      ]),
    );
  }

  Future<String> saveTeamDetails(TeamModel team) async {
    if (team.teamName.isEmpty) {
      throw Exception;
    }
    var teamName = team.teamName;
    await team.addTeam.then((reference) {
      currentTeamReference = reference;
    });
    return teamName;
  }

  Future addPlayersToTeam(PlayersBloc player, TeamModel team) async {
    if (currentTeamReference == null) {
      await saveTeamDetails(team);
      // currentTeamReference.updateData({"PlayerNames": player.name});
    }
  }

  Widget _buildList(BuildContext context, List<String> playerNames) {
    if (playerNames == null || playerNames.length == 0) {
      return Spacer();
    } else {
      return ListView.builder(
          itemCount: playerNames.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                title: Text(
              playerNames[index],
            ));
          });
    }
  }

  Widget _buildAddPlayers(
      BuildContext _context, DocumentReference teamReference) {
    // return SingleChildScrollView(child: DynamicFieldsWidget());

    TextEditingController nameController = TextEditingController();
    TextEditingController phoneNumController = TextEditingController();
    // TeamModel teamModel = TeamModel.fromSnapshot(teamReference.().first);

    return Form(
      // key: _addTeamPlayersFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              keyboardType: TextInputType.text,
              maxLength: 30,
              decoration: InputDecoration(
                  labelText: 'Player Name', hasFloatingPlaceholder: true),
            ),
            TextFormField(
              controller: phoneNumController,
              maxLength: 12,
              keyboardType: TextInputType.phone,
              validator: validatePhone,
              decoration: InputDecoration(
                  labelText: 'Phone Number', hasFloatingPlaceholder: true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: OutlineButton(
                highlightColor: Colors.amber,
                onPressed: () async {
                  // PlayersBloc player = new PlayersBloc(
                  //     nameController.text
                  //     );
                  // await addPlayersToTeam(player,teamModel);

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
}
