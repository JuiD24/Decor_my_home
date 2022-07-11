import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_my_home/pages/addCategory.dart';
import 'package:decor_my_home/pages/product.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:decor_my_home/firebase_options.dart';

class ProductCategory extends StatelessWidget {
  const ProductCategory(
      {Key? key, required this.departmentID, required this.isAdmin})
      : super(key: key);
  final String? departmentID;
  final bool isAdmin;

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
              body: Column(
                children: [getBody()],
              ),
              floatingActionButton: isAdmin == true
                  ? FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    AddCategory(dID: departmentID))));
                      },
                      tooltip: 'Add a category',
                      child: const Icon(Icons.add),
                    )
                  : Container(),
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
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                snapshot.data!.docs[index]['name'],
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
            .collection("category")
            .where("department_id", isEqualTo: departmentID)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) return const Text("Loading category");
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
                                        builder: ((context) => Product(
                                              departmentID: snapshot.data!
                                                  .docs[index]['department_id'],
                                              categoryID: snapshot
                                                  .data!.docs[index]['id'],
                                              isAdmin: isAdmin,
                                            ))));
                              }
                            },
                            child: photoWidget(snapshot, index));
                      })));
        });
  }
}
