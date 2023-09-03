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

  _appBar() {
    return AppBar(
      // centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.black),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          'categories'.tr(),
          style: TextStyle(
              color: Colors.black, fontFamily: 'Brandon', fontSize: 24),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => SearchScreen(
                  keyword: '',
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 3),
                  )
                ]),
            child: Row(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
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
                  physics: BouncingScrollPhysics(),
                  footer: ClassicFooter(loadStyle: LoadStyle.ShowWhenLoading),
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: GridView(
                    key: _contentKey,
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
                    style: GoogleFonts.pacifico(fontSize: 16),
                  ),
                );
        }
      },
    );
  }
}
