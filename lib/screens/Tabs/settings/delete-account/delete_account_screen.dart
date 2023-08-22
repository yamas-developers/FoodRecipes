import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:food_recipes_app/providers/auth_provider.dart';
import 'package:food_recipes_app/screens/Auth/login/login_screen.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  final String? information;

  const DeleteAccountScreen({Key? key, this.information}) : super(key: key);

  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        'delete_account'.tr(),
        style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
      ),
    );
  }

  _body() {
    return SingleChildScrollView(
        child: Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 100),
      child: Column(
        children: [
          Text(
            'account_deletion_confirmation'.tr(),
            style: TextStyle(fontSize: 16, height: 1.8, fontFamily: 'Brandon'),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 3),
          _buildDeleteButton(),
          SizedBox(height: 15),
          _buildCancelButton(),
        ],
      ),
    ));
  }

  _deleteAccount() async {
    print('_authProvider!.user!.id! ${_authProvider!.user!.id!}');
    await ApiRepository.deleteAccount(_authProvider!.user!.id!);
    _logout();
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
    _navigateToLoginScreen();
  }

  _navigateToLoginScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (Route<dynamic> route) => false,
    );
  }

  _buildDeleteButton() {
    return SizedBox(
      width: 300,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.0)),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: Text(
          'delete_account'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        onPressed: _deleteAccount,
      ),
    );
  }

  _buildCancelButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => DeleteAccountScreen(),
        ),
      ),
      child: Text(
        'cancel'.tr(),
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}
