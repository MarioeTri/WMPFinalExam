import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(userId: ModalRoute.of(context)!.settings.arguments as int),
      },
    );
  }
}
