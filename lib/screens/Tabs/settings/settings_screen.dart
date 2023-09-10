import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:food_recipes_app/Theme/colors.dart';
import 'package:food_recipes_app/config/app_config.dart';
import 'package:food_recipes_app/main.dart';
import 'package:food_recipes_app/providers/auth_provider.dart';
import 'package:food_recipes_app/screens/Auth/login/login_screen.dart';
import 'package:food_recipes_app/screens/Other/profile/profile_screen.dart';
import 'package:food_recipes_app/screens/Tabs/settings/cookbook/cookbook_screen.dart';
import 'package:food_recipes_app/screens/Tabs/settings/following-followers/following_followers_screen.dart';
import 'package:food_recipes_app/screens/Tabs/settings/information-screen/information_screen.dart';
import 'package:food_recipes_app/screens/Tabs/settings/profile-edit/profile_edit_screen.dart';
import 'package:food_recipes_app/screens/Tabs/settings/user-recipes/user_recipes_screen.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:food_recipes_app/widgets/shimmer_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../providers/app_provider.dart';
import '../../Auth/intro_screen.dart';
import 'languages/languages_screen.dart';

final BaseCacheManager baseCacheManager = DefaultCacheManager();

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings_screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AuthProvider? _authProvider;
  // bool isDarkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_authProvider!.user != null) _authProvider!.getFollowingFollowers();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   setState(() {
    //     isDarkModeEnabled = Theme.of(context).brightness == Brightness.dark;
    //   });
    // });
  }

  _logout() async {
    final GoogleSignIn _googleSignIn = new GoogleSignIn();
    final fbAccessToken = await FacebookAuth.instance.accessToken;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    if (await _googleSignIn.isSignedIn()) {
      await _auth.signOut().then((_) {
        _googleSignIn.signOut();
      });
    } else if (fbAccessToken != null) {
      await _auth.signOut().then((_) async {
        await FacebookAuth.instance.logOut();
      });
    }
    Provider.of<AuthProvider>(context, listen: false).logout();
    _navigateToIntroScreen();
  }

  _navigateToIntroScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      IntroScreen.routeName,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _body(),
      ),
    );
  }

  _body() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 35, bottom: 15),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => auth.user != null
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => ProfileScreen(
                                user: _authProvider!.user!,
                              ),
                            ),
                          )
                        : null,
                    child: Column(
                      children: [
                        // _buildUserImage(auth),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 22),
                              child: Text(
                                'account'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        _buildUserName(auth),
                        SizedBox(height: 0),
                      ],
                    ),
                  ),
                  // auth.user != null
                  //     ? _buildFollowingFollowers(auth)
                  //     : Container(),
                ],
              ),
            ),
            _buildButtonsList(auth),
          ],
        );
      },
    );
  }

  _buildUserImage(AuthProvider auth) {
    if (auth.user != null && auth.user?.image != null) {
      return (auth.user!.image!.contains('https'))
          ? CachedNetworkImage(
              imageUrl: '${auth.user!.image}',
              imageBuilder: (context, imageProvider) => Container(
                width: 85.0,
                height: 85.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => ShimmerWidget(
                width: 85,
                height: 85,
                circular: true,
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            )
          : CachedNetworkImage(
              imageUrl: '${ApiRepository.USER_IMAGES_PATH}${auth.user!.image}',
              imageBuilder: (context, imageProvider) => Container(
                width: 85.0,
                height: 85.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) =>
                  ShimmerWidget(width: 85, height: 85, circular: true),
              errorWidget: (context, url, error) => Icon(Icons.error),
            );
    } else
      return CircleAvatar(
        backgroundColor: Colors.white,
        child: Image.asset('assets/images/logo_user.png'),
        radius: 40,
      );
  }

  _buildUserName(AuthProvider auth) {
    return Text(auth.user != null ? auth.user!.name! : 'Guest',
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(fontSize: 26, fontWeight: FontWeight.w700));
  }

  // _buildFollowingFollowers(AuthProvider auth) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       _buildButtonCount(
  //         index: 1,
  //         count: auth.followingUsers.length,
  //         text: 'following'.tr(),
  //       ),
  //       _buildButtonCount(
  //         index: 0,
  //         count: auth.followerUsers.length,
  //         text: 'followers'.tr(),
  //       ),
  //     ],
  //   );
  // }

  _buildButtonCount({int? index, String? text, int? count}) {
    return GestureDetector(
      onTap: () async => await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => FollowingFollowersScreen(index: index),
        ),
      ),
      child: Column(
        children: [
          Text(text!, style: GoogleFonts.ubuntu(fontSize: 16)),
          Text('$count', style: GoogleFonts.ubuntu(fontSize: 16))
        ],
      ),
    );
  }

  _buildButtonsList(auth) {
    return Expanded(
      child: Consumer<AppProvider>(
        builder: (context, AppProvider appProvider, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    InkWell(
                      onTap: () async => auth.user != null
                          ? await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(),
                              ),
                            )
                          : await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IntroScreen(),
                              ),
                            ),
                      child: auth.user != null
                          ? _listViewItem(
                              context,
                              Icons.person_pin,
                              'my_profile'.tr(),
                            )
                          : _listViewItem(
                              context,
                              Icons.person_pin,
                              'login_or_create_account'.tr(),
                            ),
                    ),
                    Divider(height: 1.5, indent: 15, endIndent: 15),
                    auth.user != null
                        ? Column(
                            children: [
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyRecipesScreen(),
                                  ),
                                ),
                                child: _listViewItem(
                                  context,
                                  Icons.assignment,
                                  'my_recipes'.tr(),
                                ),
                              ),
                              Divider(height: 1.5, indent: 15, endIndent: 15),
                            ],
                          )
                        : Container(),
                    auth.user != null
                        ? InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CookbookScreen()),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Image.asset(
                                      'assets/images/ic_cookbook_black.png',
                                      width: 24,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'my_cookbook'.tr(),
                                    style: GoogleFonts.roboto(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 7),
                          child: Text(
                            'other'.tr(),
                            style: GoogleFonts.roboto(
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LanguagesScreen(),
                        ),
                      ),
                      child: _listViewItem(
                        context,
                        Icons.dark_mode,
                        'dark_mode'.tr(),
                        trailing: Switch(
                          value: appProvider.isDark,
                          activeColor: primaryColor,
                          onChanged: (newValue) {
                            setState(() {
                              appProvider.isDark = newValue;
                            });
                            // Toggle between light and dark themes based on the switch state
                            context.read<AppProvider>().setTheme();
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LanguagesScreen(),
                        ),
                      ),
                      child: _listViewItem(
                        context,
                        Icons.language,
                        'languages'.tr(),
                      ),
                    ),
                    Divider(height: 1.5, indent: 15, endIndent: 15),
                    InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InformationScreen(
                              information: 'privacy_policy'.tr(),
                            ),
                          )),
                      child: _listViewItem(
                          context, Icons.description, 'privacy_policy'.tr()),
                    ),
                    Divider(height: 1.5, indent: 15, endIndent: 15),
                    AppConfig.TermsAndConditionsEnabled
                        ? Column(
                            children: [
                              InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InformationScreen(
                                        information: 'terms_and_conditions'.tr(),
                                      ),
                                    )),
                                child: _listViewItem(context, Icons.info,
                                    'terms_and_conditions'.tr()),
                              ),
                              Divider(height: 1.5, indent: 15, endIndent: 15),
                            ],
                          )
                        : Container(),
                    InkWell(
                      onTap: () => LaunchReview.launch(
                          androidAppId: AppConfig.GooglePlayIdentifier,
                          iOSAppId: AppConfig.AppStoreIdentifier),
                      child:
                          _listViewItem(context, Icons.rate_review, 'rate_us'.tr()),
                    ),
                    Divider(height: 1.5, indent: 15, endIndent: 15),
                    InkWell(
                      onTap: () => _shareApp(),
                      child: _listViewItem(context, Icons.share, 'share_app'.tr()),
                    ),
                    auth.user != null
                        ? Column(
                            children: [
                              Divider(height: 1.5, indent: 15, endIndent: 15),
                              InkWell(
                                onTap: () => _logout(),
                                child: _listViewItem(
                                    context, Icons.exit_to_app, 'logout'.tr(),
                                    color: Colors.red),
                              ),
                              SizedBox(height: 20),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  _listViewItem(BuildContext context, IconData icon, String text,
      {Color? color, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: color != null ? color : Colors.black),
          ),
          SizedBox(width: 15),
          Text(
            text,
            style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: color != null ? color : null),
          ),
          Spacer(),
          trailing ??
              Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color:
                    color != null ? color : Theme.of(context).iconTheme.color,
              ),
        ],
      ),
    );
  }

  void _shareApp() {
    if (Platform.isAndroid) {
      Share.share(
        '${AppConfig.sharingAppText} \n ${AppConfig.sharingAppGoogleLink} ',
        subject: '${AppConfig.sharingAppText}',
      );
    } else if (Platform.isIOS) {
      Share.share(
        '${AppConfig.sharingAppText} \n ${AppConfig.sharingAppAppleLink} ',
        subject: '${AppConfig.sharingAppText}',
      );
    }
  }
}
