import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  AboutUs({ Key? key }) : super(key: key);

  final Shader linearGradient = LinearGradient(
      colors: <Color>[Color.fromARGB(255, 243, 33, 112), Color.fromARGB(255, 255, 235, 7), Color.fromARGB(255,33, 150, 243), Color.fromARGB(255, 255, 0, 235)],
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Settle Now By Rohit Anand",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                foreground: Paint()..shader = linearGradient,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    launch("mailto:rrohitanand3336@gmail.com");
                  }, 
                  icon: FaIcon(FontAwesomeIcons.envelope, size: 35,),
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {
                    launch("http://github.com/rranand");
                  }, 
                  icon: FaIcon(FontAwesomeIcons.github, size: 35,)
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {
                    launch("https://www.linkedin.com/in/rohit-anand-86a869184/");
                  }, 
                  icon: FaIcon(FontAwesomeIcons.linkedin, size: 35,)
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}