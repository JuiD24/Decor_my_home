import 'package:decor_my_home/pages/addDepartment.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_my_home/pages/category.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:decor_my_home/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const Department());
}

class Department extends StatelessWidget {
  const Department({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        backgroundColor: const Color.fromARGB(255, 177, 75, 131),
      ),
      home: const DepartmentPage(title: 'Shop by Department'),
    );
  }
}

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<DepartmentPage> createState() => _DepartmentState();
}

class _DepartmentState extends State<DepartmentPage> {
  // int _selectedScreenIndex = 0;
  late bool isAdmin;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetails();
  }

  void getDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    isAdmin = preferences.getBool("isAdmin")!;
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
            return Text("Something Went Wrong");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              // appBar: AppBar(
              //   // Here we take the value from the MyHomePage object that was created by
              //   // the App.build method, and use it to set our appbar title.
              //   title: Text(widget.title),
              //   backgroundColor: const Color.fromARGB(255, 177, 75, 131),
              // ),
              body: Column(
                children: [getBody()],
              ),
              floatingActionButton: isAdmin == true
                  ? FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => const AddDepartment(
                                    title: "Get a photo"))));
                      },
                      tooltip: 'Add a photo',
                      child: const Icon(Icons.add),
                    )
                  : Container(),
              // This trailing comma makes auto-formatting nicer for build methods.
            );
          }
          return CircularProgressIndicator();
        }));
  }

  // void _selectPage(int index) {}

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
        stream:
            FirebaseFirestore.instance.collection("departments").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) return const Text("Loading Departments");
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
                                        builder: ((context) => ProductCategory(
                                              departmentID: snapshot
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
