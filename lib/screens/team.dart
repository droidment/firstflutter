import 'package:flutter/material.dart';
import '../models/TeamModel.dart';

class Team extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TeamState();
}

class TeamState extends State<Team> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey, body: SafeArea(child: _buildAddTeam(context)));
  }

  Widget _buildAddTeam(BuildContext _context) {
    
    TextEditingController teamNameController = TextEditingController();
    TextEditingController homeCourtController = TextEditingController();
    TextEditingController adminContactController = TextEditingController();
    TeamModel team = new TeamModel(
                        new List(),
                        teamNameController.text,
                        homeCourtController.text,
                        adminContactController.text,
                        true,
                        true,
                        0,
                        true);
    return Form(
      // key: _scaffoldKey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: teamNameController,
                decoration: InputDecoration(
                    labelText: 'Team Name', hasFloatingPlaceholder: true),
              ),
              TextFormField(
                controller: homeCourtController,
                decoration: InputDecoration(
                    labelText: 'Home Court Address',
                    hasFloatingPlaceholder: true),
              ),
              TextFormField(
                controller: adminContactController,
                decoration: InputDecoration(
                    labelText: 'Admin Contact', hasFloatingPlaceholder: true),
              ),


              _buildList(_context,team.playerNames),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: OutlineButton(
                  highlightColor: Colors.amber,
                  onPressed: () async {
                    
                    var teamName = team.teamName;
                    await team.addTeam();
                    _scaffoldKey.currentState.showSnackBar(new SnackBar(
                      content: new Text("Team $teamName created successfully."),
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
      ),
    );
  }
  ListView _buildList(BuildContext context, List<String> playerNames) {
    return ListView.builder(
      itemCount: playerNames.length,
      padding: const EdgeInsets.only(top: 16.0),
      itemBuilder: (BuildContext context, int index){
        return ListTile(title: Text(playerNames[index]));
      }
    );
  }
}