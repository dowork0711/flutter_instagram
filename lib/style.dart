import 'package:flutter/material.dart';

var theme = ThemeData(
  iconTheme: IconThemeData(color: Colors.black),
  appBarTheme: AppBarTheme(
    color: Colors.white,
    elevation: 1,
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
    actionsIconTheme: IconThemeData(color: Colors.black),
  ),
  textTheme: TextTheme(
      bodyText2: TextStyle(color: Colors.black)
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.black
  ),
);