import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tera_driver/State/punishment_bloc.dart';
import 'package:tera_driver/views/Screens/HomeScreen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tera_driver/views/Authentication/login.dart';
import 'package:tera_driver/views/controllers/punishmentrepository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');
    runApp(MyApp(token: token, userId: userId));
  } catch (e) {
    print('Error initializing app: $e');
    runApp(MyApp(token: null, userId: null));
  }
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? userId;

  const MyApp({
    this.token,
    this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => PunishmentRepository(),
      child: BlocProvider(
        create: (context) =>
            PunishmentBloc()..add(GetPunishments(userId: userId ?? '')),
        child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.black,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
          ),
          home: _determineHomeScreen(),
        ),
      ),
    );
  }

  Widget _determineHomeScreen() {
    if (token != null) {
      try {
        if (!JwtDecoder.isExpired(token!)) {
          return HomeScreen(token: token);
        } else {
          print('Token is expired.');
        }
      } catch (e) {
        print('Error decoding token: $e');
      }
    } else {
      print('Token is null.');
    }
    return SignInPage();
  }
}
