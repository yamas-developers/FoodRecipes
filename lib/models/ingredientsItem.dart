import 'dart:ffi';

class IngredientsItem {
  String? id;
  String? recipeId;
  String? itemId;
  double? quantity;
  String? createdAt;
  String? updatedAt;
  Item? item;

  IngredientsItem(
      {this.id,
      this.recipeId,
      this.itemId,
      this.quantity,
      this.createdAt,
      this.updatedAt,
      this.item});

  IngredientsItem.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    recipeId = json['recipe_id'].toString();
    itemId = json['item_id'].toString();
    quantity = double.parse(json['quantity']??0.0);
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    item = json['item'] != null ? new Item.fromJson(json['item']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['recipe_id'] = this.recipeId;
    data['item_id'] = this.itemId;
    data['quantity'] = this.quantity;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.item != null) {
      data['item'] = this.item!.toJson();
    }
    return data;
  }
}

class Item {
  String? id;
  String? name;
  String? description;
  String? image;
  String? unit;
  String? unitVolume;
  int? calories;
  String? createdAt;
  String? updatedAt;

  Item(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.unit,
      this.unitVolume,
      this.calories,
      this.createdAt,
      this.updatedAt});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'];
    description = json['description'];
    image = json['image'];
    unit = json['unit'];
    unitVolume = json['unit_volume'];
    calories = json['calories'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['unit'] = this.unit;
    data['unit_volume'] = this.unitVolume;
    data['calories'] = this.calories;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
