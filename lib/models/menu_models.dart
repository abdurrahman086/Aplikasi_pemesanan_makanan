// To parse this JSON data, do

//     final menuModel = menuModelFromJson(jsonString);

import 'dart:convert';

List<MenuModel> menuModelFromJson(String str) =>
    List<MenuModel>.from(json.decode(str).map((x) => MenuModel.fromJson(x)));

String menuModelToJson(List<MenuModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MenuModel {
  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  int id;
  String name;
  int price;
  String description;
  String image;

  // factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
  //       id: json["id"],
  //       name: json["name"],
  //       price: int.parse(json["price"]),
  //       description: json["description"],
  //       image: json["image"],
  //     );
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    int price = 10; // Default value for price
    try {
      price = int.parse(json["price"]);
    } catch (e) {
      print("Failed to parse price: ${json["price"]}");
      // Handle the error, for example, by setting a default value
      // or marking the item as invalid
    }
    return MenuModel(
      id: json["id"],
      name: json["name"],
      price: price,
      description: json["description"],
      image: json["image"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price.toString(),
        "description": description,
        "image": image,
      };
}


// class MenuModel {
//   dynamic id;
//   String name;
//   dynamic price;
//   String description;
//   String image;

//   MenuModel({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.description,
//     required this.image,
//   });

//   static MenuModel fromJson(element) {
//     return MenuModel(
//       id: element['id'],
//       name: element['name'],
//       price: element['price'],
//       description: element['description'],
//       image: element['image'],
//     );
//   }
// }

// class MenuModel {
//   MenuModel({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.description,
//     required this.image,
//   });

//   final dynamic id;
//   final String? name;
//   final dynamic price;
//   final String? description;
//   final String? image;

//   factory MenuModel.fromJson(Map<String, dynamic> json) {
//     return MenuModel(
//       id: json["id"],
//       name: json["name"],
//       price: json["price"],
//       description: json["description"],
//       image: json["image"],
//     );
//   }
// }
