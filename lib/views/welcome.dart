import 'package:flutter/material.dart';
import 'package:tera_driver/views/Authentication/Login.dart';
import 'package:tera_driver/views/Authentication/register.dart';
import 'package:animate_do/animate_do.dart';

class welcomepage extends StatelessWidget {
  const welcomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey[600] ?? Colors.grey],
            ),
          ),
          child: SafeArea(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // App Logo
                  Image.asset(
                    'assets/welcomepage/logoo.png',
                    width: 180, // Adjust the width as needed
                    height: 180,
                  ),

                  Column(
                    children: <Widget>[
                      // Welcome Text
                      FadeInUp(
                        duration: Duration(milliseconds: 1000),
                        child: Text(
                          "Welcome",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // App Description
                      FadeInUp(
                        duration: Duration(milliseconds: 1200),
                        child: Text(
                          "An Ideal App designed for your Growth",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.brown[900],
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Image
                  FadeInUp(
                    duration: Duration(milliseconds: 1400),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/welcomepage/Welcome-pana.png'),
                          fit: BoxFit.contain,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Column(
                    children: <Widget>[
                      // Login Button
                      FadeInUp(
                        duration: Duration(milliseconds: 1500),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.brown[600],
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Sign Up Button
                      FadeInUp(
                        duration: Duration(milliseconds: 1600),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Registration(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.orange[600],
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
