import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes_app/models/category.dart';
import 'package:food_recipes_app/models/cuisine.dart';
import 'package:food_recipes_app/screens/Tabs/home/recipes_list/recipes_list_screen.dart';
import 'package:food_recipes_app/widgets/shimmer_widget.dart';

class GridViewItem extends StatelessWidget {
  final Category? category;
  final Cuisine? cuisine;
  final String path;

  GridViewItem({this.category, this.cuisine, this.path = ''});

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return category != null
              ? RecipesListScreen(
                  category: category!,
                  listType: ListType.Category,
                )
              : RecipesListScreen(
                  cuisine: cuisine!,
                  listType: ListType.Cuisine,
                );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectCategory(context),
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: EdgeInsets.only(right: 7),
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).highlightColor),
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).scaffoldBackgroundColor),
        padding: EdgeInsets.only(bottom: 10, top: 5),
        child: Column(
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            _buildCategoryImage(),
            Spacer(
              flex: 2,
            ),
            _buildCategoryName(context),
            Spacer(),
          ],
        ),
      ),
    );
  }

  _buildCategoryImage() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: category != null
            ? '$path${category?.image}'
            : '$path${cuisine?.image}',
        placeholder: (context, url) => ShimmerWidget(
          width: 80,
          height: 80,
          circular: false,
        ),
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      ),
    );
  }

  _buildCategoryName(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              category != null ? '${category?.name}' : '${cuisine?.name}',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontSize: 16, fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ],
    );
  }
}
