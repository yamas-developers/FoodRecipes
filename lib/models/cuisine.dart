// To parse this JSON data, do
//
//     final cuisine = cuisineFromJson(jsonString);

import 'dart:convert';

List<Cuisine> cuisineFromJson(String str) =>
    List<Cuisine>.from(json.decode(str).map((x) => Cuisine.fromJson(x)));

String cuisineToJson(List<Cuisine> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Cuisine {
  final int? id;
  final String? languageCode;
  final String? name;
  final String? image;
  final int? status;
  final String? createdAt;
  final String? updatedAt;

  Cuisine({
    this.id,
    this.languageCode,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Cuisine.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        languageCode = json['language_code'] as String?,
        name = json['name'] as String?,
        image = json['image'] as String?,
        status = json['status'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'language_code': languageCode,
        'name': name,
        'image': image,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}
