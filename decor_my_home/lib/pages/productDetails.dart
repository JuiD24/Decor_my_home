import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_my_home/pages/addProduct.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:decor_my_home/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProductDetails extends StatefulWidget {
  final String? prodURL;
  final int? prodPrice;
  final String? prodDesc;
  final String? prodID;
  final int? prodQuantity;

  ProductDetails(
      {Key? key,
      required this.prodURL,
      required this.prodPrice,
      required this.prodDesc,
      required this.prodID,
      required this.prodQuantity})
      : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;
  bool isFavorite = false;
  late String favDocID = "";

  int userQ = 1;
  late int pageQuantity = widget.prodQuantity!;

  @override
  void initState() {
    // TODO: implement initState
    userQ = 1;
    pageQuantity = widget.prodQuantity!;
    getDetails();
  }

  void getDetails() async {
    if (!_initialized) {
      await initializeDefault();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection("favorite")
        .where("userID", isEqualTo: preferences.getString("id"))
        .where("prodID", isEqualTo: widget.prodID)
        .get();

    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      // print(documents[0]["id"]);
      setState(() {
        isFavorite = true;
        favDocID = documents[0]["id"];
      });
    }
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

  void addToCart() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // print("inside");
    String? userid = preferences.getString("id");
    if (!_initialized) {
      await initializeDefault();
    }
    var uuid = Uuid();
    final String uid = uuid.v4();

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection("cart")
        .where("userID", isEqualTo: preferences.getString("id"))
        .where("prodID", isEqualTo: widget.prodID)
        .where("orderStatus", isEqualTo: false)
        .get();

    final List<DocumentSnapshot> documents = result.docs;
    if (documents.length == 0) {
      // final QuerySnapshot result = await FirebaseFirestore.instance
      //     .collection("product")
      //     .where("prodID",isEqualTo: widget.prodID)
      //     .get();
      // final List<DocumentSnapshot> documents = result.docs;

      FirebaseFirestore.instance.collection("cart").doc(uid).set({
        "userID": preferences.getString("id"),
        "id": uid,
        "prodID": widget.prodID,
        "orderQuantity": userQ,
        "orderStatus": false,
        // "availableQ": pageQuantity,
        "price": userQ * widget.prodPrice!,
      });
    } else {
      FirebaseFirestore.instance
          .collection("cart")
          .doc(documents[0]["id"])
          .update({
        "orderQuantity": userQ,
        "price": userQ * widget.prodPrice!,
      });
    }
  }

  void _addQuantity() {
    setState(() {
      userQ += 1;
    });
  }

  void _subQuantity() {
    setState(() {
      userQ -= 1;
    });
  }

  void _addtoFavorite() async {
    if (!_initialized) {
      await initializeDefault();
    }

    var uuid = Uuid();
    final String uid = uuid.v4();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    FirebaseFirestore.instance.collection("favorite").doc(uid).set({
      "userID": preferences.getString("id"),
      "id": uid,
      "prodID": widget.prodID,
    });

    setState(() {
      isFavorite = true;
      favDocID = uid;
    });
  }

  void _removeFromFavorite() async {
    if (!_initialized) {
      await initializeDefault();
    }
    print(favDocID);
    await FirebaseFirestore.instance
        .collection("favorite")
        .doc(favDocID)
        .delete();

    setState(() {
      isFavorite = false;
    });
  }

  Future<void> _updateQuantity() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    /// username
                    TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          labelText: 'Update Product Quantity'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field is required';
                        }
                        // Return null if the entered username is valid
                        return null;
                      },
                    ),
                  ],
                )),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () async {
                if (!_initialized) {
                  await initializeDefault();
                }
                FirebaseFirestore.instance
                    .collection("product")
                    .doc(widget.prodID)
                    .update({"Quantity": int.parse(_controller.text)});

                setState(() {
                  pageQuantity = int.parse(_controller.text);
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("");
    return Card(
      child: Material(
        child: GridTile(
            header: Container(
              color: Colors.white70,
              child: ListTile(
                leading: Text(
                  widget.prodDesc!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Text(
                  "\$" + widget.prodPrice.toString(),
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  "Quantity Available: " + pageQuantity.toString(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: _updateQuantity,
                  child: const Text('Update Quantity'),
                ),
              ),
            ),
            footer: Container(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 40, 14, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed:
                            userQ < widget.prodQuantity! ? _addQuantity : null,
                        child: const Icon(Icons.add),
                      ),
                      Text(userQ.toString()),
                      ElevatedButton(
                        onPressed: userQ > 1 ? _subQuantity : null,
                        child: const Icon(Icons.remove),
                      ),
                      ElevatedButton(
                        onPressed: addToCart,
                        child: const Text('Add to Cart'),
                      ),
                      isFavorite == true
                          ? IconButton(
                              onPressed: _removeFromFavorite,
                              icon: const Icon(Icons.favorite))
                          : IconButton(
                              onPressed: _addtoFavorite,
                              icon: const Icon(Icons.favorite_border_outlined))
                    ],
                  )),
            ),
            child: Image.network(
              widget.prodURL!,
              // fit: BoxFit.cover,
            )),
      ),
    );
  }
}

  // int userQ = 1;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   userQ = 1;
  // }

  // void addToCart() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   print(preferences.getString("id"));
  // }

  // void _addQuantity() {
  //   userQ += 1;
  // }

  

