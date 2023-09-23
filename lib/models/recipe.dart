import 'dart:convert';

import 'package:food_recipes_app/models/app_user.dart';
import 'package:food_recipes_app/models/category.dart';
import 'package:food_recipes_app/models/difficulty.dart';
import 'package:food_recipes_app/models/ingredientsItem.dart';

import 'cuisine.dart';

List<Recipe> recipeFromJson(String str) =>
    List<Recipe>.from(json.decode(str).map((x) => Recipe.fromJson(x)));

String recipeToJson(List<Recipe> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Recipe {
  final int? id;
  final String? languageCode;
  final int? userId;
  final String? name;
  final String? image;
  final int? duration;
  final int? noOfServing;
  final int? difficultyId;
  final int? cuisineId;
  final String? ingredients;
  final String? steps;
  final String? websiteUrl;
  final String? youtubeUrl;
  final int? noOfViews;
  final int? noOfLikes;
  final int? status;
  final double? rating;
  final String? createdAt;
  final String? updatedAt;
  final AppUser? user;
  final Difficulty? difficulty;
  final Cuisine? cuisine;
  final List<Category>? categories;
  final List<IngredientsItem>? ingredientsItem;

  Recipe(
      {this.id,
      this.languageCode,
      this.userId,
      this.name,
      this.image,
      this.duration,
      this.noOfServing,
      this.difficultyId,
      this.cuisineId,
      this.ingredients,
      this.steps,
      this.websiteUrl,
      this.youtubeUrl,
      this.noOfViews,
      this.noOfLikes,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.user,
      this.difficulty,
      this.cuisine,
      this.categories,
      this.ingredientsItem,
      this.rating});

  Recipe.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        languageCode = json['language_code'] as String?,
        userId = json['userId'] as int?,
        name = json['name'] as String?,
        image = json['image'] as String?,
        duration = json['duration'] as int?,
        noOfServing = json['noOfServing'] as int?,
        difficultyId = json['difficulty_id'] as int?,
        cuisineId = json['cuisine_id'] as int?,
        ingredients = json['ingredients'] as String?,
        steps = json['steps'] as String?,
        categories = json["recipecategories"] != null
            ? (json["recipecategories"] as List)
                .where((element) => element['category'] != null)
                .map<Category>(
                    (json) => new Category.fromJson(json['category']))
                .toList()
            : null,
        websiteUrl = json['websiteUrl'] as String?,
        youtubeUrl = json['youtubeUrl'] as String?,
        noOfViews = json['noOfViews'] as int?,
        noOfLikes = json['noOfLikes'] as int?,
        status = json['status'] as int?,
        rating = json['average_rating'] == null
            ? null
            : double.parse(json['average_rating'].toString()),
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        user = (json['user'] as Map<String, dynamic>?) != null
            ? AppUser.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        difficulty = (json['difficulty'] as Map<String, dynamic>?) != null
            ? Difficulty.fromJson(json['difficulty'] as Map<String, dynamic>)
            : null,
        cuisine = (json['cuisine'] as Map<String, dynamic>?) != null
            ? Cuisine.fromJson(json['cuisine'] as Map<String, dynamic>)
            : null,
        ingredientsItem = json["ingredients_item"] != null
            ? (json["ingredients_item"] as List)
                .map<IngredientsItem>(
                    (json) => new IngredientsItem.fromJson(json))
                .toList()
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'language_code': languageCode,
        'userId': userId,
        'name': name,
        'image': image,
        'duration': duration,
        'noOfServing': noOfServing,
        'difficulty_id': difficultyId,
        "cuisine": cuisine?.toJson(),
        "cuisine_id": cuisineId == null ? null : cuisineId,
        'ingredients': ingredients,
        'steps': steps,
        'websiteUrl': websiteUrl,
        'youtubeUrl': youtubeUrl,
        'noOfViews': noOfViews,
        'noOfLikes': noOfLikes,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'user': user?.toJson(),
        'difficulty': difficulty?.toJson(),
        'ingredients_item': ingredients,
        'recipecategories': categories,
        'average_rating': rating,
      };
}
