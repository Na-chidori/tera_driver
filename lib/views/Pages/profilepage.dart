import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tera_driver/models/usermodels.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tera_driver/views/controllers/config.dart';

class ProfilePage extends StatefulWidget {
  final String token;
  const ProfilePage({required this.token, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserModels> _futureUser;
  late String userId;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    _futureUser = fetchUserDetails(userId);
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
                      onTap: () {
                        // Open image picker to change profile picture
                      },
                      child: CircleAvatar(
                        radius: 50,
                        // Replace with actual profile picture URL
                        backgroundImage:
                            AssetImage('assets/uploads/1664982164878.jpg'),
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
                          onPressed: () {},
                          child: const Text('Edit Profile'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to change password page
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
                        ListTile(
                          title: const Text('assigned Employee Full Name'),
                          subtitle: Text(user.assignedEmployeeFullName),
                        ),
                        ListTile(
                          title: const Text('assigned Employee Id'),
                          subtitle: Text(user.assignedEmployeeId),
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
