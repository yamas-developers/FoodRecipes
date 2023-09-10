import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;

import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_recipes_app/screens/Tabs/settings/information-screen/information_screen.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:food_recipes_app/widgets/custom_text_field.dart';
import 'package:food_recipes_app/widgets/default_custom_button.dart';
import 'package:food_recipes_app/widgets/progress_dialog.dart';
import 'package:image/image.dart' as Img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../Components/textField.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/utils.dart';
import '../../Tabs/tabs_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = new GlobalKey<FormState>();

  // Initializing input controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _lNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confPasswordController = TextEditingController();

  bool passwordMode = false;

  // Initializing the image picker
  final _picker = ImagePicker();

  // Initializing variables and files
  String? _base64Image = null;
  File? _tmpFile = null, _image = null;
  String? _fileName = null;
  bool _agree = false;

  void dispose() {
    _nameController.dispose();
    _lNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confPasswordController.dispose();
    super.dispose();
  }

  Future chooseImage() async {
    var imageFile = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 500, maxHeight: 500);

    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    int rand = Math.Random().nextInt(100000);

    if (imageFile != null) {
      Img.Image? image =
          Img.decodeImage(File(imageFile.path).readAsBytesSync());
      Img.Image smallerImg = Img.copyResize(image!, width: 250);

      var compressImg = new File("$path/image_$rand.jpg")
        ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 85));

      setState(() {
        _image = compressImg;
        _tmpFile = _image;
        _base64Image = base64Encode(_image!.readAsBytesSync());
      });
    }
  }

  _navigateToInformationScreen(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => InformationScreen(information: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: _body(queryData),
    );
  }

  _body(MediaQueryData queryData) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15),
          buildBackButton(context, padding: EdgeInsets.only(left: 0),
              onTap: () {
            if (passwordMode) {
              setState(() {
                passwordMode = false;
              });
            } else {
              Navigator.pop(context);
            }
          }),
          SizedBox(height: 15),
          if (!passwordMode) ...[
            Text(
              'hi_welcome'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 15),
            Text(
              'we_cant_wait'.tr(),
              style:
                  Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 18),
            )
          ],
          SizedBox(
            height: 65,
          ),
          // Spacer(),

          // _buildImageCard(),
          Expanded(
            child: _buildRegistrationFields(queryData),
          ),
          SizedBox(
            height: 18,
          )
        ],
      ),
    );
  }

  _buildBackgroundImage() {
    return Container(
      child: Image.asset(
        'assets/images/logo.jpg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  _buildImageCard() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 25),
          child: Center(
            child: InkWell(
                onTap: chooseImage,
                child: Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black12,
                        spreadRadius: 0.8,
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: (_image == null)
                        ? Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 35,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : Image.file(_image!, fit: BoxFit.fill),
                  ),
                )),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  _buildRegistrationFields(MediaQueryData queryData) {
    return Column(
      children: [
        Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!passwordMode) ...[
                  EntryField('name'.tr(), 'name'.tr(), false, _nameController),
                  SizedBox(height: 10),
                  EntryField(
                      'email'.tr(), 'email'.tr(), false, _emailController),
                  SizedBox(height: 10)
                ],
                if (passwordMode) ...[
                  EntryField('password'.tr(), 'password'.tr(), false,
                      _passwordController),
                  SizedBox(height: 10),
                  EntryField('confirm_password'.tr(), 'confirm_password'.tr(),
                      false, _confPasswordController)
                ],
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
        Spacer(),
        if (passwordMode) ...[_buildCheckboxTile(), SizedBox(height: 10)],
        DefaultCustomButton(
            text: passwordMode ? 'explore'.tr() : 'continue'.tr(),
            onPressed: _register),
      ],
    );
  }

  _buildCheckboxTile() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        // color: Colors.white,
      ),
      margin: EdgeInsets.symmetric(horizontal: 0),
      child: CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: _agree,
          dense: true,
          contentPadding: EdgeInsets.all(3),
          checkColor: Colors.white,
          activeColor: Theme.of(context).primaryColor,
          // checkColor: theme.isDarkTheme() ? Colors.white70 : Colors.black87,
          onChanged: (state) {
            print(state);
            setState(() {
              _agree = state!;
            });
          },
          title: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                // color: Colors.black.withOpacity(0.7),
              ),
              children: <TextSpan>[
                TextSpan(text: 'i_agree_to_the'.tr() + ' '),
                TextSpan(
                  text: 'terms_of_service'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).primaryColor,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () =>
                        _navigateToInformationScreen('Terms & Conditions'),
                ),
                TextSpan(text: ' ' + 'and'.tr() + ' '),
                TextSpan(
                  text: 'the_privacy_policy'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).primaryColor,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap =
                        () => _navigateToInformationScreen('Privacy Policy'),
                ),
              ],
            ),
          )
          // Wrap(
          //         direction: Axis.horizontal,
          //         children: [
          //           _buildWrappedText(
          //               'By registering, you are agreeing to the', false),
          //           // GestureDetector(
          //           //   onTap: () => _navigateToInformationScreen('Privacy Policy'),
          //           //   child: _buildWrappedText('Privacy Policy', true),
          //           // ),
          //           // _buildWrappedText(' and ', false),
          //           GestureDetector(
          //             onTap: () => _navigateToInformationScreen('Terms & Conditions'),
          //             child: _buildWrappedText('Terms & Conditions', true),
          //           ),
          //         ],
          //       ),
          ),
    );
  }

  _register() async {
    if (!passwordMode) {
      if (_nameController.text.isEmpty) {
        Fluttertoast.showToast(
          msg: 'invalid_name'.tr(),
          toastLength: Toast.LENGTH_SHORT,
        );
      } else if (!EmailValidator.validate(_emailController.value.text)) {
        Fluttertoast.showToast(
          msg: 'invalid_email'.tr(),
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        setState(() {
          passwordMode = true;
        });
      }
      return;
    }

    if (formKey.currentState!.validate()) {
      if (_agree) {
        if (EmailValidator.validate(_emailController.value.text)) {
          if (_passwordController.value.text ==
              _confPasswordController.value.text) {
            if (_passwordController.value.text.length < 8) {
              Fluttertoast.showToast(msg: 'the_password_cannot_be_less'.tr());
              await loadingDialog(context).hide();
              return;
            } else if (!_validatePassword(_passwordController.text)) {
              Fluttertoast.showToast(msg: 'password_not_proper'.tr());
            }
            // return;
            await loadingDialog(context).show();
            // if (null == _tmpFile) {
            //   print('No Image Provided');
            // } else {
            //   setState(() {
            //     _fileName = _tmpFile!.path.split('/').last;
            //   });
            // }
            // if (_base64Image != null && _fileName != null) {
            //   await ApiRepository.registerUser(
            //     context,
            //     _nameController.value.text,
            //     _emailController.value.text,
            //     _passwordController.value.text,
            //     _tmpFile,
            //     _fileName,
            //   ).then((value) async {
            //     await loadingDialog(context).hide();
            //     // if (value != null) Navigator.pop(context);
            //   });
            // } else {
            await ApiRepository.registerUser(
              context,
              _nameController.value.text,
              _emailController.value.text,
              _passwordController.value.text,
              null,
              null,
            ).then((value) async {
              await loadingDialog(context).hide();
              if (value != null) {
                bool res =
                    await Provider.of<AuthProvider>(context, listen: false)
                        .register(value);
                if (res) {
                  Navigator.of(context)
                      .pushReplacementNamed(TabsScreen.routeName);
                }
              }
            });
            // }
            FocusScope.of(context).unfocus();
            // Navigator.pop(context);
          } else {
            Fluttertoast.showToast(
              msg: 'password_doesnt_match'.tr(),
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: 'invalid_email'.tr(),
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'you_need_to_agree'.tr(),
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  bool _validatePassword(String password) {
    // Define a regular expression pattern for the password validation.
    final pattern = r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }
}
