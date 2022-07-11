import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_my_home/pages/addProduct.dart';
import 'package:decor_my_home/pages/productDetails.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:decor_my_home/firebase_options.dart';

class Product extends StatelessWidget {
  const Product(
      {Key? key, required this.departmentID, required this.categoryID})
      : super(key: key);
  final String? departmentID;
  final String? categoryID;

  //  @override
  // void initState() {
  //   // TODO: implement initState

  // }

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
              // appBar: AppBar(
              //   // Here we take the value from the MyHomePage object that was created by
              //   // the App.build method, and use it to set our appbar title.
              //   title: const Text('Products'),
              //   backgroundColor: const Color.fromARGB(255, 177, 75, 131),
              // ),
              body: Column(
                children: [getBody()],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => AddProduct(
                              dID: departmentID, categoryID: categoryID))));
                },
                tooltip: 'Add a product',
                child: const Icon(Icons.add),
              ),
              // This trailing comma makes auto-formatting nicer for build methods.
            );
          }
          return CircularProgressIndicator();
        }));
  }

  Widget photoWidget(AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    try {
      return Card(
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(snapshot.data!.docs[index]['downloadURL']),
              // fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Price : " + snapshot.data!.docs[index]['price'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
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
            .where("department_id", isEqualTo: departmentID)
            .where("category_id", isEqualTo: categoryID)
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
