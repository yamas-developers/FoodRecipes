import 'dart:convert';

AppUser appUserFromJson(String str) => AppUser.fromJson(json.decode(str));

String appUserToJson(AppUser data) => json.encode(data.toJson());

class AppUser {
  final int? id;
  final String? name;
  final String? email;
  final int? usertype;
  final int? status;
  final dynamic emailVerifiedAt;
  final String? image;
  final dynamic authKey;
  final dynamic deviceToken;
  final dynamic instragramUrl;
  final dynamic facebookUrl;
  final dynamic pinterestUrl;
  final dynamic youtubeUrl;
  final String? createdAt;
  final String? updatedAt;

  AppUser({
    this.id,
    this.name,
    this.email,
    this.usertype,
    this.status,
    this.emailVerifiedAt,
    this.image,
    this.authKey,
    this.deviceToken,
    this.instragramUrl,
    this.facebookUrl,
    this.pinterestUrl,
    this.youtubeUrl,
    this.createdAt,
    this.updatedAt,
  });

  AppUser.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        email = json['email'] as String?,
        usertype = json['usertype'] as int?,
        status = json['status'] as int?,
        emailVerifiedAt = json['email_verified_at'],
        image = json['image'] as String?,
        authKey = json['authKey'],
        deviceToken = json['device_token'],
        instragramUrl = json['instragramUrl'],
        facebookUrl = json['facebookUrl'],
        pinterestUrl = json['pinterestUrl'],
        youtubeUrl = json['youtubeUrl'],
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'usertype': usertype,
        'status': status,
        'email_verified_at': emailVerifiedAt,
        'image': image,
        'authKey': authKey,
        'device_token': deviceToken,
        'instragramUrl': instragramUrl,
        'facebookUrl': facebookUrl,
        'pinterestUrl': pinterestUrl,
        'youtubeUrl': youtubeUrl,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}
