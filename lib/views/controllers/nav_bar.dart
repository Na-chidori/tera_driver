import 'package:flutter/material.dart';
import 'package:tera_driver/views/Pages/profilepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tera_driver/views/Pages/notifications.dart';
import 'package:tera_driver/views/Authentication/login.dart';
import 'package:tera_driver/models/usermodels.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tera_driver/views/controllers/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Nav_bar extends StatefulWidget {
  final token;

  const Nav_bar({@required this.token, Key? key}) : super(key: key);
  @override
  _Nav_barState createState() => _Nav_barState();
}

class _Nav_barState extends State<Nav_bar> {
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

  Future<void> _logout() async {
    // Clear token from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignInPage(),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
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
            return Drawer(
              child: ListView(
                // Remove padding
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(user.name.split(' ')[0] +
                        ' ' +
                        user.name.split(' ')[1]),
                    accountEmail: Text(user.email),
                    currentAccountPicture: CircleAvatar(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/uploads/1664982164878.jpg',
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage(
                            'assets/homepage/rm222batch5-kul-03.jpg'),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(token: widget.token),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Notifications'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationPage(),
                      ),
                    ),
                    trailing: ClipOval(
                      child: Container(
                        color: Colors.red,
                        width: 20,
                        height: 20,
                        child: Center(
                          child: Text(
                            '8',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () => null,
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: Text('Help'),
                    onTap: () => null,
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Logout'),
                    leading: Icon(Icons.exit_to_app),
                    iconColor: Colors.red,
                    onTap: () => _logout,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
