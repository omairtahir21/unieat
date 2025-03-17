import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unieat/services/database_service.dart';
import 'OrderStatusPage.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {

  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> userOrders = [];

  int _selectedIndex = 0;

  final TextEditingController _addressController = TextEditingController();
  List<Map<String, dynamic>> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteItems();
  }

  Future<void> _loadFavoriteItems() async {
    int userId = 1; // Replace with actual logged-in user ID
    final items = await DatabaseHelper.instance.getFavoriteItems(userId);
    setState(() => favoriteItems = items);
  }

  Future<void> _toggleFavorite(Map<String, dynamic> item) async {
    int userId = 1; // Replace with actual user ID
    bool isFav = favoriteItems.any((fav) => fav['id'] == item['id']);

    if (isFav) {
      await DatabaseHelper.instance.removeFromFavorites(userId, item['id']);
    } else {
      await DatabaseHelper.instance.addToFavorites(userId, item['id']);
    }

    _loadFavoriteItems();
  }



  Widget _buildFoodGrid() {
    return foodItems.isEmpty
        ? const Center(child: Text("No food items available"))
        : GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8, // Adjust for better proportions
      ),
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        final item = foodItems[index];
        bool isFavorite = favoriteItems.any((fav) => fav['id'] == item['id']);

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.shade100, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: item['image'] != null && File(item['image']).existsSync()
                      ? Image.file(File(item['image']),
                      height: 100, width: double.infinity, fit: BoxFit.cover)
                      : Image.asset('assets/placeholder.png', height: 100, width: double.infinity, fit: BoxFit.cover),
                ),

                // Food Name & Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item['description'] ?? "Delicious Food",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // Rating & Favorite Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 18),
                          Text(
                            item['rating']?.toString() ?? "4.8",
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(item),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesPage() {
    return favoriteItems.isEmpty
        ? const Center(child: Text("No favorites added yet", style: TextStyle(fontSize: 18)))
        : foodItems.isEmpty
        ? const Center(child: Text("No food items available"))
        : GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        final item = foodItems[index];
        bool isFavorite = favoriteItems.any((fav) => fav['id'] == item['id']);
        return Card(
          color: Colors.amber.shade100,
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Expanded(
                child: item['image'] != null && File(item['image']).existsSync()
                    ? Image.file(File(item['image']), fit: BoxFit.cover)
                    : const Icon(Icons.fastfood, size: 50, color: Colors.brown),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(item['name'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("₹${item['price']}", style: GoogleFonts.poppins(fontSize: 16, color: Colors.green)),
                    ElevatedButton(
                      onPressed: () => _addToCart(item),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
                      child: const Text("+ Add to Cart", style: TextStyle(color: Colors.black)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _toggleFavorite(item),
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
      },
    );

  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      cartItems.add(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item['name']} added to cart!"),
        backgroundColor: Colors.amber.shade700,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> placeOrder(int userId, int foodItemId, int quantity,
      double price, String address) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'orders',
      {
        'userId': userId,
        'foodItemId': foodItemId,
        'quantity': quantity,
        'totalPrice': price,
        'address': address, // Manually entered address
        'status': 'Processing',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.amber.shade50,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter Your Address",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  autofillHints: null, // Disables autofill
                  decoration: InputDecoration(
                    hintText: "Enter delivery address",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_addressController.text.isNotEmpty) {
                      Navigator.pop(context);

                      int userId = 1;  // Replace with actual user ID
                      String address = _addressController.text; // User input address

                      for (var item in cartItems) {
                        int foodItemId = item['id'];
                        String foodName = item['name'];  // Get original name from cart
                        double price = item['price'];  // Get original price from cart
                        int quantity = 1;

                        await DatabaseHelper.instance.placeOrder(
                          userId,
                          foodItemId,
                          quantity,
                          price,
                          address, // Address from TextField
                          "Cash",
                          foodName,
                        );


                      }

                      setState(() => cartItems.clear()); // Clear cart after order
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text("Confirm Address", style: TextStyle(color: Colors.black)),
                ),


              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildCartPage() {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Your Cart",
              style: GoogleFonts.poppins(fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          const Divider(),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                child: Text("Cart is empty", style: TextStyle(fontSize: 18)))
                : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item['name'], style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text("₹${item['price']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() => cartItems.removeAt(index));
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: cartItems.isEmpty ? null : _showAddressBottomSheet,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700),
              child: const Text(
                  "Place Order", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get _pages => [
    _buildFoodGrid(),
    _buildCartPage(),
    const Center(child: Text("Menu Page")),
    _buildFavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amber.shade50,
        appBar: AppBar(
          title: const Text("UniEats 🍽️"),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.receipt_long),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderStatusPage()),
                );
              },
            ),
          ],
        ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        color: Colors.yellow.shade100,
        buttonBackgroundColor: Colors.yellow.shade100,
        height: 60,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
          Icon(Icons.add, size: 30, color: Colors.white),
          Icon(Icons.article, size: 30, color: Colors.white),
          Icon(Icons.favorite, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow.shade100,
        onPressed: () {},
        child: Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData(
//         primarySwatch: Colors.amber,
//         scaffoldBackgroundColor: Colors.yellow.shade100,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.amber.shade50,
//         appBar: AppBar(
//           title: const Text("UniEats 🍽️"),
//           backgroundColor: Colors.amber,
//           foregroundColor: Colors.black,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.receipt_long),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const OrderStatusPage()),
//                 );
//               },
//             ),
//           ],
//         ),
//         body: IndexedStack(
//           index: _selectedIndex,
//           children: [
//
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           backgroundColor: Colors.amber.shade700,
//           selectedItemColor: Colors.amber.shade700,
//           unselectedItemColor: Colors.black,
//           showSelectedLabels: true,
//           showUnselectedLabels: false,
//           currentIndex: _selectedIndex,
//           onTap: _onItemTapped,
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//             BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
//             BottomNavigationBarItem(icon: Icon(Icons.shopping_cart, size: 30), label: "Orders"),
//             BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"),
//           ],
//         ),
//       ),
//     );
//   }
// }