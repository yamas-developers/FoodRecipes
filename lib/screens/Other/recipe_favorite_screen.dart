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

// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../Theme/colors.dart';
import '../../models/recipe_page.dart';
import '../../widgets/home_recipe_item.dart';
import '../../widgets/shimmer_loading.dart';

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
  bool _isFetching = true;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  TextEditingController? _commentTextController;
  int? savedRecipeId;
  bool _favorated = false;
  GlobalKey _refreshKey = GlobalKey();
  GlobalKey _contentKey = GlobalKey();
  List<Recipe> _recipes = [];
  int _recipesPage = 1;
  int _maxPages = 1;
  int _itemsPerPage = 10;
  List _recipeIds = [];

  AuthProvider? _authProvider;
  AppProvider? _appProvider;

  @override
  void initState() {
    super.initState();

    _commentTextController = TextEditingController();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      getIds();
    });

    // _loadAndShowAds();
  }

  getIds() async {
    _recipeIds = await db.getAllRecipes();
    if (_recipeIds.isNotEmpty) {
      _maxPages = (_recipeIds.length / _itemsPerPage).ceil();
    }
    _fetchRecipes();
  }

  void dispose() {
    _commentTextController!.dispose();
    super.dispose();
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
    return Padding(
      padding: EdgeInsets.only(bottom: 0, top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Row(
          //   children: [
          //     buildBackButton(context, padding: EdgeInsets.zero),
          //   ],
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
            child: Text(
              'favorites'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontSize: 32, fontWeight: FontWeight.w700),
            ),
          ),
          // TextButton(
          //     onPressed: () async {
          //       print('MK: favorites: ${await db.getAllRecipes()}');
          //     },
          //     child: Text('add_to_favorites'.tr())),
          Expanded(child: _listview()),
        ],
      ),
    );
  }

  Widget _listview() {
    return _isFetching
        ? ShimmerLoading(type: ShimmerType.Recipes)
        : SmartRefresher(
            key: _refreshKey,
            controller: _refreshController,
            enablePullUp: true,
            physics: BouncingScrollPhysics(),
            header: MaterialClassicHeader(color: primaryColor),
            footer: ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: _recipes.isNotEmpty
                ? GridView.builder(
                    physics: BouncingScrollPhysics(),
                    key: _contentKey,
                    padding: EdgeInsets.only(top: 10, bottom: 0),
                    itemBuilder: (ctx, index) => HomeRecipeItem(
                      recipe: _recipes[index],
                    ),
                    itemCount: _recipes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.68,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                  )
                : Center(
                    child: Text(
                      "no_recipes_to_display".tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 17),
                    ),
                  ),
          );
  }

  _getRecipesIds() {
    int startIndex = (_recipesPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (startIndex < _recipeIds.length) {
      List idsForCurrentPage = _recipeIds.sublist(startIndex,
          endIndex > _recipeIds.length ? _recipeIds.length : endIndex);
      return idsForCurrentPage;
    } else {
      return [];
    }
  }

  _fetchRecipes() async {
    List<Recipe>? recipes;
    if (_recipeIds.isNotEmpty) {
      recipes = (await ApiRepository.fetchRecipesByIds(_getRecipesIds()));
    }

    if (mounted)
      setState(() {
        _recipes = recipes ?? [];
        _isFetching = false;
      });
  }

  _onRefresh() async {
    await getIds();
    List<Recipe>? recipes;

    setState(() {
      _isFetching = true;
    });

    if (_recipeIds.isNotEmpty) {
      recipes = (await ApiRepository.fetchRecipesByIds(_getRecipesIds()));
    }

    _recipes.clear();
    _recipesPage = 1;
    _recipes.addAll(recipes ?? []);

    if (mounted)
      setState(() {
        _refreshController.refreshCompleted();
        _isFetching = false;
      });
  }

  _onLoading() async {
    // if (_recipeIds.isEmpty) {
    //   setState(() {
    //     _isFetching = false;
    //   });
    //   return;
    // }
    List<Recipe>? recipes;

    if (_recipeIds.isNotEmpty) {
      _recipesPage++;
      if (_recipesPage > _maxPages) {
        _refreshController.loadNoData();
        return;
      }
      recipes = (await ApiRepository.fetchRecipesByIds(_getRecipesIds()));
    }
    _recipes.addAll(recipes ?? []);
    if (mounted)
      setState(() {
        _refreshController.loadComplete();
      });
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
