import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/others/themes.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  bool darkTheme = false;

  _initalDataLoad() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme(await getTheme(context));

    if (this.mounted) {
      setState(() {
        darkTheme = themeProvider.darkTheme;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initalDataLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Text(
              "Settle Now",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: darkTheme ? null : Theme.of(context).primaryColor,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/Images/404Error.gif',
                  width: min(800, MediaQuery.of(context).size.width),
                  height: min(600, MediaQuery.of(context).size.height),
                ),
                Text(
                  "Looks like you're lost!",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
