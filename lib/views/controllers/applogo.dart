import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CommonLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          "assets/welcomepage/logoo.png",
          width: 100,
        ),
        "Tera-Driver App".text.xl2.italic.make(),
        "Our new slogan".text.light.white.wider.lg.make(),
      ],
    );
  }
}
