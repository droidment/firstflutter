
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firstflut/screens/teamList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firstflut/widgets/AddGameWidget.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key key,
    @required GlobalKey<FormState> addGameFormKey,
    @required this.inputType,
    @required this.formats,
    @required this.editable,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  }) : _addGameFormKey = addGameFormKey, _scaffoldKey = scaffoldKey, super(key: key);

  final GlobalKey<FormState> _addGameFormKey;
  final InputType inputType;
  final Map<InputType, DateFormat> formats;
  final bool editable;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Raj Balakrishnan"),
            accountEmail: Text("raj@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor:
                  Theme.of(context).platform == TargetPlatform.iOS
                      ? Colors.blue
                      : Colors.white,
              child: Text(
                "A",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            title: Text("Games"),
            onTap: () {
              Navigator.pop(context);
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
          ListTile(
            title: Text("Teams"),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(new PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) {
                return new TeamList();
              }, transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                return new FadeTransition(opacity: animation, child: child);
              }));
            },
          ),
          ListTile(
            title: Text("Clubs"),
            onTap: () {
              Navigator.pop(context);
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
        ],
      ),
    );
  }
}