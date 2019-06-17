import 'package:flutter/material.dart';
import '../mixins/AppConstants.dart';
class AppHeader extends StatelessWidget {
   const AppHeader({
    Key key,
    this.title
  }) : super(key: key);
  final String title;
 
  @override
  Widget build(BuildContext context) {
    String titleString = title ?? AppConstantsMixin.AppTitle;
    return SliverAppBar(
        expandedHeight: 100.0,
        floating: false,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(titleString,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  Shadow(
                    offset: Offset(3.0, 3.0),
                    blurRadius: 8.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              )),
          background: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset("assets/volleyball_masthead.jpg",
                  fit: BoxFit.fill)),
        ));
  }
}