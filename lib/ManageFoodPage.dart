import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:unieat/services/database_service.dart';

class ManageFoodPage extends StatefulWidget {
  const ManageFoodPage({super.key});

  @override
  _ManageFoodPageState createState() => _ManageFoodPageState();
}

class _ManageFoodPageState extends State<ManageFoodPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _selectedImage;
  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await DatabaseHelper.instance.getFoodItems();
    setState(() => foodItems = items);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _addFoodItem() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;

    if (name.isNotEmpty && price > 0 && _selectedImage != null) {
      await DatabaseHelper.instance.addFoodItem(name, price, _selectedImage!.path);
      _nameController.clear();
      _priceController.clear();
      setState(() => _selectedImage = null);
      _loadFoodItems();
      Navigator.pop(context);
    }
  }

  Future<void> _deleteFoodItem(int id) async {
    await DatabaseHelper.instance.deleteFoodItem(id);
    _loadFoodItems();
  }

  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.yellow.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Add Food Item", style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Food Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 100, width: 100, fit: BoxFit.cover)
                  : const Text("No image selected", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: Colors.amber),
                label: const Text("Select Image", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: _addFoodItem,
              child: const Text("Add", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.yellow.shade100,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.amber),
      ),
      child: Scaffold(

        floatingActionButton: FloatingActionButton(
          onPressed: _showAddFoodDialog,
          child: const Icon(Icons.add, color: Colors.black),
        ),
    body: Padding(
    padding: const EdgeInsets.only(top: 16),  // Added top padding
    child: ListView.builder(
          itemCount: foodItems.length,
          itemBuilder: (context, index) {
            final item = foodItems[index];
            return Card(
              color: Colors.yellow.shade50,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                leading: item['image'] != null && File(item['image']).existsSync()
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(item['image']), width: 50, height: 50, fit: BoxFit.cover),
                )
                    : const Icon(Icons.fastfood, size: 50, color: Colors.amber),
                title: Text(
                  item['name'],
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                subtitle: Text(
                  '\$${item['price']}',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.green),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteFoodItem(item['id']),
                ),
              ),
            );
          },
        ),
      ),
    ));
  }
}
