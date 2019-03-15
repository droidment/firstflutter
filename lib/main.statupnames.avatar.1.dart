// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.red, secondaryHeaderColor: Colors.amber),
           navigatorObservers: <NavigatorObserver>[observer],
      home: MyStatelessWidget(),
    );
  }
}

class MyStatelessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Startup Name Generators', home: RandomWords());
  }
}

class RandomWords extends StatefulWidget {
  RandomWords({Key key, this.title, this.analytics, this.observer})
      : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  RandomWordState createState() => new RandomWordState(analytics,observer);
}

class RandomWordState extends State<RandomWords> {
  RandomWordState(this.analytics, this.observer);
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  List<Avatar> avatarList = new List<Avatar>();
  final Set<Avatar> _saved = new Set<Avatar>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    fetchAvatarsFromApi().then((dynamic avatarDynList) {
      avatarList = avatarDynList;
    });
    return Scaffold(
        appBar: AppBar(
          title: Text('Startup Name Generatorsss'),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.list), onPressed: _onShowFavorites)
          ],
        ),
        body: _buildSuggestions());
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: avatarList.length,
        //  scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          // if (index >= _suggestions.length) {
          //   _suggestions.addAll(generateWordPairs().take(10));
          // }

          return _buildRow(avatarList[index]);
        });
  }

  Widget _buildRow(Avatar avatar) {
    bool alreadySaved = false;
    if (_saved != null && _saved.length > 0) {
      Avatar _matchAvatar = _saved.firstWhere(
          (savedAvatar) => savedAvatar.name == avatar.name,
          orElse: () => null);
      alreadySaved = (_matchAvatar != null);
    }

    return ListTile(
      leading: new CircleAvatar(
          backgroundColor: Colors.orangeAccent,
          backgroundImage: NetworkImage(avatar.photo)),
      trailing: new Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null),
      title: Text(avatar.name, style: _biggerFont),
      isThreeLine: true,
      subtitle: Text(avatar.position),
      onTap: () {
        _sendAnalyticsEvent(avatar);
        setState(() {
          if (alreadySaved) {
            Avatar _matchAvatar = _saved
                .firstWhere((_savedAvatar) => _savedAvatar.name == avatar.name);
            _saved.remove(_matchAvatar);
          } else {
            _saved.add(avatar);
          }
        });
      },
    );
  }

  void _onShowFavorites() {
    Navigator.of(context).push(

      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (Avatar avatar) {
              return new ListTile(
                title: new Text(
                  avatar.name,
                  style: _biggerFont,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: new ListView(children: divided),
          );
        },
      ), 
    );
  }

  Future<void> _sendAnalyticsEvent(Avatar avatar) async {
    await analytics.logEvent(
      name: 'TeamForm App',
      parameters: <String, dynamic>{
        'name': avatar.name,
        'email': avatar.email,
        'action': 'favorite',
        'position': avatar.position
      },
    );
  }
}

Future<List<Avatar>> fetchAvatarsFromApi() async {
  final response = await http.get('https://uifaces.co/api',
      headers: {"X-API-KEY": "679b5bd8753e94156682f27dbec393"});
  // print(response.body);
  List responseJson = json.decode(response.body.toString());
  return getAvatarList(responseJson);
}

List<Avatar> getAvatarList(List data) {
  List<Avatar> list = new List();
  for (int i = 0; i < data.length; i++) {
    String name = data[i]["name"];
    String email = data[i]["email"];
    String position = data[i]["position"];
    String photo = data[i]["photo"];
    Avatar user =
        new Avatar(name: name, email: email, position: position, photo: photo);
    list.add(user);
  }
  return list;
}

class Avatar {
  String name;
  String email;
  String position;
  String photo;
  Avatar({this.name, this.email, this.position, this.photo});
}
