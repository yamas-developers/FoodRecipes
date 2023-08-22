import 'package:food_recipes_app/screens/Auth/login/login_screen.dart';
import 'package:food_recipes_app/screens/Tabs/settings/profile-edit/profile_edit_screen.dart';
import 'package:food_recipes_app/screens/Other/recipe-details/recipe_details_screen.dart';
import 'package:food_recipes_app/screens/Auth/register/register_screen.dart';
import 'package:food_recipes_app/screens/Auth/splash/splash_screen.dart';
import 'package:food_recipes_app/screens/tabs/tabs_screen.dart';
import 'package:flutter/widgets.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  RegisterScreen.routeName: (context) => RegisterScreen(),
  EditProfileScreen.routeName: (context) => EditProfileScreen(),
  TabsScreen.routeName: (context) => TabsScreen(),
  RecipeDetailsScreen.routeName: (context) => RecipeDetailsScreen(),
};
