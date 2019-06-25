import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Player.dart';
import '../mixins/validation_mixin.dart';
import 'Dialogs.dart';
import '../models/TeamModel.dart';

// import '../widgets/Dialogs.dart'
class AddPlayersToTeamWidget extends StatefulWidget {
  AddPlayersToTeamWidget({
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
  _AddPlayersToTeamWidgetState createState() => _AddPlayersToTeamWidgetState();
}

class _AddPlayersToTeamWidgetState extends State<AddPlayersToTeamWidget> {
  final Firestore fireStore = Firestore.instance;
  static final _addTeamPlayersFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumController = TextEditingController();

  TeamModel teamModel, contexModel;
  @override
  Widget build(BuildContext context) {
    final Dialogs dialogs = Dialogs();

    contexModel = TeamModel.fromSnapshot(widget.teamDocument);

    return StreamBuilder<Object>(
        stream: fireStore
            .collection("Team")
            .where("TeamName", isEqualTo: contexModel.teamName)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.hasData) {
            DocumentSnapshot currentTeamSnapshot = snapshot.data.documents[0];
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  getPlayerChips(currentTeamSnapshot),
                  Form(
                    key: _addTeamPlayersFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          maxLength: 30,
                          decoration: InputDecoration(
                              labelText: 'Player Name',
                              hasFloatingPlaceholder: true),
                        ),
                        TextFormField(
                          controller: phoneNumController,
                          maxLength: 12,
                          keyboardType: TextInputType.phone,
                          // validator: validatePhone,
                          decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hasFloatingPlaceholder: true),
                        ),
                        Wrap(
                             spacing: 9.0,
                            children: <Widget>[
                              RaisedButton(
                                color: Colors.green[300],
                                highlightColor: Colors.amber,
                                onPressed: () async {
                                  // _addTeamPlayersFormKey.currentState.save();
                                  var teamName = contexModel.teamName;
                                  var playerName = nameController.text;
                                  var phoneNumber = phoneNumController.text;

                                  await updatePlayers(currentTeamSnapshot,
                                      playerName, phoneNumber);
                                  var msg = "Player $playerName added successfully.";
                                  // dialogs.information(context, "Team $teamName",msg);                                     );
                                  nameController.text = "";
                                  phoneNumController.text = "";
                                  final snackBar = SnackBar(
                                    duration: Duration(milliseconds: 100),
                                      content: Text(msg));
                                   widget._scaffoldKey.currentState.showSnackBar(snackBar);
                                },
                                
                                child: Text('Add'),
                              ),
                              OutlineButton(
                                highlightColor: Colors.amber,
                                onPressed: () async {
                                  Navigator.of(widget._context,
                                          rootNavigator: true)
                                      .pop();
                                },
                                child: Text('Close'),
                              ),
                            ])
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget getPlayerChips(DocumentSnapshot _teamSnapshot) {
    var _tModel = TeamModel.fromSnapshot(_teamSnapshot);
    List playerNames = _tModel.playerNames;
    return (playerNames != null)
        ? Wrap(alignment: WrapAlignment.start, spacing: 2, children: <Widget>[
            for (var item in playerNames) getPlayerChip(_teamSnapshot, item)
          ])
        : getPlayerChip(_teamSnapshot, "No Players found");
  }

  Widget getPlayerChip(DocumentSnapshot _teamSnapshot, String playerName) {
    return RawChip(
        onDeleted: () {
          deletePlayers(_teamSnapshot, playerName);
        },
        onPressed: (){
          nameController.text = playerName;
        },
        shadowColor: Colors.green[900],
        // avatar: CircleAvatar(
        //   backgroundColor: Colors.grey.shade800,
        //   child: Text('AB'),
        // ),
        elevation: 2,
        label: Text(playerName),
        backgroundColor: Colors.lightGreen[300]);
  }

  deletePlayers(DocumentSnapshot _teamSnapshot, String playerName) async {
    var playerNames =
        new List<String>.from(_teamSnapshot.data["PlayerName"].cast<String>());
        playerNames.remove(playerName);
        _teamSnapshot.reference.updateData({"PlayerName": playerNames});
  }

  updatePlayers(DocumentSnapshot _teamSnapshot, String playerName,
      String phoneNumber) async {
    var playerNames =
        new List<String>.from(_teamSnapshot.data["PlayerName"].cast<String>());
    playerNames.add(playerName);
    _teamSnapshot.reference.updateData({"PlayerName": playerNames});
  }
}
