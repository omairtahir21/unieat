import 'package:flutter/material.dart';
import 'ManageFoodPage.dart';
import 'OrdersPage.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const OrdersPage(),
    const ManageFoodPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.amber.shade700,
        centerTitle: true,
        elevation: 5,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.amber.shade700,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: "Manage Food",
          ),
        ],
      ),
    );
  }
}
