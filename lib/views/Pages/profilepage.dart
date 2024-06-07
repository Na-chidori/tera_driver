import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tera_driver/models/usermodels.dart';
import 'package:tera_driver/views/Pages/ChangePasswordPage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tera_driver/views/controllers/config.dart';
import 'package:tera_driver/views/Pages/EditProfilePage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final String token;
  const ProfilePage({required this.token, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserModels> _futureUser;
  late String userId;
  File? _image;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    _futureUser = fetchUserDetails(userId);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadProfilePicture(_image!);
    }
  }

  Future<void> _uploadProfilePicture(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('your_api_endpoint/uploadProfilePicture'),
    );
    request.files.add(await http.MultipartFile.fromPath('picture', image.path));
    request.fields['userId'] = userId;

    final response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        _futureUser = fetchUserDetails(userId); // Refresh user data
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile picture.')),
      );
    }
  }

  Future<UserModels> fetchUserDetails(String userId) async {
    try {
      final response = await http.get(Uri.parse('$get/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return UserModels.fromJson(responseData);
      } else {
        print('Failed to load user details - ${response.statusCode}');
        print(response.body);
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      throw Exception('Failed to load user details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<UserModels>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final user = snapshot.data!;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        // Replace with actual profile picture URL
                        backgroundImage: _image != null
                            ? FileImage(_image!) as ImageProvider<Object>
                            : AssetImage('assets/uploads/1664982164878.jpg')
                                as ImageProvider<Object>,
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // Full name
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.headline6,
                    ),

                    const SizedBox(height: 16.0),

                    // Edit profile and change password buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final updatedUser = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProfilePage(user: user),
                              ),
                            );
                            if (updatedUser != null) {
                              setState(() {
                                _futureUser = Future.value(updatedUser);
                              });
                            }
                          },
                          child: const Text('Edit Profile'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangePasswordPage(userId: userId),
                              ),
                            );
                          },
                          child: const Text('Change Password'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32.0),

                    // Profile details list view
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ListTile(
                          title: const Text('Email'),
                          subtitle: Text(user.email),
                        ),
                        ListTile(
                          title: const Text('Phone'),
                          subtitle: Text(user.phone),
                        ),
                        ListTile(
                          title: const Text('First Name'),
                          subtitle: Text(user.name.split(' ')[0]),
                        ),
                        ListTile(
                          title: const Text('Last Name'),
                          subtitle: Text(user.name.split(' ')[1]),
                        ),
                        ListTile(
                          title: const Text('Code'),
                          subtitle: Text(user.code.toString()),
                        ),
                        ListTile(
                          title: const Text('License Plate'),
                          subtitle: Text(user.licenseplate),
                        ),
                        ListTile(
                          title: const Text('License Number'),
                          subtitle: Text(user.licensenumber),
                        ),
                        ListTile(
                          title: const Text('Assigned Route'),
                          subtitle: Text(user.Assignedroute),
                        ),
                        ListTile(
                          title: const Text('City District'),
                          subtitle: Text(user.cityDistrict),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
