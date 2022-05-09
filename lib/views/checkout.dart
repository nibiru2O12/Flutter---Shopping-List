import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/model/Product.dart';

class Checkout extends StatelessWidget {
  const Checkout({Key? key, required this.cart}) : super(key: key);
  final List<Product> cart;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: ListView(
        children: cart.map((e) => CheckoutItem(product: e)).toList(),
      ),
    );
  }
}

class CheckoutItem extends StatelessWidget {
  const CheckoutItem({Key? key, required this.product}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text(product.price.toString()),
    );
  }
}
