
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/GameModel.dart';
import 'WaveLoadingWidget.dart';


class AddGameWidget extends StatelessWidget {
  const AddGameWidget({
    Key key,
    @required GlobalKey<FormState> addGameFormKey,
    @required this.inputType,
    @required this.formats,
    @required this.editable,
    @required GlobalKey<ScaffoldState> scaffoldKey,
    @required BuildContext context,
  }) : _addGameFormKey = addGameFormKey, _scaffoldKey = scaffoldKey, _context = context, super(key: key);

  final GlobalKey<FormState> _addGameFormKey;
  final InputType inputType;
  final Map<InputType, DateFormat> formats;
  final bool editable;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final BuildContext _context;

  @override
  Widget build(BuildContext context) {
    TextEditingController fromDateController = TextEditingController();
    TextEditingController toDateController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController captain1Controller = TextEditingController();
    TextEditingController captain2Controller = TextEditingController();
    return Form(
      key: _addGameFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // AspectRatio(
            //     aspectRatio: 1.0,
            //     child: WaveLoadingWidget(
            //       backgroundColor: Colors.green,
            //       waveColor: Colors.red,
            //     ),
            //   ),
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
              decoration: InputDecoration(
                  labelText: 'To', hasFloatingPlaceholder: false),
              onChanged: (dt){},
            ),
            TextFormField(
              controller: locationController,
              decoration: InputDecoration(
                  labelText: 'Location', hasFloatingPlaceholder: true),
            ),
            TextFormField(
              controller: captain1Controller,
              decoration: InputDecoration(
                  labelText: 'Captain 1', hasFloatingPlaceholder: true),
            ),
            TextFormField(
              controller: captain2Controller,
              decoration: InputDecoration(
                  labelText: 'Captain 2', hasFloatingPlaceholder: true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: OutlineButton(
                highlightColor: Colors.amber,
                onPressed: () async {
                  _addGameFormKey.currentState.save();
                  DateFormat df = new DateFormat("EEE, MMM yyyy dd h:mma");
                  var fromDate = (fromDateController.text == "")
                      ? DateTime.now()
                      : df.parse(fromDateController.text);
                  var toDate = (toDateController.text == "")
                      ? DateTime.now()
                      : df.parse(toDateController.text);
                  GameModel gm = new GameModel(
                      fromDate,
                      toDate,
                      locationController.text,
                      captain1Controller.text,
                      captain2Controller.text);
                  await gm.addGame();
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