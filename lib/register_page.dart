import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_model.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final name = _nameController.text;
    final idNumber = _idController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (name.isNotEmpty && idNumber.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      User user = User(name: name, idNumber: idNumber, email: email, password: password);
      await DatabaseHelper.instance.insertUser(user.toMap());
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
              SizedBox(height: 16),
              TextField(controller: _idController, decoration: InputDecoration(labelText: 'ID Number')),
              SizedBox(height: 16),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
              SizedBox(height: 16),
              TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password')),
              SizedBox(height: 24),
              AnimatedContainer(
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _register,
                  child: Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
