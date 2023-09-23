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
import 'package:food_recipes_app/widgets/default_custom_button.dart';
import 'package:food_recipes_app/widgets/shimmer_widget.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../Theme/colors.dart';

final BaseCacheManager baseCacheManager = DefaultCacheManager();

class RecipeDetailsScreen extends StatefulWidget {
  static const routeName = '/recipe-details';

  final Recipe? recipe;
  final String? route;

  RecipeDetailsScreen({this.recipe, this.route});

  @override
  _RecipeDetailsScreenState createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen>
    with SingleTickerProviderStateMixin {
  List<String>? _ingredients = [];
  List<String>? _steps = [];
  List? _selectedIngredients = [];
  List<Comment>? _comments = [];

  var db = new CookBookDatabaseHelper();

  TextEditingController? _commentTextController;
  int? savedRecipeId;
  String _recipeImagesPath = ApiRepository.RECIPE_IMAGES_PATH;
  String _uerImagesPath = ApiRepository.USER_IMAGES_PATH;
  String _itemImagesPath = ApiRepository.ITEMS_IMAGES_PATH;

  double? _iconRating = 0.0;
  int _serving = 1;
  String? _globalRating = '';
  int _likes = 0;
  bool _favorated = false;
  bool _isFollowing = false;
  bool _isAdding = false;
  AppUser? _author;

  AuthProvider? _authProvider;
  AppProvider? _appProvider;

  // BannerAd? _bannerAd;
  // InterstitialAd? _interstitialAd;

  // final bannerController = BannerAdController();

  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _serving = widget.recipe?.noOfServing ?? 1;
      setState(() {});
    });

    _commentTextController = TextEditingController();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

    _getIngredients();
    _getSteps();
    _getRecipeIfExist();
    _checkIfUserIsFollowing();
    _getUserRate();
    _getRecipeRate();
    _getRecipeLikes();
    _getRecipeComments();

    ApiRepository.updateRecipeViews(widget.recipe!.id!);

    // _loadAndShowAds();
  }

  void dispose() {
    _commentTextController!.dispose();
    // _interstitialAd?.dispose();
    // _bannerAd!.dispose();
    super.dispose();
  }

  _getIngredients() {
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(widget.recipe!.ingredients!);
    for (var i = 0; i < lines.length; i++) {
      _ingredients!.add(lines[i]);
    }
  }

  _getSteps() {
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(widget.recipe!.steps!);
    for (var i = 0; i < lines.length; i++) {
      _steps!.add(lines[i]);
    }
  }

  Future<void> _getRecipeComments() async {
    await ApiRepository.getRecipeComments(widget.recipe!.id!).then((value) {
      setState(() {
        _comments = value;
        _isAdding = false;
      });
    });
  }

  Future<void> _addUserFollower() async {
    if (_authProvider!.user != null) {
      await ApiRepository.addUserFollow(
              _authProvider!.user!.id!, widget.recipe!.userId!)
          .then((value) {
        if (value == true) {
          setState(() {
            _isFollowing = true;
          });
        } else {
          _checkIfUserIsFollowing();
          setState(() {
            _isFollowing = false;
          });
        }
      });
      _authProvider?.getFollowingFollowers();
    } else {
      Fluttertoast.showToast(
        msg: 'please_login_to_be_able_to_follow'.tr(),
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _addUserRate(double rate) async {
    print('authProvider user ${_authProvider}');
    await ApiRepository.addUserRate(
        _authProvider!.user!.id!, rate, widget.recipe!.id!);
  }

  Future<void> _getRecipeRate() async {
    await ApiRepository.getRecipeRate(widget.recipe!.id!).then((value) {
      if (value != null) {
        setState(() {
          _globalRating = value;
        });
      }
    });
  }

  Future<void> _getUserRate() async {
    if (_authProvider?.user != null)
      await ApiRepository.getUserRateOfRecipe(
              widget.recipe!.id!, _authProvider!.user!.id!)
          .then((value) {
        if (value != null) {
          setState(() {
            _iconRating = double.parse(value);
          });
        }
      });
  }

  Future<void> _getRecipeLikes() async {
    await ApiRepository.getRecipeLikes(widget.recipe!.id!).then((value) {
      setState(() {
        _likes = value!;
      });
    });
  }

  Future<void> _checkIfUserIsFollowing() async {
    if (_authProvider?.user != null)
      await ApiRepository.checkIfUserIsFollowing(
              _authProvider!.user!.id!, widget.recipe!.userId!)
          .then((value) {
        if (value == true)
          setState(() {
            _isFollowing = true;
          });
        else
          setState(() {
            _isFollowing = false;
          });
      });
  }

  Future<void> _addRecipeComment(String comment) async {
    AppUser? user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null)
      await ApiRepository.addRecipeComment(
          _authProvider!.user!.id!, widget.recipe!.id!, comment);
    else {
      setState(() {
        _isAdding = true;
      });
      Fluttertoast.showToast(
          msg: 'please_login_to_be_able_to_add_comments'.tr());
    }
  }

  void _onIngredientSelected(bool selected, id) {
    if (selected == true) {
      setState(() {
        _selectedIngredients!.add(id);
      });
    } else {
      setState(() {
        _selectedIngredients!.remove(id);
      });
    }
  }

  Future<void> _addToFavorite() async {
    if (_authProvider!.user == null) {
      Fluttertoast.showToast(
        msg: 'please_login_to_be_able_to_add_favorites'.tr(),
      );
      return;
    }
    if (!_favorated) {
      savedRecipeId =
          await db.saveRecipe(_authProvider!.user!.id!, widget.recipe!.id!);
      await ApiRepository.updateRecipeLikes(widget.recipe!.id!, 'plus');
      _getRecipeLikes();
      setState(() {
        _favorated = true;
      });
    } else {
      savedRecipeId = await db.deleteRecipe(widget.recipe!.id!);
      await ApiRepository.updateRecipeLikes(widget.recipe!.id!, 'minus');
      _getRecipeLikes();
      setState(() {
        _favorated = false;
      });
    }
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

  Widget _nestedScrollView() {
    return Consumer<AppProvider>(builder: (context, AppProvider appPro, _) {
      return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            // App Bar Sliver
            SliverAppBar(
              expandedHeight: 240.0,
              floating: false,
              pinned: false,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                // title: Text('CustomScrollView Example'),
                background: Stack(
                  children: <Widget>[
                    _buildRecipeImage(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildBackButton(context),
                        Padding(
                          padding: const EdgeInsets.only(top: 40, right: 20),
                          child: _buildAddToFavoriteButton(),
                        ),
                      ],
                    ),
                    _buildSocialButtons(),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 8),
                _buildRecipeNameRow(),
                SizedBox(height: 5),
                // _buildAuthorInformation(),
                // SizedBox(height: 10),
                _buildRecipeDetailsRow(),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Wrap(
                    children: [
                      ...List.generate(
                          widget.recipe?.categories?.length ?? 0,
                          (index) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  color: Color(0xffffeed8),
                                ),
                                child: Text(
                                    widget.recipe?.categories![index].name ??
                                        '--',
                                    style: TextStyle(
                                        color: Color(0xfffc7d1a),
                                        fontSize: 16)),
                              ))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 14, top: 20, right: 14),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: appPro.isDark ? bgColor : backgroundColor,
                      boxShadow: appPro.isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 7,
                              )
                            ]),
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: TabBar(
                    controller: _tabController,
                    indicatorPadding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color:
                          lightBlack, // Customize the tab indicator color here
                    ),
                    labelStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelColor: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.8),
                    labelColor: Theme.of(context).primaryColor,
                    tabs: [
                      Tab(text: 'instructions'.tr()),
                      Tab(text: 'ingredients'.tr()),
                    ],
                  ),
                ),

                // SizedBox(height: 10),
                // _buildBannerAd(),
                SizedBox(height: 0),

                // _buildSectionTitle(context, 'rate_recipe'.tr()),
                // _buildRatingBar(),
                // _buildSectionTitle(context, 'comments'.tr()),
                // _buildCommentForm(context),
                // _buildCommentsList(),
                // SizedBox(height: 10),
              ]),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Instructions tab content
            Container(
                padding: EdgeInsets.all(0),
                child: Column(children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  _buildSectionTitle(context, 'steps'.tr()),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(child: _buildStepsList(appPro)),
                  SizedBox(
                    height: 0,
                  ),
                ])),
            // Ingredients tab content
            Container(
                padding: EdgeInsets.all(0),
                child: Column(children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  _buildSectionTitle(context, 'ingredient'.tr()),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(child: _buildIngredientsList(appPro)),
                  SizedBox(
                    height: 0,
                  ),
                ])),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));

    Color fgColor = Colors.white.withOpacity(0.85);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _nestedScrollView(),
            Consumer<AppProvider>(builder: (context, AppProvider appPro, _) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 250,
                      decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: appPro.isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                  ),
                                ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _serving--;
                                });
                              },
                              icon: Icon(
                                Icons.remove,
                                color: fgColor,
                              )),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              color: fgColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${_serving}',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: bgColor,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _serving++;
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                color: fgColor,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 50,
                      width: 80,
                      decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: appPro.isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                  ),
                                ]),
                      child: IconButton(
                        icon: Icon(
                          Icons.play_arrow,
                          color: fgColor,
                        ),
                        onPressed: () {
                          _tabController?.animateTo(0);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  _buildRecipeImage() {
    return Container(
      height: 280,
      width: double.infinity,
      child: CachedNetworkImage(
        cacheManager: baseCacheManager,
        imageUrl: _recipeImagesPath + widget.recipe!.image!,
        placeholder: (context, url) => ShimmerWidget(
          width: double.infinity,
          height: double.infinity,
          circular: false,
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  _buildBack() {
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

  List<String> categories = ['Lunch', 'Shrimps', 'Easy'];

  Widget _buildRecipeDetailsContainer() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      width: double.infinity,
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 8),
          _buildRecipeNameRow(),
          SizedBox(height: 5),
          // _buildAuthorInformation(),
          // SizedBox(height: 10),
          _buildRecipeDetailsRow(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8),
            child: Wrap(
              children: [
                ...List.generate(
                    widget.recipe?.categories?.length ?? 0,
                    (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Color(0xffffeed8),
                          ),
                          child: Text(
                              widget.recipe?.categories![index].name ?? '--',
                              style: TextStyle(
                                  color: Color(0xfffc7d1a), fontSize: 16)),
                        ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 7,
                  )
                ]),
            padding: EdgeInsets.symmetric(vertical: 6),
            child: TabBar(
              controller: _tabController,
              indicatorPadding:
                  EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: lightBlack, // Customize the tab indicator color here
              ),
              labelStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelColor: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withOpacity(0.8),
              labelColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(text: 'Instructions'),
                Tab(text: 'Ingredients'),
              ],
            ),
          ),
          // Expanded(
          //   child: TabBarView(
          //     controller: _tabController,
          //     children: [
          //       // Instructions tab content
          //       Container(
          //           padding: EdgeInsets.all(16.0),
          //           child: Column(children: <Widget>[
          //             _buildSectionTitle(context, 'steps'.tr()),
          //             _buildStepsList(),
          //           ])),
          //       // Ingredients tab content
          //       Container(
          //           padding: EdgeInsets.all(16.0),
          //           child: Column(children: <Widget>[
          //             _buildSectionTitle(context, 'ingredient'.tr()),
          //             _buildIngredientsList(),
          //           ])),
          //     ],
          //   ),
          // ),

          // SizedBox(height: 10),
          // _buildBannerAd(),
          SizedBox(height: 10),

          _buildSectionTitle(context, 'rate_recipe'.tr()),
          _buildRatingBar(),
          _buildSectionTitle(context, 'comments'.tr()),
          _buildCommentForm(context),
          _buildCommentsList(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  _buildRecipeNameRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 25, right: 25, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildRecipeName(),
          // Expanded(
          //   flex: 1,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: <Widget>[
          //       _buildShareButton(),
          //       SizedBox(width: 7),
          //
          //       // _buildRecipeLikesCount(),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  _buildRecipeName() {
    return Expanded(
      // flex: 3,
      child: AutoSizeText(
        widget.recipe!.name!,
        minFontSize: 18,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          // color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _buildShareButton() {
    return InkWell(
      child: Icon(Icons.share, size: 27),
      onTap: () => baseCacheManager
          .getSingleFile(_recipeImagesPath + widget.recipe!.image!)
          .then(
        (info) {
          info.readAsBytes().then(
            (bytes) async {
              await Share.share(
                Platform.isAndroid
                    ? '${AppConfig.sharingRecipeText} \n https://play.google.com/store/apps/details?id=${AppConfig.GooglePlayIdentifier}'
                    : '${AppConfig.sharingRecipeText} \n https://apps.apple.com/de/app/bbqianer/id${AppConfig.AppStoreIdentifier}',
                subject: '${AppConfig.sharingRecipeTitle}',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddToFavoriteButton() {
    return InkWell(
      onTap: _addToFavorite,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _favorated ? Color(0xff882c2a) : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: _favorated
            ? Icon(Icons.favorite, color: Colors.red, size: 22)
            : Icon(Icons.favorite_border_outlined,
                color: Colors.black87, size: 22),
      ),
    );
  }

  _buildRecipeLikesCount() {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Container(
          child: AutoSizeText(
            '$_likes',
            style: TextStyle(
              fontSize: 19, /*color: Colors.black*/
            ),
          ),
        ),
      ),
    );
  }

  _buildAuthorInformation() {
    if (widget.recipe!.userId != _authProvider?.user?.id) {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(user: widget.recipe!.user!),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: widget.recipe!.user != null
              ? _authorRecipeItem(
                  widget.recipe!.user!.id!,
                  (widget.recipe!.user!.image)!,
                  (widget.recipe!.user!.name)!,
                  widget.recipe!.user!.createdAt!,
                )
              : _authorRecipeItem(
                  _author!.id!,
                  _author?.image,
                  _author!.name!,
                  _author!.createdAt!,
                ),
        ),
      );
    } else {
      return Container();
    }
  }

  _buildRecipeDetailsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: <Widget>[
          _detailsContainer(
              context,
              tr('cooking'),
              getDuration(widget.recipe!.duration.toString()),
              Icons.access_time_filled),
          VerticalDivider(),
          _detailsContainer(
              context,
              'rating'.tr(),
              '${widget.recipe!.rating != null ? formatDouble(widget.recipe!.rating!) : '0'}',
              Icons.star),
          VerticalDivider(),
          _detailsContainer(context, tr('recipes'),
              (widget.recipe!.difficulty!.name)!, Icons.local_fire_department),
        ],
      ),
    );
  }

  _authorRecipeItem(int userId, String? image, String name, String date) {
    String path = ApiRepository.USER_IMAGES_PATH;
    return Row(
      children: [
        (image != null)
            ? (image.contains('https'))
                ? CircleAvatar(
                    backgroundImage: NetworkImage('$image'),
                    backgroundColor: Colors.white,
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage('$path$image'),
                    backgroundColor: Colors.white,
                  )
            : CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/logo_user.png'),
              ),
        SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style:
                  GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Spacer(),
        _authProvider?.user != null
            ? Container(
                width: 80,
                height: 28,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.5,
                        color: (_isFollowing == false)
                            ? Colors.black
                            : Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    backgroundColor: (_isFollowing == false)
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                  onPressed: () => _addUserFollower(),
                  child: (_isFollowing == false)
                      ? Text('follow'.tr(), style: TextStyle(fontSize: 14))
                      : Text(
                          'following'.tr(),
                          maxLines: 1,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 25, right: 25, bottom: 3),
      child: Row(
        children: [
          Container(
            child: AutoSizeText(
              text,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    // color: Colors.black,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  _buildRatingBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: GFRating(
              color: GFColors.SUCCESS,
              borderColor: GFColors.SUCCESS,
              allowHalfRating: true,
              halfFilledIcon: Icon(Icons.star_half_rounded,
                  size: 30, color: GFColors.SUCCESS),
              filledIcon: Icon(Icons.star_rate_rounded,
                  size: 30, color: GFColors.SUCCESS),
              defaultIcon: Icon(Icons.star_outline_rounded,
                  size: 30, color: GFColors.SUCCESS),
              size: GFSize.SMALL,
              value: _iconRating != null ? _iconRating! : 0,
              onChanged: (value) {
                if (_iconRating != null) {
                  setState(() {
                    _iconRating = value;
                  });
                  _addUserRate(_iconRating!);
                  _getRecipeRate();
                } else {
                  setState(() {
                    _iconRating = value;
                  });
                  _addUserRate(_iconRating!);
                }
              },
            )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: (_globalRating != '') ? Text('$_globalRating') : Container(),
        ),
      ],
    );
  }

  Widget _buildIngredientsList(AppProvider appPro) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: (widget.recipe?.ingredientsItem != null &&
              (widget.recipe?.ingredientsItem!.length)! > 0)
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // itemExtent: 40,
              itemBuilder: (ctx, index) => Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                margin: EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    (widget.recipe?.ingredientsItem!.length)! > (index + 1)
                        ? 14
                        : 72),
                decoration: BoxDecoration(
                  color: appPro.isDark ? lightBlack : backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          '$_itemImagesPath${widget.recipe?.ingredientsItem![index].item?.image}',
                      imageBuilder: (context, imageProvider) => Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          // shape: BoxShape.circle,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => ShimmerWidget(
                        width: 40,
                        height: 40,
                        circular: true,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    Text(
                      widget.recipe?.ingredientsItem![index].item?.name ?? '--',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    //.toStringAsFixed(0)
                    Text(
                      '${formatDouble((_serving / (widget.recipe?.noOfServing ?? 1)) * (widget.recipe?.ingredientsItem![index].quantity ?? 0))} ${widget.recipe?.ingredientsItem![index].item?.unit ?? '-'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              itemCount: widget.recipe?.ingredientsItem!.length,
            )
          : Center(
              child: widget.recipe?.ingredientsItem == null ||
                      widget.recipe?.ingredientsItem!.length == 0
                  ? Text('no_ingredients_available'.tr())
                  : CircularProgressIndicator()),
    );
  }

  // _buildBannerAd() {
  //   return _bannerAd != null
  //       ? Container(
  //           alignment: Alignment.center,
  //           width: _bannerAd?.size.width.toDouble(),
  //           height: _bannerAd?.size.height.toDouble(),
  //           child: AdWidget(ad: _bannerAd!),
  //         )
  //       : Container();
  // }

  Widget _buildStepsList(AppProvider appPro) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: (_steps?.length ?? 0) > 0
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) => Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                margin: EdgeInsets.fromLTRB(
                    20, 14, 20, _steps!.length > (index + 1) ? 14 : 72),
                decoration: BoxDecoration(
                    color: appPro.isDark ? lightBlack : backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 7,
                      )
                    ]),
                child: stepsListTile(context, index, _steps!),
              ),
              itemCount: _steps!.length,
            )
          : (_steps?.length ?? 0) == 0
              ? Text('no_instructions_available'.tr())
              : Center(child: CircularProgressIndicator()),
    );
  }

  _detailsContainer(
      BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 5, top: 0, bottom: 10, right: 5),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: BoxDecoration(
            // color: Colors.white,
            // border:
            //     Border.all(color: Theme.of(context).primaryColor, width: 0.4),
            // borderRadius: BorderRadius.circular(5),
            ),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 27, color: Theme.of(context).primaryColor),
            SizedBox(
              height: 8,
            ),
            AutoSizeText(
              value,
              style: TextStyle(
                // color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 20,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.8),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            AutoSizeText(title,
                style: TextStyle(
                  // color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.5),
                )),
          ],
        ),
      ),
    );
  }

  Widget checkBoxListTile(
      BuildContext context, List selecteditems, int index, List items) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      controlAffinity: ListTileControlAffinity.leading,
      value: selecteditems.contains(index),
      onChanged: (bool? selected) {
        setState(() {
          _onIngredientSelected(selected!, index);
        });
      },
      title: Text(
        items[index],
        style: GoogleFonts.lato(fontSize: 14.5, fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget stepsListTile(BuildContext context, int index, List items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AutoSizeText(
            '${index + 1}.',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(width: 15),
          Expanded(
            child: AutoSizeText(
              items[index],
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              'add_a_comment'.tr(),
              style: TextStyle(fontSize: 15),
            ),
          ),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLength: 120,
                controller: _commentTextController,
                style: TextStyle(
                    fontSize: 16,
                    // fontFamily: 'Raleway',
                    fontWeight: FontWeight.normal),
                maxLines: 3,
                // cursorColor: Colors.black,
                decoration: InputDecoration.collapsed(
                  hintText: "enter_your_comment_here".tr(),
                  hintStyle: TextStyle(
                    fontSize: 16,
                    // fontFamily: 'Raleway',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                if (_commentTextController!.value.text.isNotEmpty) {
                  setState(() {
                    _isAdding = true;
                  });
                  await _addRecipeComment(_commentTextController!.value.text);
                  _commentTextController?.clear();
                  await _getRecipeComments();
                } else {
                  Fluttertoast.showToast(msg: 'please_write_a_comment'.tr());
                }
              },
              child: _isAdding
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'add'.tr(),
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  _buildCommentsList() {
    return _comments != null
        ? MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) =>
                  _commentListItem(context, _comments!, index),
              itemCount: _comments!.length,
            ),
          )
        : Center(
            child: Padding(
              padding: EdgeInsets.only(top: 55, bottom: 48),
              child: Text(
                'no_comments_yet'.tr(),
                style: TextStyle(fontSize: 15),
              ),
            ),
          );
  }

  _commentListItem(BuildContext context, List<Comment> comments, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        child: Card(
          elevation: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(user: widget.recipe!.user!),
                    ),
                  ),
                  child: (comments[index].user.image != null)
                      ? (comments[index].user.image!.contains('https'))
                          ? CachedNetworkImage(
                              imageUrl: '${comments[index].user.image}',
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => ShimmerWidget(
                                width: 50,
                                height: 50,
                                circular: true,
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )
                          : CachedNetworkImage(
                              imageUrl:
                                  '$_uerImagesPath${comments[index].user.image}',
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => ShimmerWidget(
                                width: 50,
                                height: 50,
                                circular: true,
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage:
                              AssetImage('assets/images/logo_user.png'),
                          radius: 25,
                        ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(user: widget.recipe!.user!),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '${comments[index].user.name}',
                              style: TextStyle(
                                  // color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            Spacer(),
                            Text(
                              '${timeago.format(comments[index].createdAt, locale: context.locale.languageCode)}',
                              style: TextStyle(
                                  // color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'RobotoCondensed',
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${comments[index].comment}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                              softWrap: true,
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: (comments[index].userId ==
                                    _authProvider!.user?.id)
                                ? InkWell(
                                    onTap: () async {
                                      await ApiRepository.deleteUserComment(
                                          comments[index].id);
                                      await _getRecipeComments();
                                    },
                                    child: Icon(
                                      Icons.delete_forever,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VerticalDivider extends StatelessWidget {
  const VerticalDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          border: Border(
              left: BorderSide(
        width: 0.5,
        color: Colors.grey.withOpacity(0.5),
      ))),
    );
  }
}
