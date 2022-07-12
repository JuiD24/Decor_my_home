import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:decor_my_home/pages/Orders/allOrdersProductProvider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:decor_my_home/firebase_options.dart';

class AllOrders extends StatelessWidget {
  const AllOrders({Key? key, required this.userID}) : super(key: key);
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
            return Scaffold(
              appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: const Text('All Orders'),
                backgroundColor: const Color.fromARGB(255, 177, 75, 131),
              ),
              body: Column(
                children: [getBody()],
              ),

              // This trailing comma makes auto-formatting nicer for build methods.
            );
          }
          return const CircularProgressIndicator();
        }));
  }

  Widget getBody() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("order")
            .where("userID", isEqualTo: userID)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Center(
                child: Text("You have 0 orders. Keep SHoppping !!"));
          }
          return Expanded(
              child: Scrollbar(
                  child: ListView.builder(
                      // separatorBuilder: (context, index) =>
                      //     Divider(color: Colors.black),
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Card(
                            elevation: 5,
                            child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Order Date: ${snapshot.data!.docs[index]['date'].toString()}'),
                                    const Divider(
                                      thickness: 2,
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              AllOrdersProductProvider(
                                                userID: snapshot.data!
                                                    .docs[index]['userID'],
                                                orderID: snapshot
                                                    .data!.docs[index]['id'],
                                              )
                                            ],
                                          ),
                                          const VerticalDivider(
                                            thickness: 1,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text("Order Amount :"),
                                              Text(
                                                  '\$${snapshot.data!.docs[index]['total']}')
                                            ],
                                          )
                                        ])
                                  ],
                                )),
                          ),
                        );
                      })));
        });
  }
}
