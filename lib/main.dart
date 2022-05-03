import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CartInherited extends InheritedWidget {
  final List<Product> items;
  final Function addItem;
  final Function removeItem;
  final Function clear;
  final Function toggle;

  const CartInherited(
      {Key? key,
      required this.items,
      required this.addItem,
      required this.removeItem,
      required this.clear,
      required this.toggle,
      required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(CartInherited oldWidget) {
    print("old " + oldWidget.items.length.toString());
    print("new " + this.items.length.toString());
    return oldWidget.items != items;
  }
}

class Cart extends StatefulWidget {
  const Cart({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final List<Product> items = [];

  void toggle(Product product) {
    print(items.length);
    if (items.contains(product)) {
      remove(product);
    } else {
      add(product);
    }
  }

  void add(Product product) {
    setState(() {
      items.add(product);
    });
  }

  void remove(Product product) {
    setState(() {
      items.remove(product);
    });
  }

  void clear() {
    setState(() {
      items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CartInherited(
        items: List.from(items),
        toggle: toggle,
        addItem: add,
        removeItem: remove,
        clear: clear,
        child: widget.child);
  }
  // Widget build(BuildContext context) {
  //   return CartInherited(
  //       items: List.from(items),
  //       toggle: toggle,
  //       addItem: add,
  //       removeItem: remove,
  //       clear: clear,
  //       child: widget.child);
  // }
}

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

void main() {
  List<Product> products = const [
    Product(
        name: "helmet",
        price: 2000.00,
        reviews: 104,
        ratings: 3,
        category: ProductCategory.HeadWear,
        imagePath: "assets/products/helmet.png"),
    Product(
        name: "jacket",
        price: 3500.0,
        reviews: 4,
        ratings: 2,
        category: ProductCategory.BodyWear,
        imagePath: "assets/products/jacket.png"),
    Product(
        name: "sidemirror",
        price: 150.0,
        reviews: 25,
        ratings: 4,
        category: ProductCategory.Accessory,
        imagePath: "assets/products/sidemirror.png")
  ];

  runApp(ChangeNotifierProvider(
    create: (context) => CartModel(),
    child: MaterialApp(
      initialRoute: "/",
      onGenerateRoute: (settings) {
        final args = settings.arguments as List<Product>;
        return MaterialPageRoute(
            builder: (context) => Checkout(
                  cart: args,
                ));
      },
      routes: {
        "/": (context) => ShoppingList(products: products),
      },
    ),
  ));

  // runApp(ChangeNotifierProvider(
  //   create: (context) => CartModel(),
  //   child: MaterialApp(
  //     initialRoute: "/",
  //     onGenerateRoute: (settings) {
  //       final args = settings.arguments as List<Product>;
  //       return MaterialPageRoute(
  //           builder: (context) => Checkout(
  //                 cart: args,
  //               ));
  //     },
  //     routes: {
  //       "/": (context) => ShoppingList(products: products),
  //     },
  //   ),
  // ));
}

enum ProductCategory {
  ALL,
  HeadWear,
  BodyWear,
  Accessory,
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
}

class ShoppingList extends StatefulWidget {
  const ShoppingList({Key? key, required this.products}) : super(key: key);

  final List<Product> products;

  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: ProductCategory.values.length, vsync: this);
  }

  List _items = [];

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/products.json');
    final data = await json.decode(response);
    setState(() {
      _items = data["names"];
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<CartModel>(context);
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
            controller: _tabController,
            tabs: ProductCategory.values
                .map((e) => Tab(
                      text: e.name.toString(),
                    ))
                .toList()),
        title: const Text("Shopping List"),
        actions: [
          Row(
            children: [
              Text(provider._items.length.toString()),
              IconButton(
                icon: Icon(Icons.shopping_cart),
                tooltip: 'Show Snackbar',
                onPressed: () => readJson(),
              )
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: TabBarView(
                  controller: _tabController,
                  children: ProductCategory.values
                      .map((e) => ProductItems(
                          products: widget.products,
                          cart: provider._items,
                          category: e,
                          onSelect: provider.toggle))
                      .toList())),
          Footer(
            cart: provider._items,
          ),
        ],
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return Consumer<CartModel>(
  //     builder: (context, cart, child) {
  //       print(_items);
  //       if (_items.length > 0) {
  //         print(_items[0]["name"]);
  //       }
  //       return Scaffold(
  //         appBar: AppBar(
  //           bottom: TabBar(
  //               controller: _tabController,
  //               tabs: ProductCategory.values
  //                   .map((e) => Tab(
  //                         text: e.name.toString(),
  //                       ))
  //                   .toList()),
  //           title: const Text("Shopping List"),
  //           actions: [
  //             Row(
  //               children: [
  //                 Text(cart._items.length.toString()),
  //                 IconButton(
  //                   icon: Icon(Icons.shopping_cart),
  //                   tooltip: 'Show Snackbar',
  //                   onPressed: () => readJson(),
  //                 )
  //               ],
  //             )
  //           ],
  //         ),
  //         body: Column(
  //           children: [
  //             Expanded(
  //                 child: TabBarView(
  //                     controller: _tabController,
  //                     children: ProductCategory.values
  //                         .map((e) => ProductItems(
  //                             products: widget.products,
  //                             cart: cart.items,
  //                             category: e,
  //                             onSelect: cart.toggle))
  //                         .toList())),
  //             Footer(
  //               cart: cart.items,
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}

class ProductItems extends StatelessWidget {
  const ProductItems(
      {Key? key,
      required this.products,
      required this.cart,
      required this.category,
      required this.onSelect})
      : super(key: key);
  final List<Product> products;
  final List<Product> cart;
  final ProductCategory category;
  final Function onSelect;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: ListView(
          children: products
              .where((element) =>
                  element.category == category ||
                  category == ProductCategory.ALL)
              .map((Product product) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: ProductItem(
                product: product,
                onSelect: () => onSelect(product),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }
}

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key, required this.product, required this.onSelect})
      : super(key: key);
  final Product product;
  final Function onSelect;

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context);
    return ListTile(
      subtitle: Column(children: [
        Row(children: [
          Expanded(
              child: Ratings(
            ratings: product.ratings,
          )),
          Text("${product.reviews} Reviews"),
        ]),
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsRoute(
                  product: product,
                ),
              )),
          child: Hero(
              tag: product.name,
              child: Image.asset(
                product.imagePath,
                width: 200,
              )),
        )
      ]),
      title: Row(
        children: [
          Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => onSelect(),
                child: ItemIcon(inCart: cart._items.contains(product)),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(product.name)
            ],
          )),
          Text("P " + product.price.toString())
        ],
      ),
    );
  }
}

