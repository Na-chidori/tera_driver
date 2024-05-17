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
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(
    token: prefs.getString('token'),
  ));
}

class MyApp extends StatelessWidget {
  final token;
  final userId;
  const MyApp({
    @required this.token,
    @required this.userId,
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
            home: (token != null && JwtDecoder.isExpired(token) == false)
                ? HomeScreen(token: token)
                : SignInPage()),
      ),
    );
  }
}
