import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_recipes_app/config/admob_config.dart';
import 'package:food_recipes_app/config/app_config.dart';
import 'package:food_recipes_app/models/category.dart';
import 'package:food_recipes_app/models/cuisine.dart';
import 'package:food_recipes_app/models/recipe.dart';
import 'package:food_recipes_app/models/recipe_page.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:food_recipes_app/widgets/home_recipe_item.dart';
import 'package:food_recipes_app/widgets/shimmer_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum ListType { Newest, Category, Cuisine }

class RecipesListScreen extends StatefulWidget {
  final Category? category;
  final Cuisine? cuisine;
  final ListType? listType;

  const RecipesListScreen(
      {Key? key, this.category, this.cuisine, this.listType})
      : super(key: key);

  @override
  _RecipesListScreenState createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  GlobalKey _contentKey = GlobalKey();
  GlobalKey _refreshKey = GlobalKey();

  List<Recipe> _recipes = [];
  bool _isFetching = true;
  int _recipesPage = 1;

  var _paddingBottom = AppConfig.AdmobEnabled ? 48.0 : 0.0;

  BannerAd? bannerAd;

  @override
  void initState() {
    super.initState();

    _fetchRecipes();
    // _loadAndShowAd();
  }

  @override
  void dispose() {
    super.dispose();
    bannerAd!.dispose();
  }

  // _loadAndShowAd() async {
  //   if (AppConfig.AdmobEnabled) {
  //     bannerAd = BannerAd(
  //       adUnitId: AdmobConfig.bannerAdUnitId,
  //       size: AdSize(width: 300, height: 50),
  //       request: AdRequest(),
  //       listener: BannerAdListener(
  //         // Called when an ad is successfully received.
  //         onAdLoaded: (Ad ad) {},
  //         // Called when an ad request failed.
  //         onAdFailedToLoad: (Ad ad, LoadAdError error) {
  //           // Dispose the ad here to free resources.
  //           ad.dispose();
  //           setState(() => _paddingBottom = 0);
  //           print('Ad failed to load: $error');
  //         },
  //         // Called when an ad opens an overlay that covers the screen.
  //         onAdOpened: (Ad ad) => print('Ad opened.'),
  //         // Called when an ad removes an overlay that covers the screen.
  //         onAdClosed: (Ad ad) => setState(() => _paddingBottom = 0),
  //         // Called when an impression occurs on the ad.
  //         onAdImpression: (Ad ad) => print('Ad impression.'),
  //       ),
  //     );
  //
  //     await bannerAd!.load();
  //     // if (bannerAd.isLoaded) _bannerController.show();
  //   }
  // }

  _fetchRecipes() async {
    RecipePage? recipePage;
    switch (widget.listType) {
      case ListType.Newest:
        recipePage = (await ApiRepository.fetchNewestRecipes(_recipesPage))!;
        break;
      case ListType.Category:
        recipePage = await ApiRepository.fetchRecipeByCategory(
            (widget.category?.id)!, _recipesPage);
        break;
      case ListType.Cuisine:
        recipePage = (await ApiRepository.fetchRecipeByCuisine(
            (widget.cuisine?.id)!, _recipesPage))!;
        break;
      default:
        recipePage = (await ApiRepository.fetchNewestRecipes(_recipesPage))!;
    }

    if (mounted)
      setState(() {
        _recipes = recipePage!.data!;
        _isFetching = false;
      });
  }

  _onRefresh() async {
    RecipePage recipePage;

    setState(() {
      _isFetching = true;
    });
    switch (widget.listType) {
      case ListType.Newest:
        recipePage = (await ApiRepository.fetchNewestRecipes(1))!;
        break;
      case ListType.Category:
        recipePage = (await ApiRepository.fetchRecipeByCategory(
            (widget.category?.id)!, 1))!;
        break;
      case ListType.Cuisine:
        recipePage = (await ApiRepository.fetchRecipeByCuisine(
            (widget.cuisine!.id)!, 1))!;
        break;
      default:
        recipePage = (await ApiRepository.fetchNewestRecipes(1))!;
    }

    _recipes.clear();
    _recipesPage = 1;
    _recipes.addAll(recipePage.data!);

    if (mounted)
      setState(() {
        _refreshController.refreshCompleted();
        _isFetching = false;
      });
  }

  _onLoading() async {
    RecipePage recipePage;
    _recipesPage++;
    switch (widget.listType) {
      case ListType.Newest:
        recipePage = (await ApiRepository.fetchNewestRecipes(_recipesPage))!;
        break;
      case ListType.Category:
        recipePage = (await ApiRepository.fetchRecipeByCategory(
            (widget.category?.id)!, _recipesPage))!;
        break;
      case ListType.Cuisine:
        recipePage = (await ApiRepository.fetchRecipeByCuisine(
            (widget.cuisine!.id)!, _recipesPage))!;
        break;
      default:
        recipePage = (await ApiRepository.fetchNewestRecipes(_recipesPage))!;
    }
    _recipes.addAll(recipePage.data!);
    if (mounted)
      setState(() {
        _refreshController.loadComplete();
      });
  }

  String _displayName() {
    switch (widget.listType) {
      case ListType.Newest:
        return 'recent_recipes'.tr();
      case ListType.Category:
        return (widget.category!.name)!;
      case ListType.Cuisine:
        return (widget.cuisine!.name)!;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration.copyAncestor(
      context: context,
      enableLoadingWhenFailed: true,
      headerBuilder: () => WaterDropMaterialHeader(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      footerTriggerDistance: 30,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(),
        body: _body(),
      ),
    );
  }

  _appBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        _displayName(),
        style: TextStyle(color: Colors.black, fontFamily: 'Brandon'),
      ),
      iconTheme: IconThemeData(color: Colors.black),
    );
  }

  _body() {
    return _isFetching
        ? ShimmerLoading(type: ShimmerType.Recipes)
        : SmartRefresher(
            key: _refreshKey,
            controller: _refreshController,
            enablePullUp: true,
            physics: BouncingScrollPhysics(),
      header: MaterialClassicHeader(),
            footer: ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: _recipes.isNotEmpty
                ? GridView.builder(
                    key: _contentKey,
                    padding: EdgeInsets.only(top: 10, bottom: _paddingBottom),
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
                      style: GoogleFonts.pacifico(fontSize: 17),
                    ),
                  ),
          );
  }

// _buildBannerAd() {
//   return Container(
//     alignment: Alignment.center,
//     width: bannerAd!.size.width.toDouble(),
//     height: bannerAd!.size.height.toDouble(),
//     child: AdWidget(ad: bannerAd!),
//   );
// }
}
