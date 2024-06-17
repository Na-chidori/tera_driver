import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tera_driver/views/Authentication/Login.dart';
import 'package:tera_driver/views/controllers/applogo.dart';
import 'package:tera_driver/views/controllers/config.dart';
import 'package:velocity_x/velocity_x.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController licenseplateController = TextEditingController();
  TextEditingController licensenumberController = TextEditingController();
  bool _isNotValidate = false;

  // Data structure to hold the nested relationships
  Map<String, Map<String, List<String>>> districtData = {
    'Addis Ketema': {
      'Awtobusi Tera': [
        'Awtobusi Tera to Megenagna',
        'Awtobusi Tera to Lamm Beret',
        'Awtobusi Tera to Diaspora'
      ],
      'Merekato Amede': [
        'Merekato Amede to Asco',
        'Merekato Amede to Shegole',
        'Merekato Amede to Burrayu Mariyam'
      ],
      'Raguel': ['Raguel to Megenagna', 'Raguel to Minilik Hospital'],
      'Tana Gebeya': [
        'Tana Gebeya to Bole Micheal',
        'Tana Gebeya to Bole Medaniyalem',
        'Tana Gebeya to Megenagna'
      ],
      'Sinima Ras': [
        'Sinima Ras to Bole Deldeye',
        'Sinima Ras to Mekanisa',
        'Sinima Ras to Saris Abo'
      ],
      'Merab Hotel': [
        'Merab Hotel to Alem Bank',
        'Merab Hotel to Sebeta',
        'Merab Hotel to Welete'
      ],
      'Sebategna': [
        'Sebategna to Atena Tera',
        'Sebategna to Menagesha',
        'Sebategna to Lekunda'
      ],
      'Mesalemiya': [
        'Mesalemiya to Shero Meda',
        'Mesalemiya to Tourist Hotel',
        'Mesalemiya to Asco'
      ],
      'Atena Tera': [
        'Atena Tera to Giorgis',
        'Atena Tera to Piassa',
        'Atena Tera to Asco'
      ]
    },
    'Arada': {
      '4 Kilo': [
        '4 Kilo to Bole Deldeye',
        '4 Kilo to Kality Total',
        '4 Kilo to Kotebe College',
        '4 Kilo to Megenagna'
      ],
      'Piassa Mazegaja': [
        'Piassa Mazegaja to Adey Abeba',
        'Piassa Mazegaja to Sidist Kilo'
      ],
      'Piassa': [
        'Piassa to Stadium',
        'Piassa to Giorgis',
        'Piassa to Kolfe',
        'Piassa to Arat Kilo'
      ],
      'Giorgis': ['Giorgis to Liqawndoxa', 'Giorgis to St. Michael'],
      'Tourist Hotel': [
        'Tourist Hotel to Ambassador Cinema',
        'Tourist Hotel to Wenge'
      ]
    },
    'Bole': {
      'Megenagna': ['Megenagna to Gofa Mebrat Hail', 'Megenagna to Merkato'],
      'Bole Deldeye': [
        'Bole Deldeye to Seme Hail',
        'Bole Deldeye to Bole Michael',
        'Bole Deldeye to Bole Michael Square',
        'Bole Deldeye to 22',
        'Bole Deldeye to Welo Sefer',
        'Bole Deldeye to Yoseyf',
        'Bole Deldeye to Sefer Tsefaye'
      ],
      'Bole Michael': [
        'Bole Michael to Piassa',
        'Bole Michael to Bole Minilik'
      ],
      'Welo Sefer': ['Welo Sefer to Kaliti'],
      'Bole Kefle Ketema': ['Bole Kefle Ketema to Goro']
    }
  };

  List<String> districts = [];
  List<String> terminals = [];
  List<String> routes = [];

  // Selected values for dropdowns
  String? selectedDistrict;
  String? selectedTerminal;
  String? selectedRoute;

  @override
  void initState() {
    super.initState();
    districts = districtData.keys.toList();
  }

  void updateTerminals() {
    setState(() {
      terminals = selectedDistrict != null
          ? districtData[selectedDistrict!]!.keys.toList()
          : [];
      selectedTerminal = null;
      updateRoutes();
    });
  }

  void updateRoutes() {
    setState(() {
      routes = selectedTerminal != null
          ? districtData[selectedDistrict!]![selectedTerminal!]!
          : [];
      selectedRoute = null;
    });
  }

  void registerUser() async {
    if (emailController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        codeController.text.isNotEmpty &&
        licenseplateController.text.isNotEmpty &&
        licensenumberController.text.isNotEmpty &&
        selectedDistrict != null &&
        selectedTerminal != null &&
        selectedRoute != null) {
      var regBody = {
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "email": emailController.text,
        "username": usernameController.text,
        "phone": phoneController.text,
        "password": passwordController.text,
        "code": codeController.text,
        "licenseplate": licenseplateController.text,
        "licensenumber": licensenumberController.text,
        "cityDistrict": selectedDistrict,
        "Assignedroute": selectedRoute,
        "Terminal": selectedTerminal,
      };

      var response = await http.post(Uri.parse(register),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User registered successfully"),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignInPage()));
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message']),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Internal server error"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
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
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.white,
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CommonLogo().wh(150, 150), // Enlarged logo
                        HeightBox(10),
                        "CREATE YOUR ACCOUNT".text.size(22).blue300.make(),
                        TextField(
                          controller: firstNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              errorStyle: TextStyle(color: Colors.white),
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              hintText: "First Name",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        TextField(
                          controller: lastNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              errorStyle: TextStyle(color: Colors.white),
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              hintText: "Last Name",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              errorStyle: TextStyle(color: Colors.white),
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              hintText: "Email",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        TextField(
                          controller: usernameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              errorStyle: TextStyle(color: Colors.white),
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              hintText: "Username",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              errorStyle: TextStyle(color: Colors.white),
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              hintText: "Phone",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        TextField(
                          controller: passwordController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.copy),
                                onPressed: () {
                                  final data = ClipboardData(
                                      text: passwordController.text);
                                  Clipboard.setData(data);
                                },
                              ),
                              prefixIcon: IconButton(
                                icon: Icon(Icons.password),
                                onPressed: () {
                                  String passGen = generatePassword();
                                  passwordController.text = passGen;
                                  setState(() {});
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              errorStyle: TextStyle(color: Colors.white),
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              hintText: "Password",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        TextField(
                          controller: codeController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              errorStyle: TextStyle(color: Colors.white),
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              hintText: "Code",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        TextField(
                          controller: licenseplateController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              errorStyle: TextStyle(color: Colors.white),
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              hintText: "License Plate",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        TextField(
                          controller: licensenumberController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              errorStyle: TextStyle(color: Colors.white),
                              errorText:
                                  _isNotValidate ? "Enter Proper Info" : null,
                              hintText: "License Number",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)))),
                        ).p4().px24(),
                        DropdownButtonFormField<String>(
                          value: selectedDistrict,
                          items: districts.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedDistrict = newValue;
                              updateTerminals();
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Select District",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            errorStyle: TextStyle(color: Colors.white),
                            errorText:
                                _isNotValidate && selectedDistrict == null
                                    ? "Enter Proper Info"
                                    : null,
                          ),
                        ).p4().px24(),
                        DropdownButtonFormField<String>(
                          value: selectedTerminal,
                          items: terminals.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedTerminal = newValue;
                              updateRoutes();
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Select Terminal",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            errorStyle: TextStyle(color: Colors.white),
                            errorText:
                                _isNotValidate && selectedTerminal == null
                                    ? "Enter Proper Info"
                                    : null,
                          ),
                        ).p4().px24(),
                        DropdownButtonFormField<String>(
                          value: selectedRoute,
                          items: routes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedRoute = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Select Route",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            errorStyle: TextStyle(color: Colors.white),
                            errorText: _isNotValidate && selectedRoute == null
                                ? "Enter Proper Info"
                                : null,
                          ),
                        ).p4().px24(),
                        HStack([
                          GestureDetector(
                            onTap: () {
                              registerUser();
                            },
                            child: VxBox(
                                    child: "Register"
                                        .text
                                        .white
                                        .makeCentered()
                                        .p16())
                                .blue600
                                .roundedLg
                                .width(150)
                                .make()
                                .px16()
                                .py16(),
                          ),
                        ]),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignInPage()));
                          },
                          child: HStack([
                            "Already Registered?".text.make(),
                            " Sign In".text.blue500.make()
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

String generatePassword() {
  String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String lower = 'abcdefghijklmnopqrstuvwxyz';
  String numbers = '1234567890';
  String symbols = '!@#\$%^&*()<>,./';

  String password = '';

  int passLength = 20;

  String seed = upper + lower + numbers + symbols;

  List<String> list = seed.split('').toList();

  Random rand = Random();

  for (int i = 0; i < passLength; i++) {
    int index = rand.nextInt(list.length);
    password += list[index];
  }
  return password;
}
