import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'Product.dart';

class CartModel extends ChangeNotifier {
  final List<Product> _items = [];

  UnmodifiableListView<Product> get items => UnmodifiableListView(_items);

  void toggle(Product product) {
    if (_items.contains(product)) {
      remove(product);
    } else {
      add(product);
    }
  }

  void add(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void remove(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
