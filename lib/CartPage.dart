import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onOrderPlaced;
  final Function(int) onRemoveItem;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onOrderPlaced,
    required this.onRemoveItem,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: widget.cartItems.isEmpty
          ? const Center(child: Text("Cart is empty", style: TextStyle(fontSize: 18)))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return ListTile(
                  title: Text(item['name'], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text("₹${item['price']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() => widget.onRemoveItem(index));
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
              onPressed: widget.cartItems.isEmpty ? null : widget.onOrderPlaced,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
              child: const Text("Place Order", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
