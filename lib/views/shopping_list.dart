import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/model/Cart.dart';
import 'package:hello_world/model/Product.dart';
import 'package:provider/provider.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({Key? key, required this.products, required this.refresh})
      : super(key: key);

  final List<Product> products;
  final Function refresh;
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

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<CartModel>(context);
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text("Navigation")),
            ListTile(
              title: Text("Click ME!"),
            ),
            ListTile(
              title: Text("Click ME!"),
            ),
            InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: ListTile(
                  title: Text("Close"),
                ))
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              label: "Favorite", icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(
              label: "Messages",
              icon: Badge(
                showBadge: false,
                child: Icon(Icons.message),
              )),
          BottomNavigationBarItem(
              label: "Cart",
              icon: Badge(
                toAnimate: false,
                showBadge: provider.items.length > 0,
                badgeContent: Text(
                  provider.items.length.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                child: Icon(Icons.shopping_cart_checkout),
              )),
          BottomNavigationBarItem(
              label: "Settings",
              icon: GestureDetector(
                child: Icon(Icons.settings),
                onTap: () => Navigator.of(context).pushNamed("user-info"),
              )),
        ],
      ),
      appBar: AppBar(
        bottom: TabBar(
            isScrollable: true,
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
              Text(provider.items.length.toString()),
              IconButton(
                icon: Icon(Icons.shopping_cart),
                tooltip: 'Show Snackbar',
                onPressed: () => widget.refresh(),
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
                          cart: provider.items,
                          category: e,
                          onSelect: provider.toggle))
                      .toList())),
          Footer(
            cart: provider.items,
          ),
        ],
      ),
    );
  }
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

  Future<void> _refresh() {
    return Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: RefreshIndicator(
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
                ),
                onRefresh: _refresh)),
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
                child: ItemIcon(inCart: cart.items.contains(product)),
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

  void showClearWarning(
      {required BuildContext context, required Function onOk}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Alert"),
            content: Text("Are your sure you want to clear your car?"),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    onOk();
                    Navigator.of(context).pop();
                  },
                  child: Text("Continue")),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<CartModel>(context);

    return Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
                child: Row(
              children: [
                Badge(
                  toAnimate: false,
                  badgeContent: Text(provider.items.length.toString()),
                  child: Icon(Icons.shopping_cart),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  child: Text("Checkout"),
                  onTap: () => Navigator.pushNamed(context, '/checkouts',
                      arguments: cart),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () =>
                      showClearWarning(context: context, onOk: provider.clear),
                  child: GestureDetector(
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        Text(
                          "Clear",
                          style: TextStyle(color: Colors.red),
                        )
                      ],
                    ),
                    onTap: null,
                  ),
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
    var provider = Provider.of<CartModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details"),
      ),
      body: Center(
        child: Column(
          children: [
            Hero(
                tag: product.name,
                child: InteractiveViewer(
                  child: Image(image: AssetImage(product.imagePath)),
                )),
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
