// To parse this JSON data, do
//
//     final cuisinePage = cuisinePageFromJson(jsonString);

import 'dart:convert';

import 'package:food_recipes_app/models/cuisine.dart';

CuisinePage cuisinePageFromJson(String str) =>
    CuisinePage.fromJson(json.decode(str));

String cuisinePageToJson(CuisinePage data) => json.encode(data.toJson());

class CuisinePage {
  final int? currentPage;
  final List<Cuisine>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Links>? links;
  final dynamic nextPageUrl;
  final String? path;
  final String? perPage;
  final dynamic prevPageUrl;
  final int? to;
  final int? total;

  CuisinePage({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  CuisinePage.fromJson(Map<String, dynamic> json)
      : currentPage = json['current_page'] as int?,
        data = (json['data'] as List?)
            ?.map((dynamic e) => Cuisine.fromJson(e as Map<String, dynamic>))
            .toList(),
        firstPageUrl = json['first_page_url'] as String?,
        from = json['from'] as int?,
        lastPage = json['last_page'] as int?,
        lastPageUrl = json['last_page_url'] as String?,
        links = (json['links'] as List?)
            ?.map((dynamic e) => Links.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextPageUrl = json['next_page_url'],
        path = json['path'] as String?,
        perPage = json['per_page'] as String?,
        prevPageUrl = json['prev_page_url'],
        to = json['to'] as int?,
        total = json['total'] as int?;

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'data': data?.map((e) => e.toJson()).toList(),
        'first_page_url': firstPageUrl,
        'from': from,
        'last_page': lastPage,
        'last_page_url': lastPageUrl,
        'links': links?.map((e) => e.toJson()).toList(),
        'next_page_url': nextPageUrl,
        'path': path,
        'per_page': perPage,
        'prev_page_url': prevPageUrl,
        'to': to,
        'total': total
      };
}

class Links {
  final String? url;
  final dynamic label;
  final bool? active;

  Links({
    this.url,
    this.label,
    this.active,
  });

  Links.fromJson(Map<String, dynamic> json)
      : url = json['url'] as String?,
        label = json['label'],
        active = json['active'] as bool?;

  Map<String, dynamic> toJson() =>
      {'url': url, 'label': label, 'active': active};
}
