import 'package:flutter/material.dart';
import 'package:unieat/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await debugCheckOrders(); // Check if orders are being fetched
      _loadOrders();
    });
  }


  Future<void> _loadOrders() async {
    final orderList = await DatabaseHelper.instance.getOrders();
    print("Loaded Orders with Food Name: $orderList"); // Debugging
    setState(() {
      orders = orderList;
      isLoading = false;
    });
  }

  Future<void> debugCheckOrders() async {
    final db = await DatabaseHelper.instance.database;
    final orders = await db.query('orders');
    print("Debug Orders from DB: $orders");
  }



  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    await DatabaseHelper.instance.updateOrderStatus(orderId, newStatus);
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.yellow.shade100,
        cardColor: Colors.yellow.shade50,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.amber, elevation: 0),
      ),
      child: Scaffold(
          body: Padding(
              padding: const EdgeInsets.only(top: 16),  // Added top padding
              child:
         isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : orders.isEmpty
            ? const Center(child: Text("No orders available", style: TextStyle(fontSize: 18, color: Colors.black54)))
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: orders.length,
           itemBuilder: (context, index) {
             final order = orders[index];
             return Card(
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               elevation: 3,
               child: ListTile(
                 contentPadding: const EdgeInsets.all(16),
                 leading: CircleAvatar(
                   backgroundColor: Colors.amber.shade700,
                   radius: 30,
                   child: Text(
                     "#${order['id']}",
                     style: GoogleFonts.poppins(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                       color: Colors.black,
                     ),
                   ),
                 ),
                 title: Text(
                   "Total: \$${order['totalPrice']}",
                   style: GoogleFonts.poppins(
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                     color: Colors.black,
                   ),
                 ),
                 subtitle: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         Icon(Icons.location_on, color: Colors.red, size: 18),
                         const SizedBox(width: 5),
                         Expanded(
                           child: Text(
                             order['address'],
                             style: GoogleFonts.poppins(
                               fontSize: 14,
                               color: Colors.black54,
                             ),
                             overflow: TextOverflow.ellipsis,
                             maxLines: 2,
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         Icon(Icons.info, color: _getStatusColor(order['status']), size: 18),
                         const SizedBox(width: 5),
                         Text(
                           "Status: ${order['status']}",
                           style: GoogleFonts.poppins(
                             fontSize: 14,
                             fontWeight: FontWeight.w500,
                             color: _getStatusColor(order['status']),
                           ),
                         ),
                       ],
                     ),
                   ],
                 ),
                 trailing: PopupMenuButton<String>(
                   icon: const Icon(Icons.more_vert, color: Colors.black),
                   onSelected: (status) => _updateOrderStatus(order['id'], status),
                   itemBuilder: (context) => const [
                     PopupMenuItem(value: 'Processing', child: Text("Processing")),
                     PopupMenuItem(value: 'Delivered', child: Text("Delivered")),
                     PopupMenuItem(value: 'Canceled', child: Text("Canceled")),
                   ],
                 ),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(15),
                   side: BorderSide(color: Colors.grey.shade300),
                 ),
               )
               ,
             );
           }
           ,
        ),
      ),
    ));
  }
}
Color _getStatusColor(String status) {
  switch (status) {
    case 'Processing':
      return Colors.orange;
    case 'Delivered':
      return Colors.green;
    case 'Canceled':
      return Colors.red;
    default:
      return Colors.black;
  }
}