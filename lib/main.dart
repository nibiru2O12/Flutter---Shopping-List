import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';

import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hello_world/model/User.dart';
import 'package:hello_world/views/checkout.dart';
import 'package:hello_world/views/shopping_list.dart';
import 'package:hello_world/views/user_info.dart';
import 'package:provider/provider.dart';

import './model/Product.dart';
import './model/Cart.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);
  @override
  _MainAppState createState() => _MainAppState();
}

User getLoggedUser() {
  return User(
      last_name: "last_name",
      first_name: "first_name",
      gender: "MALE",
      address: "address",
      contact: "contact",
      email: "email");
}

class _MainAppState extends State<MainApp> {
  late Future<List<Product>> products;

  late User loggeduser;

  @override
  void initState() {
    super.initState();
    products = getProducts();
    loggeduser = getLoggedUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: products,
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {
          return const CircularProgressIndicator();
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<CartModel>(
              create: (context) => CartModel(),
            )
          ],
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
              "/": (context) => ShoppingList(
                    products: snapshot.data as List<Product>,
                    refresh: () {
                      setState(() {
                        products = getProducts();
                      });
                    },
                  ),
              "user-info": (context) => UserInfoPage()
            },
          ),
        );
      },
    );
  }
}
