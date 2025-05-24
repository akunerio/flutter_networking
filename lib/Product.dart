import 'dart:convert';

class Products {
  final int id;
  final String name;
  final int price;

  const Products({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }
}
