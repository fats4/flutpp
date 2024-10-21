import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/menu_service.dart';
import '../models/menu_model.dart';

class AddMenuScreen extends StatefulWidget {
  final MenuModel? menuItem;

  AddMenuScreen({this.menuItem});

  @override
  _AddMenuScreenState createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  String? _imageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menuItem?.name ?? '');
    _priceController =
        TextEditingController(text: widget.menuItem?.price.toString() ?? '');
    _imageUrl = widget.menuItem?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl = null;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _imageUrl;

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef =
        storageRef.child('menu_images/${DateTime.now().toIso8601String()}.jpg');

    try {
      await imageRef.putFile(_imageFile!);
      return await imageRef.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final menuService = Provider.of<MenuService>(context, listen: false);

      String? imageUrl = await _uploadImage();
      if (imageUrl == null && _imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image. Please try again.')),
        );
        return;
      }

      final menuItem = MenuModel(
        id: widget.menuItem?.id ?? '',
        name: _nameController.text,
        price: double.parse(_priceController.text),
        imageUrl: imageUrl ?? _imageUrl!,
      );

      if (widget.menuItem == null) {
        await menuService.addMenu(menuItem);
      } else {
        await menuService.updateMenu(menuItem.id, menuItem);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.menuItem == null ? 'Add Menu Item' : 'Edit Menu Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
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
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : _imageUrl != null
                    ? Image.network(_imageUrl!, height: 200)
                    : Text('No image selected'),
            ElevatedButton(
              child: Text('Select Image'),
              onPressed: _pickImage,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(widget.menuItem == null
                  ? 'Add Menu Item'
                  : 'Update Menu Item'),
              onPressed: _saveForm,
            ),
          ],
        ),
      ),
    );
  }
}