class ItemIcon extends StatelessWidget {
  const ItemIcon({Key? key, required this.inCart}) : super(key: key);

  final bool inCart;

  @override
  Widget build(BuildContext context) {
    return inCart
        ? Icon(
            Icons.remove,
            color: Colors.red,
          )
        : Icon(
            Icons.add,
            color: Colors.green,
          );
  }
}

class Ratings extends StatelessWidget {
  const Ratings({Key? key, this.ratings = 0}) : super(key: key);
  final int ratings;
  final maxRating = 5;
  checkRating(int num, int rating) {
    if (num <= rating) {
      return Colors.green;
    } else {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: checkRating(1, ratings),
        ),
        Icon(
          Icons.star,
          color: checkRating(2, ratings),
        ),
        Icon(
          Icons.star,
          color: checkRating(3, ratings),
        ),
        Icon(
          Icons.star,
          color: checkRating(4, ratings),
        ),
        Icon(
          Icons.star,
          color: checkRating(5, ratings),
        ),
      ],
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({Key? key, required this.cart}) : super(key: key);

  final List<Product> cart;

  double getTotal() {
    if (cart.isEmpty) return 0;
    Product total = cart.reduce((value, element) => Product(
        name: "total",
        category: ProductCategory.ALL,
        price: value.price + element.price));

    return total.price;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
                child: Row(
              children: [
                const Icon(Icons.shopping_cart),
                Text(cart.length.toString()),
                GestureDetector(
                  child: Text("Checkout"),
                  onTap: () => Navigator.pushNamed(context, '/checkouts',
                      arguments: cart),
                )
              ],
            )),
            Container(
              child: Text("Total Amount: " + getTotal().toString()),
            )
          ],
        ));
  }
}

class ProductDetailsRoute extends StatelessWidget {
  const ProductDetailsRoute({Key? key, required this.product})
      : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details"),
      ),
      body: Center(
        child: Column(
          children: [
            Hero(
                tag: product.name,
                child: Image(image: AssetImage(product.imagePath))),
            Text("Product: " + product.name),
            Text("Amount: " + product.price.toString()),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Back to list"))
          ],
        ),
      ),
    );
  }
}

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
