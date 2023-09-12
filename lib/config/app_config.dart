import 'package:flutter/material.dart';

import '../Theme/style.dart';

class AppConfig {

  ////////////////////////////////////////
  //       SERVER CONFIGURATION         //
  ////////////////////////////////////////

  // Host URL (Replace it with your host)
  // Do not add "/" at the end
  static const URL = 'https://mix.nex-nova.com';
  // static const URL = 'http://10.0.2.2:8000';
  // static const URL = 'http://127.0.0.1:8000';

  ////////////////////////////////////////
  //           SPLASH SCREEN            //
  ////////////////////////////////////////

  static const AppName = 'Food Recipes';

  ////////////////////////////////////////
  //         APP CONFIGURATION          //
  ////////////////////////////////////////

  // pagination settings
  // the number of recipes to load per page
  static const PerPage = 20;

  // set the ads state, set it to false if you want to hide ads
  static const AdmobEnabled = false;

  // enabled or disabled terms and conditions page in settings
  static const TermsAndConditionsEnabled = true;

  // the primary theme color, change it to your prefered color, by default it is green
  static const primaryColor = Colors.green;

  ////////////////////////////////////////
  //          APP IDENTIFIERS           //
  ////////////////////////////////////////

  // Used to enable the rating feature of the application

  // Google Play package name
  static const GooglePlayIdentifier =
      'com.royhayek.flutterfoodrecipes'; //example: com.companyname.appname

  // AppStore identifier
  static const AppStoreIdentifier = '1491556149'; // example: 1491556149


  ////////////////////////////////////////
  //             APP SHARING            //
  ////////////////////////////////////////

  // Title and text that appear when sharing a recipe
  static const sharingRecipeTitle = 'Food Recipes App';
  static const sharingRecipeText =
      'Download Food Recipes app for FREE to check out more healthy meal!';

  // Title and text that appear when sharing the application
  static const sharingAppTitle = 'Food Recipes App';
  static const sharingAppText =
      'Download Food Recipes App for FREE to check out more recipes!';
  static const sharingAppGoogleLink =
      "https://play.google.com/store/apps/details?id=${AppConfig.GooglePlayIdentifier}";
  static const sharingAppAppleLink =
      "https://apps.apple.com/de/app/bbqianer/id${AppConfig.AppStoreIdentifier}";
}
