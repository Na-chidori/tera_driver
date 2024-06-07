import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tera_driver/views/controllers/config.dart';

class ChangePasswordPage extends StatefulWidget {
  final String userId;
  const ChangePasswordPage({required this.userId, Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  late String _errorMessage = '';

  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _obscureCurrentPassword = !_obscureCurrentPassword;
    });
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.put(
        Uri.parse('$password/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          'oldPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );
      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully.')),
        );
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _errorMessage = responseData['error'] ?? 'Failed to change password.';
        });
      }
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  suffixIcon: IconButton(
                    onPressed: _toggleCurrentPasswordVisibility,
                    icon: Icon(_obscureCurrentPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                ),
                obscureText: _obscureCurrentPassword,
                validator: (value) => value!.isEmpty
                    ? 'Please enter your current password'
                    : null,
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    onPressed: _toggleNewPasswordVisibility,
                    icon: Icon(_obscureNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                ),
                obscureText: _obscureNewPassword,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a new password' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    onPressed: _toggleConfirmPasswordVisibility,
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
              ),
              if (_errorMessage.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
