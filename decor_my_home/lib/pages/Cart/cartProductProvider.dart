import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProductProvider extends StatefulWidget {
  String prod_id;
  int orderQ;
  String orderid;

  ValueNotifier<int> count;

  CartProductProvider(
      {Key? key,
      required this.prod_id,
      required this.orderQ,
      required this.orderid,
      required this.count})
      : super(key: key);
  @override
  State<CartProductProvider> createState() => CartProductProviderState();
}

class CartProductProviderState extends State<CartProductProvider> {
  late String? userID;
  late int currentQ;
  late int prodPrice;

  void getDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print(preferences.getString("id"));
    userID = preferences.getString("id");

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection("product")
        .where("id", isEqualTo: widget.prod_id)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    setState(() {
      prodPrice = documents[0]['price'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    currentQ = widget.orderQ;

    getDetails();
  }

  void _subQuantity() {
    FirebaseFirestore.instance.collection("cart").doc(widget.orderid).update({
      "orderQuantity": currentQ - 1,
      "price": (currentQ - 1) * prodPrice,
    });
    widget.count.value = widget.count.value - prodPrice;
    setState(() {
      currentQ = currentQ - 1;
    });
  }

  void _addQuantity() {
    FirebaseFirestore.instance.collection("cart").doc(widget.orderid).update({
      "orderQuantity": currentQ + 1,
      "price": (currentQ + 1) * prodPrice,
    });
    widget.count.value = widget.count.value + prodPrice;
    setState(() {
      currentQ = currentQ + 1;
    });
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
            return const Text("Loading Products");
          } else {
            print(snapshot.data!.docs[0]);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.network(snapshot.data!.docs[0]["downloadURL"],
                    width: 100, height: 80, fit: BoxFit.cover),
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
                          ),
                        ])),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        onPressed: currentQ > 1 ? _subQuantity : null,
                        icon: const Icon(Icons.remove_circle)),
                    Text(
                      currentQ.toString(),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    IconButton(
                        onPressed: currentQ < snapshot.data!.docs[0]["Quantity"]
                            ? _addQuantity
                            : null,
                        icon: const Icon(Icons.add_circle)),
                  ],
                )
              ],
            );
          }
        });
  }
}
