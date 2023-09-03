import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info/device_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_recipes_app/models/app_user.dart';
import 'package:food_recipes_app/preferences/session_manager.dart';
import 'package:food_recipes_app/providers/app_provider.dart';
import 'package:food_recipes_app/providers/auth_provider.dart';
import 'package:food_recipes_app/providers/category_provider.dart';
import 'package:food_recipes_app/providers/cuisine_provider.dart';
import 'package:food_recipes_app/providers/recipe_provider.dart';
import 'package:food_recipes_app/screens/Auth/login/login_screen.dart';
import 'package:food_recipes_app/screens/Auth/login/widgets/custom_divider.dart';
import 'package:food_recipes_app/screens/Auth/login/widgets/social_media_button.dart';
import 'package:food_recipes_app/screens/Auth/register/register_screen.dart';
import 'package:food_recipes_app/screens/Tabs/tabs_screen.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:food_recipes_app/widgets/custom_text_field.dart';
import 'package:food_recipes_app/widgets/default_custom_button.dart';
import 'package:food_recipes_app/widgets/progress_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../Theme/colors.dart';

class IntroScreen extends StatefulWidget {
  static const routeName = '/intro';

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SessionManager prefs = SessionManager();
  late AppProvider application;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late String _deviceName;

  void initState() {
    super.initState();
    application = Provider.of<AppProvider>(context, listen: false);

    SystemChannels.textInput.invokeMethod('TextInput.hide');

    getDeviceName();
  }

  void getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceName = iosInfo.utsname.machine;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    return Scaffold(
      body: _body(queryData),
    );
  }

  _buildBackgroundImage() {
    return Container(
      child: Stack(children: [
        Opacity(
          opacity: 0.1,
          child: Image.asset(
            'assets/images/logo.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ]),
    );
  }

  _body(MediaQueryData queryData) {
    return SingleChildScrollView(
      child: Container(
        height: queryData.size.height,
        child: Stack(
          children: <Widget>[
            _buildBackgroundImage(),
            _buildLoginScreen(queryData),
          ],
        ),
      ),
    );
  }

  _buildLoginScreen(MediaQueryData queryData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, TabsScreen.routeName, (context) => false),
              child: Text(
                'skip'.tr().toUpperCase(),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Theme.of(context).primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: queryData.size.width / 8),
            child: Column(
              children: [
                SizedBox(height: 40),
                GestureDetector(
                  onTap: () => _navigateToRegisterScreen(),
                  child: _getStartedText(),
                ),
                SizedBox(height: 20),
                _buildLanguagesIcons(),
                SizedBox(height: 20),
                AuthCustomButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                    title: 'sign_in'.tr()),
                SizedBox(height: 14),
                AuthCustomButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()));
                    },
                    title: 'sign_up'.tr()),
                SizedBox(height: 14),
                _buildSocialButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _getStartedText() {
    return FittedBox(
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AutoSizeText(
            'get_started'.tr(),
            minFontSize: 13,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
    );
  }

  _buildSocialButtons() {
    return Column(
      children: [
        SocialMediaButton(
          text: 'sign_in_with_google'.tr(),
          image: Image.asset('assets/images/ic_google.png', width: 25),
          color: Color(0xffdb4a39),
          function: signInUsingGoogle,
        ),
        SizedBox(height: 15),
        SocialMediaButton(
          text: 'sign_in_with_facebook'.tr(),
          image: Image.asset('assets/images/ic_facebook.png', width: 22),
          color: Color(0xff3b5998),
          function: signInUsingFacebook,
        ),
      ],
    );
  }

  _buildLanguagesIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _languageIconButton(
          'assets/images/flag_ar.png',
          () {
            context.setLocale(Locale('ar', 'AL'));
            _emptyLists();
          },
        ),
        _languageIconButton(
          'assets/images/flag_fr.png',
          () {
            context.setLocale(Locale('fr', 'FR'));
            _emptyLists();
          },
        ),
        _languageIconButton(
          'assets/images/flag_us.png',
          () {
            context.setLocale(Locale('en', 'US'));
            _emptyLists();
          },
        ),
      ],
    );
  }

  _emptyLists() {
    Provider.of<RecipeProvider>(context, listen: false).emptyRecipeLists();
    Provider.of<CategoryProvider>(context, listen: false).emptyCategoryLists();
    Provider.of<CuisineProvider>(context, listen: false).emptyCuisineLists();
    Provider.of<AppProvider>(context, listen: false).emptyDifficultiesLists();
  }

  _languageIconButton(String image, Function onTap) {
    return InkWell(
      onTap: () => onTap(),
      child: SizedBox(
        width: 55,
        child: Card(
          shape: CircleBorder(side: BorderSide(width: 0, color: Colors.white)),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Image.asset(image, width: 40),
          ),
        ),
      ),
    );
  }

  _navigateToRegisterScreen() async {
    await Navigator.of(context)
        .pushNamed(RegisterScreen.routeName)
        .then((value) {
      setState(() {
        FocusScope.of(context).unfocus();
      });
    });
  }

  _navigateToTabsScreen() {
    Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);
  }

  signInUsingGoogle() async {
    try {
      loadingDialog(context).show();
      User? firebaseUser;
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication?.accessToken,
        idToken: googleSignInAuthentication?.idToken,
      );

      print('access token: ${googleSignInAuthentication?.accessToken}');
      firebaseUser = (await _auth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        AppUser _user = AppUser(
          authKey: firebaseUser.uid,
          email: firebaseUser.email!,
          image: firebaseUser.photoURL!,
          name: firebaseUser.displayName!,
        );

        bool authenticated =
            await Provider.of<AuthProvider>(context, listen: false)
                .loginUsingSocial(context, _user, _deviceName);

        await loadingDialog(context).hide();
        print(authenticated);

        if (authenticated) {
          _navigateToTabsScreen();
        }
      }
    } catch (error) {
      print(error);
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_LONG,
      );
      loadingDialog(context).hide();
    }
  }

  signInUsingFacebook() async {
    try {
      loadingDialog(context).show();

      final LoginResult facebookLoginResult =
          await FacebookAuth.instance.login();

      switch (facebookLoginResult.status) {
        case LoginStatus.success:
          // get the user data
          // by default we get the userId, email,name and picture

          final userData = await FacebookAuth.instance.getUserData();
          // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");

          print('userData ${userData}');
          AppUser _user = AppUser(
            authKey: userData['id'],
            email: userData['email'],
            image: userData['picture']['data']['url'],
            name: userData['name'],
          );

          bool authenticated =
              await Provider.of<AuthProvider>(context, listen: false)
                  .loginUsingSocial(context, _user, _deviceName);

          await loadingDialog(context).hide();
          print(authenticated);

          if (authenticated) {
            _navigateToTabsScreen();
          }
          break;
        case LoginStatus.cancelled:
          print('cancelled by user');
          await loadingDialog(context).hide();
          break;
        case LoginStatus.failed:
          print('error');
          await loadingDialog(context).hide();
          print(facebookLoginResult.status);
          print(facebookLoginResult.message);
          Fluttertoast.showToast(
            msg: facebookLoginResult.message!,
            toastLength: Toast.LENGTH_LONG,
          );
          break;
        case LoginStatus.operationInProgress:
          break;
      }
    } catch (e) {
      await loadingDialog(context).hide();
    }
  }
}

class AuthCustomButton extends StatelessWidget {
  const AuthCustomButton({
    super.key,
    required this.onTap,
    required this.title,
  });

  final Function() onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 10),
        height: 55,
        decoration: BoxDecoration(
            color: primaryColor, borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
