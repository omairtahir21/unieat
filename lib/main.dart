   import 'package:flutter/material.dart';
import 'package:unieat/AdminHome.dart';
import 'package:unieat/UserHome.dart';
import 'package:unieat/login_screen.dart';
import 'package:unieat/signup_screen.dart';
import 'package:unieat/splash_screen.dart';


void main() {
  runApp(const UniEats());
}

class UniEats extends StatelessWidget {
  const UniEats({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) =>  const LoginScreen(),
        '/signup': (context) =>  const SignupScreen(),
        '/admin_home': (context) => const AdminHome(),
        '/user_home': (context) => const UserHome(),
      },
    );
  }
}
