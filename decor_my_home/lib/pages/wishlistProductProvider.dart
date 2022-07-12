import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_my_home/firebase_options.dart';
import 'package:decor_my_home/pages/productDetails.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProductProvider extends StatefulWidget {
  String prod_id;

  WishlistProductProvider({
    Key? key,
    required this.prod_id,
  }) : super(key: key);
  @override
  State<WishlistProductProvider> createState() =>
      WishlistProductProviderState();
}

class WishlistProductProviderState extends State<WishlistProductProvider> {
  late String? userID;

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('product')
            .where('id', isEqualTo: widget.prod_id)
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text("Loading Wishlist");
          } else {
            // print(snapshot.data!.docs[0]);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => ProductDetails(
                                  prodURL: snapshot.data!.docs[0]
                                      ['downloadURL'],
                                  prodPrice: snapshot.data!.docs[0]['price'],
                                  prodDesc: snapshot.data!.docs[0]['desc'],
                                  prodID: snapshot.data!.docs[0]['id'],
                                  prodQuantity: snapshot.data!.docs[0]
                                      ['Quantity']))));
                    },
                    child: Image.network(snapshot.data!.docs[0]["downloadURL"],
                        width: 100, height: 80, fit: BoxFit.cover)),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                    width: 120,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data!.docs[0]["desc"],
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          Text(
                            '\$${snapshot.data!.docs[0]["price"]}',
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ])),
                const SizedBox(
                  width: 10,
                ),
              ],
            );
          }
        });
  }
}
