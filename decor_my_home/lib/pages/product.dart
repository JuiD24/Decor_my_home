import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_my_home/pages/addProduct.dart';
import 'package:decor_my_home/pages/productDetails.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:decor_my_home/firebase_options.dart';

class Product extends StatefulWidget {
  const Product(
      {Key? key,
      required this.departmentID,
      required this.categoryID,
      required this.isAdmin})
      : super(key: key);
  final String? departmentID;
  final String? categoryID;
  final bool isAdmin;

  @override
  State<Product> createState() => ProductDetailsState();
}

class ProductDetailsState extends State<Product> {
  RangeValues _currentRangeValues = const RangeValues(0, 1000);

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
            return Text("Something Went Wrong");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Products'),
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
              body: Column(
                children: [getBody()],
              ),
              floatingActionButton: widget.isAdmin == true
                  ? FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => AddProduct(
                                    dID: widget.departmentID,
                                    categoryID: widget.categoryID))));
                      },
                      tooltip: 'Add a product',
                      child: const Icon(Icons.add),
                    )
                  : FloatingActionButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 100,
                                child: Center(
                                  child: StatefulBuilder(
                                    builder: (context, State) {
                                      return RangeSlider(
                                        values: _currentRangeValues,
                                        max: 1000,
                                        divisions: 50,
                                        labels: RangeLabels(
                                          _currentRangeValues.start
                                              .round()
                                              .toString(),
                                          _currentRangeValues.end
                                              .round()
                                              .toString(),
                                        ),
                                        onChanged: (RangeValues values) {
                                          _currentRangeValues = values;
                                          State(() {});
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            });
                      },
                      tooltip: 'Filter product',
                      child: const Icon(Icons.filter),
                    ),
              // This trailing comma makes auto-formatting nicer for build methods.
            );
          }
          return CircularProgressIndicator();
        }));
  }

  Widget photoWidget(AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    try {
      return Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.pink[50], borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Image.network(
                snapshot.data!.docs[index]['downloadURL'],
                height: 120,
                width: 140,
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 5),
              alignment: Alignment.bottomCenter,
              child: Text(
                  'Price: ${snapshot.data!.docs[index]['price'].toString()}'),
            ),
            // Container()  for prod desc
          ],
        ),
      );
    } catch (e) {
      return Card(
        color: Colors.amber,
        child: Center(child: Text("Error: $e")),
      );
    }
  }

  Widget getBody() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("product")
            .where("department_id", isEqualTo: widget.departmentID)
            .where("category_id", isEqualTo: widget.categoryID)
            .where("price", isLessThanOrEqualTo: _currentRangeValues.end)
            .where("price", isGreaterThanOrEqualTo: _currentRangeValues.start)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) return const Text("Loading Products");
          return Expanded(
              child: Scrollbar(
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              if (snapshot.data!.docs[index]['id'] != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => ProductDetails(
                                            prodURL: snapshot.data!.docs[index]
                                                ['downloadURL'],
                                            prodPrice: snapshot
                                                .data!.docs[index]['price'],
                                            prodDesc: snapshot.data!.docs[index]
                                                ['desc'],
                                            prodID: snapshot.data!.docs[index]
                                                ['id'],
                                            prodQuantity: snapshot.data!
                                                .docs[index]['Quantity']))));
                              }
                            },
                            child: photoWidget(snapshot, index));
                      })));
        });
  }
}
