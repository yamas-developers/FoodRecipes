// To parse this JSON data, do
//
//     final comment = commentFromJson(jsonString);

import 'dart:convert';

import 'package:const_date_time/const_date_time.dart';

import 'app_user.dart';

List<Comment> commentFromJson(String str) =>
    List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

String commentToJson(List<Comment> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Comment {
  Comment({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.comment,
    this.createdAt = const ConstDateTime(0),
    this.updatedAt = const ConstDateTime(0),
    required this.user,
  });

  int id;
  int userId;
  int recipeId;
  String comment;
  DateTime createdAt;
  DateTime updatedAt;
  AppUser user;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        userId: json["userId"],
        recipeId: json["recipeId"],
        comment: json["comment"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        user: AppUser.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "recipeId": recipeId,
        "comment": comment,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "user": user.toJson(),
      };
}
