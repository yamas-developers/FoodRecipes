import 'package:flutter/material.dart';

import 'colors.dart';

final ThemeData appTheme = ThemeData(
  highlightColor: Color(0xff707070).withOpacity(0.2),
  shadowColor: tabColor,
  cardColor: cardColor,
  unselectedWidgetColor: Colors.grey[300],
  fontFamily: 'ProductSans',
  tabBarTheme: TabBarTheme(unselectedLabelColor: primaryColor),
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(size: 13, color: Colors.black)),
  scaffoldBackgroundColor: Colors.white,
  dividerColor: Colors.grey[200],
  primaryColor: primaryColor,
  backgroundColor: Colors.white,
  textTheme: TextTheme(
      button: TextStyle(color: Colors.white),
      bodyText1: TextStyle(
          color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
      bodyText2: TextStyle(
          color: fontSecondary, fontSize: 11, fontWeight: FontWeight.w500),
      headline1: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),
      headline2: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: TextStyle(color: Color(0xff4d4d4d))),
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  highlightColor: Colors.white.withOpacity(0.3),
  shadowColor: Color(0xff242424),
  cardColor: Color(0xff5a5341),
  unselectedWidgetColor: Colors.grey[300],
  tabBarTheme: TabBarTheme(unselectedLabelColor: primaryColor),
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(size: 13, color: Colors.white)),
  scaffoldBackgroundColor: Colors.black,
  dividerColor: Color(0xff242424),
  primaryColor: primaryColor,
  backgroundColor: Color(0xff242424),
  textTheme: TextTheme(
      button: TextStyle(color: Colors.white),
      bodyText1: TextStyle(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      bodyText2: TextStyle(
          color: fontSecondary, fontSize: 11, fontWeight: FontWeight.w500),
      headline1: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),
      headline2: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: TextStyle(color: Colors.grey[500])),
);
