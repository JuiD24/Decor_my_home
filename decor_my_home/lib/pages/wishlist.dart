import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_my_home/components/drawer.dart';
import 'package:decor_my_home/firebase_options.dart';
import 'package:decor_my_home/pages/wishlistProductProvider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({Key? key}) : super(key: key);

  @override
  State<Wishlist> createState() => _WishlistDetailsState();
}

class _WishlistDetailsState extends State<Wishlist> {
  late String? userID;
  bool _initialized = false;

  void getDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print(preferences.getString("id"));
    userID = preferences.getString("id");
  }

  @override
  void initState() {
    // TODO: implement initState
    getDetails();
  }

  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
    if (kDebugMode) {
      print('Initialized default app $app');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error);
            }
            return const Text("Something Went Wrong");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Your Wishlist'),
                backgroundColor: const Color.fromARGB(255, 177, 75, 131),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  )
                ],
              ),
              drawer: const DrawerDetails(),
              body: Column(
                children: [getBody()],
              ),

              // This trailing comma makes auto-formatting nicer for build methods.
            );
          }
          return const CircularProgressIndicator();
        }));
  }

  void _removeProduct(String favDocID) async {
    if (!_initialized) {
      await initializeDefault();
    }

    await FirebaseFirestore.instance
        .collection("favorite")
        .doc(favDocID)
        .delete();

    setState(() {});
  }

  Widget getBody() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("favorite")
            .where("userID", isEqualTo: userID)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Center(
                child: Text("Nothing to display. Keep SHoppping !!"));
          }
          return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.all(10),
                    child: Card(
                      child: Row(
                        children: [
                          WishlistProductProvider(
                            prod_id: snapshot.data!.docs[index]['prodID'],
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          IconButton(
                              onPressed: (() => _removeProduct(
                                  snapshot.data!.docs[index]['id'])),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                        ],
                      ),
                    ));
              });
        });
  }
}
