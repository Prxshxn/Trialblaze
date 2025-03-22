import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:createtrial/utils/validation_utils.dart';
import 'package:createtrial/utils/toast_utils.dart';

enum UserType { hiker, responder }
enum HikingExperience { beginner, intermediate, expert }
enum Gender { male, female }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserType? _selectedUserType;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _responderTypeController = TextEditingController();
  final _locationController = TextEditingController();
  
  HikingExperience _hikingExperience = HikingExperience.beginner;
  Gender _gender = Gender.male;
  bool _isLoading = false;

  String _getHikingExperienceString() {
    switch (_hikingExperience) {
      case HikingExperience.beginner:
        return 'Beginner';
      case HikingExperience.intermediate:
        return 'Intermediate';
      case HikingExperience.expert:
        return 'Expert';
    }
  }

  String _getGenderString() {
    switch (_gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }

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
      final url = _selectedUserType == UserType.hiker
          ? Uri.parse('http://13.53.173.93:5000/api/v1/register/hiker')
          : Uri.parse('http://13.53.173.93:5000/api/v1/register/responder');

      final Map<String, dynamic> body = _selectedUserType == UserType.hiker
          ? {
              'email': _emailController.text,
              'username': _usernameController.text,
              'password': _passwordController.text,
              'hikingExperience': _getHikingExperienceString(),
              'emergencyContact': _emergencyContactController.text,
              'address': _addressController.text,
              'gender': _getGenderString(),
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
            errorData['message'] ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Network error: Please check your connection');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildUserTypeSelection() {
    return Column(
      children: [
        const Text(
          'I am a',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildUserTypeCard(
              UserType.hiker, 
              'Hiker', 
              Icons.hiking,
              'I am exploring nature and want safety features'
            ),
            _buildUserTypeCard(
              UserType.responder, 
              'Emergency Responder', 
              Icons.health_and_safety,
              'I provide assistance to hikers in need'
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTypeCard(UserType type, String title, IconData icon, String description) {
    final isSelected = _selectedUserType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected 
            ? [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)]
            : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _usernameController,
            label: 'Username',
            validator: ValidationUtils.validateUsername,
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            validator: ValidationUtils.validateEmail,
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            validator: ValidationUtils.validatePassword,
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          if (_selectedUserType == UserType.hiker) ...[
            _buildDropdownField(
              value: _hikingExperience,
              onChanged: (HikingExperience? newValue) {
                setState(() {
                  _hikingExperience = newValue!;
                });
              },
              items: HikingExperience.values.map((HikingExperience experience) {
                String displayText = experience.toString().split('.').last;
                displayText = displayText[0].toUpperCase() + displayText.substring(1);
                return DropdownMenuItem<HikingExperience>(
                  value: experience,
                  child: Text(displayText, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              label: 'Hiking Experience',
              icon: Icons.terrain,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emergencyContactController,
              label: 'Emergency Contact',
              validator: ValidationUtils.validatePhoneNumber,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              validator: ValidationUtils.validateAddress,
              icon: Icons.home,
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              value: _gender,
              onChanged: (Gender? newValue) {
                setState(() {
                  _gender = newValue!;
                });
              },
              items: Gender.values.map((Gender gender) {
                String displayText = gender.toString().split('.').last;
                displayText = displayText[0].toUpperCase() + displayText.substring(1);
                return DropdownMenuItem<Gender>(
                  value: gender,
                  child: Text(displayText, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              label: 'Gender',
              icon: Icons.people,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              validator: ValidationUtils.validateAge,
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),
          ] else if (_selectedUserType == UserType.responder) ...[
            _buildTextField(
              controller: _responderTypeController,
              label: 'Responder Type',
              validator: ValidationUtils.validateResponderType,
              icon: Icons.business,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emergencyContactController,
              label: 'Emergency Contact',
              validator: ValidationUtils.validatePhoneNumber,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              validator: ValidationUtils.validateLocation,
              icon: Icons.location_on,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account?',
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required FormFieldValidator<String> validator,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required ValueChanged<T?> onChanged,
    required List<DropdownMenuItem<T>> items,
    required String label,
    required IconData icon,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      items: items,
      style: const TextStyle(color: Colors.white),
      dropdownColor: Colors.grey.shade900,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: _selectedUserType == null
                ? _buildUserTypeSelection()
                : _buildRegistrationForm(),
          ),
        ),
      ),
    );
  }
}