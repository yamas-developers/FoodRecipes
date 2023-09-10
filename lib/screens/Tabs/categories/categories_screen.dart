import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_recipes_app/models/category.dart';
import 'package:food_recipes_app/providers/category_provider.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:food_recipes_app/widgets/grid_view_item.dart';
import 'package:food_recipes_app/widgets/shimmer_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../Components/entry_field.dart';
import '../../../Theme/colors.dart';
import '../../../models/recipe.dart';
import '../../../providers/recipe_provider.dart';
import '../../../utils/utils.dart';
import '../../../widgets/search_text_field.dart';
import '../home/search/search_screen.dart';

class CategoriesScreen extends StatefulWidget {
  static const routeName = '/categories';

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CategoryProvider _categoryProvider;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  GlobalKey _contentKey = GlobalKey();
  GlobalKey _refreshKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _fetchCategories();
    startTimer();
  }

  int generateRandomNumber() {
    Random random = Random();
    return random.nextInt(context
        .read<RecipeProvider>()
        .mostCollectedRecipes
        .length); // Generates a random number between 0 and maxNumber (inclusive)
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        randomRecipeIndex = generateRandomNumber();
      });
    });
  }

  _fetchCategories() async {
    try {
      await Provider.of<CategoryProvider>(context, listen: false)
          .fetchOrDisplayPaginatedCategories();
    } catch (err) {
      print('[_fetchCategories] :: error ' + err.toString());
    }
  }

  _onRefresh() async {
    await _categoryProvider.fetchPaginatedCategories(refresh: true);
    if (mounted)
      setState(() {
        _refreshController.refreshCompleted();
      });
  }

  _onLoading() async {
    await _categoryProvider.fetchPaginatedCategories(loading: true);
    if (mounted)
      setState(() {
        _refreshController.loadComplete();
      });
  }

  @override
  void dispose() {
    if (timer != null) timer?.cancel();
    super.dispose();
  }

  TextEditingController _searchKeywordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: RefreshConfiguration.copyAncestor(
        context: context,
        enableLoadingWhenFailed: true,
        headerBuilder: () => WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        footerTriggerDistance: 30,
        child: Scaffold(
          appBar: _appBar(),
          body: _body(),
        ),
      ),
    );
  }

  bool _isFocused = false;
  FocusNode _focusNode = FocusNode();
  int randomRecipeIndex = 0;
  Timer? timer;

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  _buildSearchField() {
    return Consumer<RecipeProvider>(builder: (context, recipePro, child) {
      List<Recipe> _recipes = recipePro.mostCollectedRecipes;
      Recipe? recipe = _recipes.length > 0
          ? randomRecipeIndex < _recipes.length
              ? _recipes[randomRecipeIndex]
              : _recipes.first
          : null;
      return Stack(
        children: [
          SearchTextfield(
            focusNode: _focusNode,
            hintText: '',
            controller: _searchKeywordController,
            onTap: () {
              setState(() {
                _isFocused = true;
              });
            },
            suffixIconOnTap: () {
              setState(() {
                _isFocused = false;
              });
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
          ),
          Container(
            // width: MediaQuery.of(context).size.width * 0.7,
            height: 35,
            padding: const EdgeInsets.only(left: 30, top: 16, right: 50),
            child: GestureDetector(
              onTap: () {
                _focusNode.requestFocus();
              },
              child: DefaultTextStyle(
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                child: AnimatedTextKit(
                  isRepeatingAnimation: true,
                  repeatForever: true,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      '${'search_for'.tr()} ${recipe?.name ?? 'recipes'}',
                      speed: Duration(milliseconds: 100),
                    ),
                  ],
                  onTap: () {
                    print("Tap Event");
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  _appBar() {
    return AppBar(
      // centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0.0,
      // iconTheme: IconThemeData(color: Colors.black),
      leading: buildSimpleBackArrow(context),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          'categories'.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontSize: 32, fontWeight: FontWeight.w700),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: true
            ? _buildSearchField()
            : Row(
                children: [
                  Icon(
                    Icons.search,
                    color: fontSecondary,
                    size: 24,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 6),
                    child: Text(
                      'search_recipes'.tr(),
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: fontSecondary,
                          ),
                    ),
                  )),
                ],
              ),
      ),
    );
  }

  _body() {
    return Consumer<CategoryProvider>(
      builder: (context, category, child) {
        if (category.categoryStatus == CategoryStatus.Fetching) {
          return ShimmerLoading(type: ShimmerType.Categories);
        } else {
          List<Category> _categories = category.paginatedCategories;
          return _categories.isNotEmpty
              ? SmartRefresher(
                  key: _refreshKey,
                  controller: _refreshController,
                  enablePullUp: true,
                  header: MaterialClassicHeader(color: primaryColor),
                  physics: BouncingScrollPhysics(),
                  footer: ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: GridView(
                    key: _contentKey,
                    physics: BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(15),
                    children: _categories
                        .map((category) => GridViewItem(
                              category: category,
                              path: ApiRepository.CATEGORY_IMAGES_PATH,
                            ))
                        .toList(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.72,
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                    // gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    //   maxCrossAxisExtent: 200,
                    //   childAspectRatio: 3 / 2,
                    //   crossAxisSpacing: 15,
                    //   mainAxisSpacing: 15,
                    // ),
                  ),
                )
              : Center(
                  child: Text(
                    'no_categories_found'.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: 16),
                  ),
                );
        }
      },
    );
  }
}
