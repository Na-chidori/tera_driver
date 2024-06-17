import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CommonLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.0, // Set your desired height here
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/welcomepage/Semerit.png",
              width: 150,
            ),
            "SEMERIT".text.xl4.bold.color(Colors.black).make(),
          ],
        ),
      ),
    );
  }
}
