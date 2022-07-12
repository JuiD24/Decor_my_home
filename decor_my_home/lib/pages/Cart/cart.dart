import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_my_home/components/drawer.dart';
import 'package:decor_my_home/firebase_options.dart';
import 'package:decor_my_home/pages/Cart/ThankYouPage.dart';
import 'package:decor_my_home/pages/Cart/cartProductProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartDetailsState();
}

class _CartDetailsState extends State<Cart> {
  late String? userID;
  int totalSum = 0;
  bool _initialized = false;
  late ValueNotifier<int> _count = ValueNotifier<int>(0);
  late final List<DocumentSnapshot> documents;

  void getDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print(preferences.getString("id"));

    userID = preferences.getString("id");
    updateTotalsum();
  }

  @override
  void initState() {
    super.initState();
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

  void updateTotalsum() async {
    int total = 0;
    print("hett");
    print(userID);
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection("cart")
        .where("userID", isEqualTo: userID)
        .where("orderStatus", isEqualTo: false)
        .get();

    documents = result.docs;
    print(documents.length);
    for (var i = 0; i < documents.length; i++) {
      total = documents[i]['price'] + total;
    }

    _count.value = total;
  }

  void createOrder() async {
    var uuid = Uuid();
    final String uid = uuid.v4();

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String currDate = formatter.format(now);

    for (var i = 0; i < documents.length; i++) {
      FirebaseFirestore.instance
          .collection("cart")
          .doc(documents[i]['id'])
          .update({"orderStatus": true, "orderID": uid});

      final QuerySnapshot prod = await FirebaseFirestore.instance
          .collection("product")
          .where("id", isEqualTo: documents[i]['prodID'])
          .get();

      List<DocumentSnapshot> prodDetails = prod.docs;

      FirebaseFirestore.instance
          .collection("product")
          .doc(documents[i]['prodID'])
          .update({
        "Quantity": prodDetails[0]['Quantity'] - documents[i]['orderQuantity']
      });
    }

    FirebaseFirestore.instance.collection("order").doc(uid).set(
        {"id": uid, "userID": userID, "total": _count.value, "date": currDate});

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: ((context) =>
                const ThankYouPage(title: "Thank you Page"))));
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
                  title: const Text('Your Cart'),
                  backgroundColor: const Color.fromARGB(255, 177, 75, 131),
                ),
                drawer: const DrawerDetails(),
                body: Column(
                  children: [
                    getBody(),
                  ],
                ),
                bottomNavigationBar: Container(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_count.value > 0) {
                            createOrder();
                          }
                        },
                        child: ValueListenableBuilder<int>(
                          builder:
                              (BuildContext context, int value, Widget? child) {
                            if (value == 0) {
                              return Text(
                                "Nothing to display. Keep shopping ",
                                style: Theme.of(context).textTheme.headline5,
                              );
                            } else {
                              return Text('Checkout : ' + '\$$value');
                            }
                          },
                          valueListenable: _count,
                        ),
                      )),
                ));
          }
          return const CircularProgressIndicator();
        }));
  }

  void _removeOrder(String cartID, int price) async {
    if (!_initialized) {
      await initializeDefault();
    }

    await FirebaseFirestore.instance.collection("cart").doc(cartID).delete();
    _count.value = _count.value - price;
    setState(() {});
  }

  Widget getBody() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("cart")
            .where("userID", isEqualTo: userID)
            .where("orderStatus", isEqualTo: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Center(
                child: Text("No orders to display. Keep SHoppping !!"));
          }
          return ListView.builder(
              // separatorBuilder: (context, index) =>
              //     Divider(color: Colors.black),
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Card(
                      child: Row(
                        children: [
                          CartProductProvider(
                              prod_id: snapshot.data!.docs[index]['prodID'],
                              orderQ: snapshot.data!.docs[index]
                                  ['orderQuantity'],
                              orderid: snapshot.data!.docs[index]['id'],
                              count: _count),
                          IconButton(
                              onPressed: (() => _removeOrder(
                                  snapshot.data!.docs[index]['id'],
                                  snapshot.data!.docs[index]['price'])),
                              icon: const Icon(
                                CupertinoIcons.delete,
                                color: Colors.red,
                              ))
                        ],
                      ),
                    ));
              });
        });
  }
}
