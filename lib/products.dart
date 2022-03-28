import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'app_provider.dart';

class ProducSaisie extends StatefulWidget {
  const ProducSaisie({Key key}) : super(key: key);

  @override
  _ProducSaisieState createState() => _ProducSaisieState();
}

class _ProducSaisieState extends State<ProducSaisie> {
  var ProductName = TextEditingController();
  //var imageURL = TextEditingController();
  var weight = TextEditingController();
  var brandName = TextEditingController();
  var type = TextEditingController();
  final nameproductFocusNode = FocusNode();
  String imageUrl;
  String selectedType = 'مواد غذائية';
  List TypesProductList = [
    'مواد غذائية',
    'حبوب',
    'زيوت',
    'معدات القهوة والشاي',
    'مشروبات غازية',
    'مشروبات عادية',
    'مياه معدنية',
    'معجنات',
    'حليب ومشتقاته',
    'معلبات',
    'مواد التنظيف',
    'حلويات',
    'مكونات الحلويات',
    'مكونات أخرى',
  ];

  @override
  Widget build(BuildContext context) {
    //final _appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Write down your product'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15.0,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,
                  ))
            ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Form(
            child: ListView(
              children: [
                (imageUrl != null)
                    ? Image.network(
                        imageUrl,
                        height: 150.0,
                      )
                    : Placeholder(fallbackHeight: 150.0, fallbackWidth: double.infinity),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  child: Text('Upload Image'),
                  color: Colors.lightBlue,
                  onPressed: () => uploadImage(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: brandName,
                        decoration: InputDecoration(labelText: 'ماركة المنتج'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: ProductName,
                        decoration: InputDecoration(labelText: 'اسم المنتج'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: weight,
                        decoration: InputDecoration(labelText: 'الوزن المقدر'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        (imageUrl != null) ? imageUrl : 'Empty',
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('نوع المنتج'),
                            DropdownButton(
                              isExpanded: true,
                              hint: Text('نوع المنتج'),
                              value: selectedType,
                              items: TypesProductList.map((item) {
                                return DropdownMenuItem(
                                  child: Text(item),
                                  value: item,
                                );
                              }).toList(),
                              onChanged: (newVal) {
                                setState(() {
                                  selectedType = newVal;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      RaisedButton(
                        color: Colors.teal,
                        textColor: Colors.white,
                        onPressed: () {
                          SaveAddress();
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => Perm()));
                        },
                        child: Text('حفظ'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  uploadImage() async {
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile image;

    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      print('permission is granted');
      //Select Image
      image = await _picker.getImage(source: ImageSource.gallery);
      var file = File(image.path);

      if (image != null) {
        final Reference postImageRef = FirebaseStorage.instance.ref().child("products");
        var timeKey = DateTime.now();
        UploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(file);
        print('aaa');
        print(uploadTask);
        imageUrl = await (await uploadTask).ref.getDownloadURL();
        var url = imageUrl.toString();
        print('my URL IMAGE IS > ' + imageUrl);
        print('my URL IMAGE IS > ' + url.toString());
        // Guardar el post en la bbdd

        setState(() {
          imageUrl = url;
          print('my URL IMAGE IS > ' + imageUrl);
        });
      } else {
        print('No Path Received');
      }
    } else {
      print('permission is not granted');
    }
  }

  Future<void> SaveAddress() async {
    //now below I am getting an instance of firebaseiestore then getting the user collection
    //now I am creating the document if not already exist and setting the data.
    if (imageUrl==null) {
      shownSnackBar('upload image please', context);
      return;
    }if (brandName.text.trim() == "") {
      shownSnackBar('brandName empty', context);
      return;
    }
    if (ProductName.text.trim() == "") {
      shownSnackBar('ProductName empty', context);
      return;
    }
    if (weight.text.trim() == "") {
      shownSnackBar('weight empty', context);
      return;
    }
    FirebaseFirestore.instance.collection("products").add({
      "productName": ProductName.text.toString(),
      "productBrand": brandName.text.toString(),
      "imageUrl": imageUrl.toString(),
      "weight": weight.text.toString(),
      "type": selectedType.toString(),
    });
    setState(() {
      shownSnackBar('Saved Succefully', context);
      ProductName.clear();
      brandName.clear();
      imageUrl = null;
      weight.clear();
      selectedType =  'مواد غذائية';
    });
    return;
  }

  void shownSnackBar(title, context) {
    final SnackBar snackBar = SnackBar(
      backgroundColor: title.toString() == "Saved Succefully" ? Colors.lightGreen : Colors.red,
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15, color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
