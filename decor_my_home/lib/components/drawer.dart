import 'package:decor_my_home/pages/Orders/allOrders.dart';
import 'package:decor_my_home/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
  String? username;
  String? userURL;
  String? userID;

  @override
  void initState() {
    username = "Flutter User";

    getDetails();
  }

  void getDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString("username");
      userURL = preferences.getString("photoUrl");
      userID = preferences.getString("id");
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


// class DrawerComp extends StatelessWidget {
//   const DrawerComp(
//       {Key? key, required this.username, required this.userURL, this.userID})
//       : super(key: key);
//   final String? username;
//   final String? userURL;
//   final String? userID;
//   //  @override
//   // void initState() {
//   //   // TODO: implement initState

//   // }

//   @override
//   Widget build(BuildContext context) {
//     print(userID);
//     return Drawer(
//       child: Center(
//         child: Column(
//           children: <Widget>[
//             UserAccountsDrawerHeader(
//               accountEmail: Text(username!),
//               accountName: Text(username!),
//               decoration: const BoxDecoration(color: Colors.white),
//               currentAccountPicture: CircleAvatar(
//                 radius: 50.0,
//                 backgroundColor: const Color(0xFF778899),
//                 backgroundImage: NetworkImage(userURL!),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
