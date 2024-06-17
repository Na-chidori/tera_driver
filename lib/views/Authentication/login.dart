import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tera_driver/views/Screens/HomeScreen.dart';
import 'package:tera_driver/views/Authentication/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:tera_driver/views/controllers/applogo.dart';
import 'package:http/http.dart' as http;
import 'package:tera_driver/views/controllers/config.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  bool _obscurePassword = true;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      var reqBody = {
        "username": usernameController.text,
        "password": passwordController.text
      };

      var response = await http.post(Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));

      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      if (jsonResponse['status']) {
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(token: myToken)));
      } else {
        print('Something went wrong');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.lightBlueAccent,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  color: Colors.white,
                  elevation: 20.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CommonLogo().wh(150, 150),
                        "The Solution ".text.size(30).blue400.bold.make(),
                        "You Were".text.size(30).blue400.bold.make(),
                        "Looking For!".text.size(30).blue400.bold.make(),
                        SizedBox(height: 18),
                        "Welcome!".text.size(22).blue600.make(),
                        Image.asset(
                          'assets/welcomepage/driver-app.png',
                          width: 100,
                          height: 100,
                        ),
                        HeightBox(10),
                        TextField(
                          controller: usernameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "UserName",
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        TextField(
                          controller: passwordController,
                          keyboardType: TextInputType.text,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Password",
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        HeightBox(20),
                        GestureDetector(
                          onTap: () {
                            loginUser();
                          },
                          child: HStack([
                            VxBox(
                                    child:
                                        "LogIn".text.white.makeCentered().p20())
                                .blue600
                                .roundedLg
                                .width(150)
                                .make(),
                          ]),
                        ),
                        HeightBox(20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Registration()));
                          },
                          child: HStack([
                            "Create a new Account..".text.make(),
                            "Sign Up".text.blue500.make()
                          ]).centered(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
