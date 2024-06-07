import 'package:flutter/material.dart';
import 'package:tera_driver/views/Pages/attendance.dart';
import 'package:tera_driver/views/Pages/complaints.dart';
import 'package:tera_driver/views/Pages/notifications.dart';
import 'package:tera_driver/views/Pages/punishment.dart';
import 'package:tera_driver/views/Pages/routes.dart';
import 'package:tera_driver/views/Pages/warnings.dart';
import 'package:tera_driver/views/controllers/nav_bar.dart';
import 'package:tera_driver/models/usermodels.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tera_driver/views/controllers/config.dart';

class HomeScreen extends StatefulWidget {
  final token;
  const HomeScreen({@required this.token, Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<UserModels> _futureUser;
  late String userId;
  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    _futureUser = fetchUserDetails(userId);
  }

  GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Add this key

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

  List<String> imgList = [
    'attendance',
    'warnings',
    'notifications',
    'routes',
    'punishments',
    'complaints',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: NavBar(token: widget.token),
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
            return Stack(
              children: [
                Image.asset(
                  'assets/homepage/background.jpg',
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  child: ListView(
                    children: [
                      Container(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 15,
                            left: 15,
                            right: 15,
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/homepage/dashboard.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/homepage/logoo.png',
                                      width: 100,
                                      height: 100,
                                    ),
                                    Text(
                                      "Welcome" +
                                          ' ' +
                                          user.name.split(' ')[0] +
                                          '!',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                        wordSpacing: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      DateTime.now().hour.toString() +
                                          ":" +
                                          DateTime.now().minute.toString(),
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.builder(
                          itemCount: imgList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                          ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                navigateToScreen(index);
                              },
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        const Color.fromARGB(
                                            255, 171, 205, 234),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/homepage/${imgList[index]}.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        imgList[index].capitalize(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Attendance(token: widget.token),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WarningsPage(token: widget.token),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationPage(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Routes(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PunishmentsPage(
              token: widget.token,
            ),
          ),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Complaints(
              token: widget.token,
            ),
          ),
        );
        break;
      default:
        break;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
