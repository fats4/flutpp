import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/menu_service.dart';
import '../models/menu_model.dart';

class AddMenuScreen extends StatefulWidget {
  @override
  _AddMenuScreenState createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String?> uploadImage(File image) async {
    try {
      print("Starting image upload...");
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      print("Generated file name: $fileName");
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('menu_images/$fileName.jpg');
      print("Created Firebase Storage reference");
      UploadTask uploadTask = firebaseStorageRef.putFile(image);
      print("Started upload task");

      TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => print("Upload completed"));
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print("Image uploaded successfully. Download URL: $downloadUrl");
      return downloadUrl;
    } on FirebaseException catch (e) {
      print("Firebase Exception: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Unexpected error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Menu Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Menu Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a menu name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!, height: 200),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Pick an image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && _image != null) {
                  String? imageUrl = await uploadImage(_image!);
                  if (imageUrl != null) {
                    MenuModel newMenu = MenuModel(
                      id: '',
                      name: _nameController.text,
                      price: double.parse(_priceController.text),
                      imageUrl: imageUrl,
                    );
                    try {
                      await Provider.of<MenuService>(context, listen: false)
                          .addMenu(newMenu);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Menu item added successfully')));
                      _nameController.clear();
                      _priceController.clear();
                      setState(() {
                        _image = null;
                      });
                    } catch (e) {
                      print("Error adding menu item: $e");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Failed to add menu item. Please try again.')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Failed to upload image. Please try again.')));
                  }
                }
              },
              child: Text('Add Menu Item'),
            ),
          ],
        ),
      ),
    );
  }
}
