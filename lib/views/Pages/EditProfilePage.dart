import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tera_driver/models/usermodels.dart';
import 'package:tera_driver/views/controllers/config.dart';

class EditProfilePage extends StatefulWidget {
  final UserModels user;
  const EditProfilePage({required this.user, Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = UserModels(
        id: widget.user.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        code: widget.user.code,
        licenseplate: widget.user.licenseplate,
        licensenumber: widget.user.licensenumber,
        Address: widget.user.Address,
        cityDistrict: widget.user.cityDistrict,
        Terminal: widget.user.Terminal,
        Assignedroute: widget.user.Assignedroute,
      );

      final response = await http.put(
        Uri.parse('$update/${widget.user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedUser.toJson()),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile Successfully updated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
