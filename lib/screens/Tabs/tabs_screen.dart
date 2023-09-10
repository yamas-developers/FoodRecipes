import 'package:flutter/material.dart';
import 'package:food_recipes_app/screens/Tabs/home/search/search_screen.dart';
import 'package:food_recipes_app/screens/tabs/categories/categories_screen.dart';
import 'package:food_recipes_app/screens/tabs/cuisine/cuisine_screen.dart';
import 'package:food_recipes_app/screens/tabs/home/home_screen.dart';
import 'package:food_recipes_app/screens/tabs/recipe-add/recipe_add_screen.dart';

import '../Other/recipe_favorite_screen.dart';
import '../tabs/settings/settings_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  _body(BuildContext context) {
    return _pages[_selectedPageIndex]['page'];
  }

  _bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      onTap: _selectPage,
      elevation: 0,
      backgroundColor: Colors.white,
      unselectedItemColor: Colors.black26,
      selectedItemColor: Theme.of(context).primaryColor,
      currentIndex: _selectedPageIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 30,),
          // activeIcon: Image.asset(
          //   'assets/images/ic_home.png',
          //   scale: 2.2,
          //   color: Theme.of(context).primaryColor,
          // ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border, size: 30,),
          // activeIcon: Image.asset(
          //   'assets/images/ic_add.png',
          //   scale: 2.2,
          //   color: Theme.of(context).primaryColor,
          // ),
          label: 'Favorite',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined, size: 30,),
          // activeIcon: Image.asset(
          //   'assets/images/ic_category.png',
          //   scale: 2.2,
          //   color: Theme.of(context).primaryColor,
          // ),
          label: 'Categories',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.search, size: 30,),
          // activeIcon: Image.asset(
          //   'assets/images/ic_country.png',
          //   scale: 2.2,
          //   color: Theme.of(context).primaryColor,
          // ),
          label: 'Cuisine',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_2_outlined, size: 30,),
          // activeIcon: Image.asset(
          //   'assets/images/ic_profile.png',
          //   scale: 1.9,
          //   color: Theme.of(context).primaryColor,
          // ),
          label: 'CookBook',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      {'page': HomeScreen()},
      {'page': RecipeFavoriteScreen()},
      {'page': CategoriesScreen()},
      {'page': SearchScreen()},
      {'page': SettingsScreen()},
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }
}
