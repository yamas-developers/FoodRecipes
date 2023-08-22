import 'dart:convert';

List<Difficulty> difficultyFromJson(String str) =>
    List<Difficulty>.from(json.decode(str).map((x) => Difficulty.fromJson(x)));

String difficultyToJson(List<Difficulty> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Difficulty {
  final int? id;
  final String? languageCode;
  final String? name;

  Difficulty({
    this.id,
    this.languageCode,
    this.name,
  });

  Difficulty.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        languageCode = json['language_code'] as String?,
        name = json['difficulty'] as String?;

  Map<String, dynamic> toJson() =>
      {'id': id, 'language_code': languageCode, 'difficulty': name};
}
