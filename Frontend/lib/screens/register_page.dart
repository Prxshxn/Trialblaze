import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trialblaze1/utils/toast_utils.dart';
import 'package:trialblaze1/utils/validation_utils.dart';

enum UserType { hiker, responder }

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
  final _hikingExperienceController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _genderController = TextEditingController();
  final _ageController = TextEditingController();
  final _responderTypeController = TextEditingController();
  final _locationController = TextEditingController();
  UserType _userType = UserType.hiker;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      ToastUtils.showErrorToast('Please fill all required fields correctly');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ToastUtils.showErrorToast('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = _userType == UserType.hiker
          ? Uri.parse('http://192.168.1.69:5005/api/v1/register/hiker')
          : Uri.parse('http://192.168.1.69:5005/api/v1/register/responder');

      final Map<String, dynamic> body = _userType == UserType.hiker
          ? {
              'email': _emailController.text,
              'username': _usernameController.text,
              'password': _passwordController.text,
              'hikingExperience': _hikingExperienceController.text,
              'emergencyContact': _emergencyContactController.text,
              'address': _addressController.text,
              'gender': _genderController.text,
              'age': int.parse(_ageController.text),
            }
          : {
              'email': _emailController.text,
              'username': _usernameController.text,
              'password': _passwordController.text,
              'responderType': _responderTypeController.text,
              'emergencyContact': _emergencyContactController.text,
              'location': _locationController.text,
            };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ToastUtils.showSuccessToast('Registration successful! Please login.');
        Navigator.pushNamed(context, '/login');
      } else {
        final errorData = json.decode(response.body);
        print('Error Response: ${response.body}');
        ToastUtils.showErrorToast(
          errorData['message'] ?? 'Registration failed. Please try again.'
        );
      }
    } catch (e) {
      ToastUtils.showErrorToast('Network error: Please check your connection');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: ValidationUtils.validateUsername,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: ValidationUtils.validateEmail,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: ValidationUtils.validatePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserType>(
                    value: _userType,
                    onChanged: (UserType? newValue) {
                      setState(() {
                        _userType = newValue!;
                      });
                    },
                    items: UserType.values.map((UserType type) {
                      return DropdownMenuItem<UserType>(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'User Type'),
                  ),
                  const SizedBox(height: 16),
                  if (_userType == UserType.hiker) ...[
                    TextFormField(
                      controller: _hikingExperienceController,
                      decoration: const InputDecoration(labelText: 'Hiking Experience'),
                      validator: ValidationUtils.validateHikingExperience,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emergencyContactController,
                      decoration: const InputDecoration(labelText: 'Emergency Contact'),
                      validator: ValidationUtils.validatePhoneNumber,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: ValidationUtils.validateAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _genderController,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      validator: ValidationUtils.validateGender,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      validator: ValidationUtils.validateAge,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.done,
                    ),
                  ] else if (_userType == UserType.responder) ...[
                    TextFormField(
                      controller: _responderTypeController,
                      decoration: const InputDecoration(labelText: 'Responder Type'),
                      validator: ValidationUtils.validateResponderType,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emergencyContactController,
                      decoration: const InputDecoration(labelText: 'Emergency Contact'),
                      validator: ValidationUtils.validatePhoneNumber,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: ValidationUtils.validateLocation,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Register'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}