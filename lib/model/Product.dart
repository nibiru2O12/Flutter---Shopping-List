import 'dart:convert';

import 'package:flutter/services.dart';

enum ProductCategory { ALL, HeadWear, BodyWear, Accessory, Others }
ProductCategory getCategory(String category) {
  switch (category.toLowerCase()) {
    case "headwear":
      return ProductCategory.HeadWear;
    case "bodywear":
      return ProductCategory.BodyWear;
    case "accessory":
      return ProductCategory.Accessory;
  }
  return ProductCategory.Others;
}

class Product {
  const Product(
      {required this.name,
      required this.price,
      this.reviews = 0,
      this.ratings = 0,
      this.imagePath = "",
      required this.category});
  final String name;
  final double price;
  final int reviews;
  final int ratings;
  final String imagePath;
  final ProductCategory category;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
      name: json["name"],
      price: json["price"],
      reviews: json['reviews'],
      ratings: json['ratings'],
      imagePath: json['image_path'],
      category: getCategory(json["category"]));
}

Future<List<Product>> getProducts() async {
  var data = jsonDecode(await rootBundle.loadString("assets/products.json"));
  var products = data["products"];
  return (products as List).map((e) => Product.fromJson(e)).toList();
}
