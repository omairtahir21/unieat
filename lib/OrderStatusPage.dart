import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unieat/services/database_service.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  _OrderStatusPageState createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  List<Map<String, dynamic>> userOrders = [];

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  Future<void> _loadUserOrders() async {
    int userId = 1;
    final orders = await DatabaseHelper.instance.getUserOrders(userId);

    for (var order in orders) {
      print(order); // 👀 Check the actual column names and values
    }

    setState(() => userOrders = orders);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: userOrders.isEmpty
          ? const Center(child: Text("No orders yet."))
          : ListView.builder(
        itemCount: userOrders.length,
        itemBuilder: (context, index) {
          final order = userOrders[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(order['food_name'] ?? "Unknown Food",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              subtitle: Text("Status: ${order['status'] ?? "Pending"}"),
              trailing: Text("₹${order['price']?.toString() ?? "0.0"}",
                  style: TextStyle(color: Colors.green)),
            )


          );
        },
      ),
    );
  }
}
