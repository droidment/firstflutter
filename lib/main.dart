// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.red, secondaryHeaderColor: Colors.amber),
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
  RandomWordState createState() => new RandomWordState();
}

class RandomWordState extends State<RandomWords> {
  
  List<Avatar> avatarList = new List<Avatar>();
  final Set<Avatar> _saved = new Set<Avatar>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    fetchAvatarsFromApi().then((dynamic avatarDynList){
        avatarList = avatarDynList;
    });
    return Scaffold(
        appBar: AppBar(
          title: Text('Startup Name Generator'),
        ),
        body: _buildSuggestions());
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
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
    final bool alreadySaved = _saved.contains(avatar);
    return ListTile(
      leading: new CircleAvatar(
        backgroundColor: Colors.orangeAccent, backgroundImage: NetworkImage(avatar.photo)
      ),
      trailing: new Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null),
      title: Text(avatar.name, style: _biggerFont),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(avatar);
          } else {
            _saved.add(avatar);
          }
        });
      },
    );
  }
}

Future<List<Avatar>> fetchAvatarsFromApi() async {
  final response = await http.get('https://uifaces.co/api',
      headers: {"X-API-KEY": "679b5bd8753e94156682f27dbec393"});
  print(response.body);
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
    Avatar user = new Avatar(
        name: name, email: email, position: position, photo: photo);
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
