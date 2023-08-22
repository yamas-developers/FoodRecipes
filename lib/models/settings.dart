// To parse this JSON data, do
//
//     final settings = settingsFromJson(jsonString);

import 'dart:convert';

import 'package:const_date_time/const_date_time.dart';

Settings settingsFromJson(String str) => Settings.fromJson(json.decode(str));

String settingsToJson(Settings data) => json.encode(data.toJson());

class Settings {
  Settings({
    required this.id,
    this.fcmKey = '',
    this.autoApprove = 1,
    this.privacyPolicy = '',
    this.termsAndConditions = '',
    this.createdAt = const ConstDateTime(0),
    this.updatedAt = const ConstDateTime(0),
  });

  int id;
  String fcmKey;
  int autoApprove;
  String privacyPolicy;
  String termsAndConditions;
  DateTime createdAt;
  DateTime updatedAt;

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        id: json["id"],
        fcmKey: json["fcm_key"],
        autoApprove: json["auto_approve"],
        privacyPolicy: json["privacy_policy"],
        termsAndConditions: json["terms_and_conditions"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fcm_key": fcmKey,
        "auto_approve": autoApprove,
        "privacy_policy": privacyPolicy,
        "terms_and_conditions": termsAndConditions,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
