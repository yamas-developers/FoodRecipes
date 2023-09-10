import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_recipes_app/config/admob_config.dart';
import 'package:food_recipes_app/config/app_config.dart';
import 'package:food_recipes_app/database/cookbook_db_helper.dart';
import 'package:food_recipes_app/models/app_user.dart';
import 'package:food_recipes_app/models/comment.dart';
import 'package:food_recipes_app/models/recipe.dart';
import 'package:food_recipes_app/providers/app_provider.dart';
import 'package:food_recipes_app/providers/auth_provider.dart';
import 'package:food_recipes_app/screens/Other/profile/profile_screen.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:food_recipes_app/utils/utils.dart';
import 'package:food_recipes_app/widgets/shimmer_widget.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class RecipeFavoriteScreen extends StatefulWidget {
  static const routeName = '/recipe-favorite';

  final Recipe? recipe;
  final String? route;

  RecipeFavoriteScreen({this.recipe, this.route});

  @override
  _RecipeFavoriteScreenState createState() => _RecipeFavoriteScreenState();
}

class _RecipeFavoriteScreenState extends State<RecipeFavoriteScreen> {
  var db = new CookBookDatabaseHelper();

  TextEditingController? _commentTextController;
  int? savedRecipeId;
  bool _favorated = false;

  AuthProvider? _authProvider;
  AppProvider? _appProvider;

  @override
  void initState() {
    super.initState();

    _commentTextController = TextEditingController();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

    // _loadAndShowAds();
  }

  void dispose() {
    _commentTextController!.dispose();
    super.dispose();
  }

  // From local database
  Future _getRecipeIfExist() async {
    await db.checkIfRecipeExists(widget.recipe!.id!).then((state) {
      setState(() {
        _favorated = state;
      });
    });
  }

  _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: _body(),
    );
  }

  _body() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: 55, top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Row(
            //   children: [
            //     buildBackButton(context, padding: EdgeInsets.zero),
            //   ],
            // ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
              child: Text(
                'favorites'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 32, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildBack() {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 25),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: new CircleBorder(),
            ),
            child: Icon(Icons.arrow_back, size: 25, color: Colors.black),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
      ],
    );
  }

  _buildSocialButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 175, 20, 0),
      child: Column(
        children: [
          widget.recipe!.websiteUrl!.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _launchURL(widget.recipe!.websiteUrl!),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: _buildWebsiteButton(),
                    ),
                  ),
                )
              : Container(),
          widget.recipe!.youtubeUrl!.isNotEmpty
              ? GestureDetector(
                  onTap: () => _launchURL(widget.recipe!.youtubeUrl!),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      'assets/images/watch_on_youtube.png',
                      width: 100,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  _buildWebsiteButton() {
    return Container(
      width: 85,
      height: 28,
      child: Center(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.web, color: Colors.white),
            ),
            Expanded(
              child: Text(
                'VISIT WEBSITE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
    );
  }

// _buildAddToFavoriteButton() {
//   return InkWell(
//     child: _favorated
//         ? Icon(Icons.favorite, color: Colors.red, size: 27)
//         : Icon(Icons.favorite_border, color: Colors.red, size: 27),
//     onTap: _addToFavorite,
//   );
// }
}
