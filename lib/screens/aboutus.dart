import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:settlenow/functions/gradient.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  AboutUs({Key? key}) : super(key: key);

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
                foreground: kIsWeb?null:(Paint()..shader = linearGradient),
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
                    launchUrl(
                      Uri.parse("mailto:info@settlenow.in"),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.envelope,
                    size: 35,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse("http://github.com/rranand"),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.github,
                      size: 35,
                    )),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse("https://www.linkedin.com/in/rohitanand99/"),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.linkedin,
                      size: 35,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
