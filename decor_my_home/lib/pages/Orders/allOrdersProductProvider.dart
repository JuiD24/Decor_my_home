import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:decor_my_home/firebase_options.dart';

class AllOrdersProductProvider extends StatelessWidget {
  const AllOrdersProductProvider(
      {Key? key, required this.orderID, required this.userID})
      : super(key: key);
  final String? orderID;
  final String? userID;

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
            return Column(
              children: [getBody()],
            );
          }
          return const CircularProgressIndicator();
        }));
  }

  Widget getBody() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("cart")
            .where("userID", isEqualTo: userID)
            .where("orderID", isEqualTo: orderID)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) return const Text("Loading Products");
          return Container(
              width: 200,
              child: ListView.builder(
                  // physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Row(children: [
                      getProductBody(snapshot.data!.docs[index]['prodID']),
                      Text(' x${snapshot.data!.docs[index]['orderQuantity']}')
                    ]);
                  }));
        });
  }

  Widget getProductBody(String prodID) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('product')
            .where('id', isEqualTo: prodID)
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text("Loading Products");
          } else {
            return Text(snapshot.data!.docs[0]["desc"]);
          }
        });
  }
}
