import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/menu_service.dart';
import '../models/menu_model.dart';

class EditMenuScreen extends StatefulWidget {
  final String menuId;

  EditMenuScreen({required this.menuId});

  @override
  _EditMenuScreenState createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  late MenuModel _menu;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final menuService = Provider.of<MenuService>(context, listen: false);
    _menu = await menuService.getMenuById(widget.menuId);
    _nameController.text = _menu.name;
    _priceController.text = _menu.price.toString();
    setState(() {
      _isLoading = false;
    });
  }

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
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('menu_images/$fileName.jpg');
      UploadTask uploadTask = firebaseStorageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Menu Item')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Menu Item')),
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
                ? Image.network(_menu.imageUrl, height: 200)
                : Image.file(_image!, height: 200),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Change Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String imageUrl = _menu.imageUrl;
                  if (_image != null) {
                    String? newImageUrl = await uploadImage(_image!);
                    if (newImageUrl != null) {
                      imageUrl = newImageUrl;
                    }
                  }
                  MenuModel updatedMenu = MenuModel(
                    id: _menu.id,
                    name: _nameController.text,
                    price: double.parse(_priceController.text),
                    imageUrl: imageUrl,
                  );
                  try {
                    await Provider.of<MenuService>(context, listen: false)
                        .editMenu(updatedMenu);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Menu item updated successfully')));
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Failed to update menu item. Please try again.')));
                  }
                }
              },
              child: Text('Update Menu Item'),
            ),
          ],
        ),
      ),
    );
  }
}
