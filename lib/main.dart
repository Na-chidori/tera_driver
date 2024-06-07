import 'package:flutter/material.dart';
import 'package:tera_driver/util.dart';
import 'package:tera_driver/views/Screens/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tera_driver/views/Authentication/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(
    token: prefs.getString('token'),
  ));
}

class MyApp extends StatelessWidget {
  final token;
  const MyApp({
    @required this.token,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.black,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: (token != null && !JwtDecoder.isExpired(token))
            ? HomeScreen(token: token)
            : SignInPage());
  }
}
