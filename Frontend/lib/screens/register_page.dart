import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum UserType { user, emergencyResponder }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserType _userType = UserType.user;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('YOUR_BACKEND_URL/api/customers/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'userType': _userType.toString().split('.').last, // Convert enum to string
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
      Navigator.pushNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
                const SizedBox(height: 16),
                TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 16),
                TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
