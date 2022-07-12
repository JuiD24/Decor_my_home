import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_my_home/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddProduct extends StatelessWidget {
  AddProduct({Key? key, required this.dID, this.categoryID}) : super(key: key);
  final String? dID;
  final String? categoryID;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _pricecontroller = TextEditingController();
  final TextEditingController _quantitycontroller = TextEditingController();
  File? _image;
  String _productDesc = '';
  late int _productPrice;
  late int _productQuantity;
  bool _initialized = false;
  FirebaseApp? app;

  Future<void> initializeDefault() async {
    app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    _initialized = true;
    if (kDebugMode) {
      print('Initialized default app $app');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    // super.initState();
    initializeDefault();
  }

  void _getImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      _image = File(pickedImage.path);
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }

  Future<String> _uploadFile(filename) async {
    if (!_initialized) {
      await initializeDefault();
    }
    final Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
    final SettableMetadata metadata =
        SettableMetadata(contentType: 'image/jpeg', contentLanguage: 'en');
    final UploadTask uploadTask = ref.putFile(_image!, metadata);
    final downloadURL = await (await uploadTask).ref.getDownloadURL();
    if (kDebugMode) {
      print(downloadURL.toString());
    }
    return downloadURL.toString();
  }

  Future<void> _addItem(String downloadURL, String id) async {
    if (!_initialized) {
      await initializeDefault();
    }
    await FirebaseFirestore.instance
        .collection('product')
        .doc(id)
        .set(<String, dynamic>{
      'downloadURL': downloadURL,
      'id': id,
      'department_id': dID,
      'category_id': categoryID,
      'desc': _productDesc,
      'price': _productPrice,
      'Quantity': _productQuantity
    });
  }

  void _upload(BuildContext context) async {
    if (!_initialized) {
      await initializeDefault();
    }
    if (_image != null) {
      var uuid = Uuid();
      final String uid = uuid.v4();
      if (kDebugMode) {
        print(uid);
      }
      _productDesc = _controller.text;
      _productPrice = int.parse(_pricecontroller.text);
      _productQuantity = int.parse(_quantitycontroller.text);
      final String downloadURL = await _uploadFile(_productDesc);
      await _addItem(downloadURL, uid);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: const Color.fromARGB(255, 177, 75, 131),
      ),
      body: SingleChildScrollView(
          child: ConstrainedBox(
              constraints: const BoxConstraints(),
              child: Card(
                  child: Form(
                      key: _formKey,
                      child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          /// username
                          TextFormField(
                            controller: _controller,
                            decoration: const InputDecoration(
                                labelText: 'Product Desc'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              }
                              // Return null if the entered username is valid
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _pricecontroller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Product Price'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              }
                              // Return null if the entered username is valid
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _quantitycontroller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Product Quantity'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              }
                              // Return null if the entered username is valid
                              return null;
                            },
                          ),
                          ElevatedButton(
                            onPressed: _getImage,
                            child: const Icon(Icons.add_a_photo),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _upload(context);
                              },
                              child: const Text("Add Product",
                                  style: TextStyle(fontSize: 20))),
                        ],
                      ))))),
    );
  }
}
