import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_recipes_app/models/recipe.dart';
import 'package:food_recipes_app/providers/app_provider.dart';
import 'package:food_recipes_app/screens/Other/recipe-details/recipe_details_screen.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:food_recipes_app/utils/utils.dart';
import 'package:food_recipes_app/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class HomeRecipeItem extends StatefulWidget {
  final Recipe recipe;

  HomeRecipeItem({required this.recipe});

  @override
  _HomeRecipeItemState createState() => _HomeRecipeItemState();
}

class _HomeRecipeItemState extends State<HomeRecipeItem> {
  String recipePath = ApiRepository.RECIPE_IMAGES_PATH;

  _navigateToRecipeDetailsScreen() async {
    await Provider.of<AppProvider>(context, listen: false)
        .incrementAdClickCount();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(recipe: widget.recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToRecipeDetailsScreen(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRecipeImage(),
            _buildRecipeDetails(),
          ],
        ),
      ),
    );
  }

  _buildRecipeImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: EdgeInsets.only(top: 5),
            child: ClipRRect(
              child: CachedNetworkImage(
                imageUrl: '$recipePath${widget.recipe.image}',
                placeholder: (context, url) => ShimmerWidget(
                  width: 150,
                  height: 150,
                  circular: false,
                ),
                width: MediaQuery.of(context).size.width * 0.38,
                height: MediaQuery.of(context).size.width * 0.36,
                // height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 10),
          //   padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).primaryColor,
          //     borderRadius: BorderRadius.circular(5),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       Icon(Icons.history, color: Colors.white, size: 15),
          //       Text(
          //         getDuration(widget.recipe.duration.toString()),
          //         style: TextStyle(
          //           fontSize: 10.5,
          //           color: Colors.white,
          //           fontFamily: 'Brandon',
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  _buildRecipeDetails() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildDifficulty(),
          _buildRecipeName(),
          // _buildRecipeUserInfo(),
        ],
      ),
    );
  }

  _buildDifficulty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      child: Text(
        widget.recipe.difficulty!.name!.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
          fontFamily: 'Brandon',
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  _buildRecipeName() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
      child: Text(
        widget.recipe.name!,
        maxLines: 2,
        style: TextStyle(
          fontFamily: 'Brandon',
          fontSize: 17,
          color: Colors.black.withOpacity(0.7),
        ),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  _buildRecipeUserInfo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: Row(
        children: [
          (widget.recipe.user!.image != '')
              ? (widget.recipe.user!.image!.contains('https'))
                  ? CircleAvatar(
                      backgroundImage:
                          NetworkImage('${widget.recipe.user!.image}'),
                      radius: 10,
                      backgroundColor: Colors.white,
                    )
                  : CircleAvatar(
                      backgroundImage: NetworkImage(
                          '${ApiRepository.USER_IMAGES_PATH}${widget.recipe.user?.image}'),
                      radius: 10,
                      backgroundColor: Colors.white,
                    )
              : CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/logo_user.png'),
                  radius: 10,
                ),
          SizedBox(width: 5),
          Text(
            (widget.recipe.user!.name)!,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Brandon',
              fontWeight: FontWeight.normal,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
