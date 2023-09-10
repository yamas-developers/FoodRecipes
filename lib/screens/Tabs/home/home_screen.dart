import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:animation_wrappers/Animations/faded_slide_animation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro_nullsafety/carousel_pro_nullsafety.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes_app/config/app_config.dart';
import 'package:food_recipes_app/models/app_user.dart';
import 'package:food_recipes_app/models/recipe.dart';
import 'package:food_recipes_app/providers/app_provider.dart';
import 'package:food_recipes_app/providers/auth_provider.dart';
import 'package:food_recipes_app/providers/recipe_provider.dart';
import 'package:food_recipes_app/screens/Other/profile/profile_screen.dart';
import 'package:food_recipes_app/screens/Other/recipe-details/recipe_details_screen.dart';
import 'package:food_recipes_app/screens/Tabs/home/recipes_list/recipes_list_screen.dart';
import 'package:food_recipes_app/screens/Tabs/home/search/search_screen.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:food_recipes_app/services/notification_bloc.dart';
import 'package:food_recipes_app/utils/utils.dart';
import 'package:food_recipes_app/widgets/home_recipe_item.dart';
import 'package:food_recipes_app/widgets/search_text_field.dart';
import 'package:food_recipes_app/widgets/shimmer_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/category.dart';
import '../../../providers/category_provider.dart';
import '../../../widgets/shimmer_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription<Map> _notificationSubscription;
  GlobalKey _contentKey = GlobalKey();
  TextEditingController _searchKeywordController = TextEditingController();

  int randomRecipeIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _notificationSubscription = NotificationsBloc.instance.notificationStream
        .listen(_performActionOnNotification);
    _fetchMostCollectedRecipes();
    _fetchRecentRecipes();
    _fetchCategories();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        randomRecipeIndex = generateRandomNumber();
      });
    });
  }

  int generateRandomNumber() {
    Random random = Random();
    return random.nextInt(context
        .read<RecipeProvider>()
        .mostCollectedRecipes
        .length); // Generates a random number between 0 and maxNumber (inclusive)
  }

  _fetchCategories() async {
    try {
      await Provider.of<CategoryProvider>(context, listen: false)
          .fetchOrDisplayPaginatedCategories();
    } catch (err) {
      print('[_fetchCategories] :: error ' + err.toString());
    }
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    if (timer != null) timer?.cancel();
    super.dispose();
  }

  _performActionOnNotification(Map<String, dynamic> message) async {
    if (message['data']['message'] != null) {
      print('message map $message');
      Map decodedMessage = json.decode(message['data']['message']);

      if (decodedMessage['follow'] != null) {
        AppUser user = AppUser.fromJson(decodedMessage['follow']);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
        );
      } else if (decodedMessage['recipe'] != null) {
        Recipe recipe = Recipe.fromJson(decodedMessage['recipe']);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecipeDetailsScreen(recipe: recipe),
          ),
        );
      }
    }
  }

  _fetchRecentRecipes() async {
    await Provider.of<RecipeProvider>(context, listen: false)
        .fetchOrDisplayRecentRecipes();
  }

  _fetchMostCollectedRecipes() async {
    await Provider.of<RecipeProvider>(context, listen: false)
        .fetchOrDisplayMostCollectedRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: _body()),
    );
  }

  _body() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildUserNameAndImage(),
            _buildSearchField(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
              child: _buildTitle(
                text: 'most_collected'.tr(),
                hasViewAll: false,
              ),
            ),
            _buildCarousel(),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _buildTitle(
                text: 'choose_types_food'.tr(),
                hasViewAll: false,
              ),
            ),
            CategoryHorizontalList(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildTitle(
                text: 'recent_recipes'.tr(),
                hasViewAll: true,
              ),
            ),
            _buildRecentRecipesList(),
          ],
        ),
      ),
    );
  }

  _buildUserNameAndImage() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getGreeting(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  if (auth.user?.name != null)
                    Text(
                      auth.user != null ? auth.user!.name! : 'Guest',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              // Container(
              //   width: 40,
              //   height: 40,
              //   clipBehavior: Clip.antiAliasWithSaveLayer,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: (auth.user != null && auth.user!.image != null)
              //       ? Image.network(
              //           auth.user!.image!.contains('https')
              //               ? auth.user!.image!
              //               : '${ApiRepository.USER_IMAGES_PATH}${auth.user!.image}',
              //           fit: BoxFit.cover,
              //         )
              //       : Image.asset('assets/images/logo_user.png'),
              // )
            ],
          ),
        );
      },
    );
  }

  Widget popupListItemWidget(Recipe recipe) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        recipe.name!,
        style: TextStyle(fontSize: 18, fontFamily: 'RobotoCondensed'),
      ),
    );
  }

  _buildTitle({required String text, bool? hasViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AutoSizeText(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        hasViewAll!
            ? Column(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RecipesListScreen(
                          listType: ListType.Newest,
                        ),
                      ),
                    ),
                    child: AutoSizeText(
                      'view_all'.tr(),
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  _buildSearchField() {
    return Consumer<RecipeProvider>(builder: (context, recipePro, child) {
      List<Recipe> _recipes = recipePro.mostCollectedRecipes;
      Recipe? recipe = _recipes.length > 0
          ? randomRecipeIndex < _recipes.length
              ? _recipes[randomRecipeIndex]
              : _recipes.first
          : null;
      return SearchTextfield(
        hintText: '${'search_for'.tr()} ${recipe?.name ?? 'recipes'}',
        controller: _searchKeywordController,
        suffixIconOnTap: () {
          if (_searchKeywordController.text.isNotEmpty) {
            FocusScope.of(context).unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => SearchScreen(
                  keyword: _searchKeywordController.text,
                ),
              ),
            );
          }
        },
        onChanged: () => null,
      );
    });
  }

  _buildCarousel() {
    return Consumer<RecipeProvider>(
      builder: (context, recipe, child) {
        if (recipe.mostCollectedStatus == MostCollectedRecipeStatus.Fetching) {
          return ShimmerLoading(type: ShimmerType.Carousel);
        } else {
          List<Recipe> _recipes = recipe.mostCollectedRecipes;
          return _recipes.isNotEmpty
              ? SizedBox(
                  height: 180.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Carousel(
                      images: List.generate(
                        _recipes.length,
                        (index) => Stack(
                          children: [
                            Container(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Image.network(
                                ApiRepository.RECIPE_IMAGES_PATH +
                                    _recipes[index].image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            Align(
                              alignment: context.locale.languageCode == 'ar'
                                  ? Alignment.bottomRight
                                  : Alignment.bottomLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 22,
                                  horizontal: 10,
                                ),
                                child: Text(
                                  _recipes[index].name!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Brandon',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      dotSize: 5.0,
                      dotSpacing: 15.0,
                      radius: Radius.circular(15),
                      dotColor: Theme.of(context).primaryColor,
                      indicatorBgPadding: 5.0,
                      dotBgColor: Colors.transparent,
                      borderRadius: true,
                      onImageTap: (index) {
                        _navigateToRecipeDetailsScreen(_recipes[index]);
                      },
                    ),
                  ),
                )
              : Container(
                  height: 180,
                  child: Center(
                    child: Text(
                      'No Recipes To Display',
                      style: GoogleFonts.pacifico(fontSize: 14),
                    ),
                  ),
                );
        }
      },
    );
  }

  _buildRecentRecipesList() {
    return Consumer<RecipeProvider>(
      builder: (context, recipe, child) {
        if (recipe.recentStatus == RecentRecipeStatus.Fetching) {
          return ShimmerLoading(type: ShimmerType.Recipes);
        } else {
          List<Recipe> _recipes = recipe.recentRecipes;
          return _recipes.isNotEmpty
              ? GridView.builder(
                  key: _contentKey,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 10),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (ctx, index) => HomeRecipeItem(
                    recipe: _recipes[index],
                  ),
                  itemCount: _recipes.length > AppConfig.PerPage
                      ? AppConfig.PerPage
                      : _recipes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.68,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                )
              : Container(
                  height: 200,
                  child: Center(
                    child: Text(
                      'no_recent_recipes'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                );
        }
      },
    );
  }

  void onItemSelected(Recipe recipe) {
    _navigateToRecipeDetailsScreen(recipe);
  }

  _navigateToRecipeDetailsScreen(Recipe recipe) async {
    await Provider.of<AppProvider>(context, listen: false)
        .incrementAdClickCount();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(recipe: recipe),
      ),
    );
  }

  Widget noItemsFound() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.folder_open,
          size: 24,
          color: Colors.grey[900]?.withOpacity(0.7),
        ),
        const SizedBox(width: 10),
        Text(
          "no_recipes_to_display".tr(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[900]?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget selectedItemWidget(
      Recipe selectedItem, VoidCallback deleteSelectedItem) {
    return Container();
  }
}

class CategoryHorizontalList extends StatefulWidget {
  const CategoryHorizontalList({
    super.key,
  });

  @override
  State<CategoryHorizontalList> createState() => _CategoryHorizontalListState();
}

class _CategoryHorizontalListState extends State<CategoryHorizontalList> {
  // int foodIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(builder: (context, categoryPro, child) {
      if (categoryPro.categoryStatus == CategoryStatus.Fetching) {
        return ShimmerLoading(type: ShimmerType.HorizontalCategories);
      } else {
        List<Category> _categories = categoryPro.paginatedCategories;
        return _categories.isNotEmpty
            ? Container(
                padding: EdgeInsetsDirectional.only(start: 20),
                margin: EdgeInsets.only(bottom: 20, top: 20),
                height: 130,
                child: FadedSlideAnimation(
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        _categories.length < 10 ? _categories.length : 10,
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      Category category = _categories[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return RecipesListScreen(
                                  category: category,
                                  listType: ListType.Category,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 7),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).highlightColor),
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).scaffoldBackgroundColor),
                          padding: EdgeInsets.only(
                              bottom: 15, top: 10, right: 8, left: 8),
                          constraints: BoxConstraints(minWidth: 90),
                          child: Column(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      '${ApiRepository.CATEGORY_IMAGES_PATH}${category.image}',
                                  placeholder: (context, url) => ShimmerWidget(
                                    width: 70,
                                    height: 70,
                                    circular: false,
                                  ),
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${category.name}',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  beginOffset: Offset(0.4, 0),
                  endOffset: Offset(0, 0),
                  slideCurve: Curves.linearToEaseOut,
                ),
              )
            : Center(
                child: Text(
                  'no_categories_found'.tr(),
                  style: GoogleFonts.pacifico(fontSize: 16),
                ),
              );
      }
    });
  }
}
