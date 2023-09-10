import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_recipes_app/models/recipe.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:food_recipes_app/widgets/home_recipe_item.dart';
import 'package:food_recipes_app/widgets/search_text_field.dart';
import 'package:food_recipes_app/widgets/shimmer_loading.dart';
import 'package:easy_localization/easy_localization.dart';

class SearchScreen extends StatefulWidget {
  final String? keyword;

  SearchScreen({this.keyword});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchKeywordController = TextEditingController();
  bool _isLoading = false;
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();

    _searchKeywordController.text = widget.keyword ?? '';

    _fetchRecipes();
  }

  _fetchRecipes() async {
    FocusScope.of(context).unfocus();
    FocusScope.of(context).requestFocus(FocusNode());
    // if (widget.keyword != _searchKeywordController.text) {
    // }
    setState(() {
      _isLoading = true;
    });
    if (_searchKeywordController.text.isNotEmpty) {
      await ApiRepository.fetchSearchedRecipes(_searchKeywordController.text)
          .then((recipes) {
        if (recipes.isNotEmpty) {
          if (mounted)
            setState(() {
              _recipes = recipes;
              _isLoading = false;
            });
        }
      });
    } else {
      setState(() {
        _recipes.clear();
        _isLoading = false;
      });
    }
  }

  _onChanged() {
    if (_searchKeywordController.text.isEmpty)
      setState(() {
        _recipes.clear();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'search'.tr(),
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(fontSize: 32, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildSearchResultList(),
        ],
      ),
    );
  }

  _buildSearchField() {
    return SearchTextfield(
      hintText: 'search_recipe_here'.tr(),
      controller: _searchKeywordController,
      suffixIconOnTap: () => _fetchRecipes(),
      onChanged: () => _onChanged(),
    );
  }

  Widget _buildSearchResultList() {
    if (!_isLoading) {
      if (_searchKeywordController.text.isNotEmpty) {
        if (_recipes.isNotEmpty) {
          return Expanded(
            // height: 400,
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              itemCount: _recipes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.68,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemBuilder: (context, index) =>
                  HomeRecipeItem(recipe: _recipes[index]),
            ),
          );
        } else {
          return _buildMessageText('no_recipes_to_display'.tr());
        }
      } else
        return _buildMessageText('start_looking_for_recipes'.tr());
    } else {
      return Expanded(child: ShimmerLoading(type: ShimmerType.Recipes));
    }
  }

  _buildMessageText(String text) {
    return Expanded(
      child: Center(
        child: Text(
          'start_looking_for_recipes'.tr(),
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
