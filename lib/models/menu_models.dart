class MenuModel {
  final int id;
  final String name;
  final int price;
  final String description;
  final String image;

  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
