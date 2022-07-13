import 'package:decor_my_home/pages/Orders/allOrders.dart';
import 'package:decor_my_home/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerDetails extends StatefulWidget {
  const DrawerDetails({
    Key? key,
  }) : super(key: key);

  @override
  State<DrawerDetails> createState() => _DrawerDetailsState();
}

class _DrawerDetailsState extends State<DrawerDetails> {
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  late SharedPreferences preferences;
  String? username;
  String? userURL;
  String? userID;

  @override
  void initState() {
    username = "Flutter User";

    getDetails();
  }

  void getDetails() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString("username");
      userURL = preferences.getString("photoUrl");
      userID = preferences.getString("id");
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();

    await preferences.setString("id", "");
    await preferences.setString("username", "");
    await preferences.setString("photoUrl", "");
    await preferences.setBool("isAdmin", false);

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: Text(username ?? ""),
              accountName: const Text(""),
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 177, 75, 131)),
              currentAccountPicture: CircleAvatar(
                radius: 50.0,
                backgroundColor: const Color(0xFF778899),
                backgroundImage: NetworkImage(userURL ?? ""),
              ),
            ),
            ListTile(
              title: const Text('All orders'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => AllOrders(userID: userID))));
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}
