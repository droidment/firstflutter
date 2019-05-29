import 'package:flutter/material.dart';

class Notes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NotesState();
}

class NotesState extends State<Notes> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // List<Note> _notes = <Note>[];
  // int _limit = 50;
  // NotePresenter _presenter;
  bool _isLoading = true;
  // NoteProvider _provider = new NoteProvider();

  @override
  void initState() {
    super.initState();

    _isLoading = true;
    
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(),
      body: SafeArea(
        child: this._isLoading
            ? Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: <Widget>[
                  // _silverAppBar(),
                  _silverList(),
                ],
              ),
      ),
      bottomNavigationBar: _bottomAppBar(),
    );
  }

  Widget _silverList() {
    return SliverList(
      
    );
  }

  // Widget _silverAppBar() {
  //   return SearchBar(
  //     searchCallBack: () {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text('Implement Search'),
  //           );
  //         },
  //       );
  //     },
  //     menuCallBack: () {
  //       _scaffoldKey.currentState.openDrawer();
  //     },
  //     profileCallback: () {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text('Implement Profile'),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _bottomAppBar() {
    return BottomAppBar(
      child: InkWell(
        
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.all(3),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "takeANote",
                  style: Theme.of(context).textTheme.button,
                ),
              ),
              Container(
                child: Icon(Icons.add),
              )
            ],
          ),
        ),
      ),
    );
  }

 
}