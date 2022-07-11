import 'package:decor_my_home/pages/cart.dart';
import 'package:decor_my_home/pages/login.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: Login(),
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/cart': (context) => const Cart(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      // '/second': (context) => const SecondRoute(),
    },
  ));
}
