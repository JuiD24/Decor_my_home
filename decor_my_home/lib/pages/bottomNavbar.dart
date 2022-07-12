import 'package:decor_my_home/components/drawer.dart';
import 'package:decor_my_home/pages/cart.dart';
import 'package:decor_my_home/pages/department.dart';
import 'package:decor_my_home/pages/login.dart';
import 'package:decor_my_home/pages/wishlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  int _currentIndex = 0;
  late String? username = "";
  late String? userID = "";
  late String? userURL = "";

  void getDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print(preferences.getString("id"));

    username = preferences.getString("username");
    userURL = preferences.getString("photoUrl");
    userID = preferences.getString("id");
  }

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  final List<Widget> _children = [
    const Department(),
    const Cart(),
    const Wishlist(),
  ];

  void _selectPage(int index) {
    print("inside se");
    print(index);
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Decor'),
        //   backgroundColor: const Color.fromARGB(255, 177, 75, 131),
        //   actions: [
        //     IconButton(
        //       icon: const Icon(
        //         Icons.logout,
        //         color: Colors.white,
        //       ),
        //       onPressed: _signOut,
        //     )
        //   ],
        // ),
        drawer: const DrawerDetails(),
        body: _children.elementAt(_currentIndex), // new
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            // selectedItemColor: Color.fromARGB(255, 0, 110, 255),
            onTap: _selectPage,
            type: BottomNavigationBarType.shifting,
            items: const [
              BottomNavigationBarItem(
                backgroundColor: Color.fromARGB(255, 177, 75, 131),
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                backgroundColor: Color.fromARGB(255, 177, 75, 131),
                icon: Icon(Icons.shopping_cart),
                label: 'My Orders',
              ),
              BottomNavigationBarItem(
                backgroundColor: Color.fromARGB(255, 177, 75, 131),
                icon: Icon(Icons.favorite),
                label: "My Wishlist",
              ),
            ]));
  }
}
