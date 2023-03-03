import 'package:flutter/material.dart';

class Maintenance extends StatelessWidget {
  Maintenance({Key? key}) : super(key: key);
  final Shader linearGradient = LinearGradient(
    colors: <Color>[
      Color.fromARGB(255, 243, 33, 112),
      Color.fromARGB(255, 255, 235, 7),
      Color.fromARGB(255, 33, 150, 243),
      Color.fromARGB(255, 255, 0, 235)
    ],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(
              'assets/Images/maintenance.jpg',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Sorry, we are down for maintenance but will be back in no time!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
