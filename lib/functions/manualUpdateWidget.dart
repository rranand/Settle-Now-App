import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/VersionInfo.dart';
import 'package:settlenow/others/themes.dart';
import 'package:url_launcher/url_launcher.dart';

Widget updateWidget(BuildContext context, VersionInfo versionInfo) {
  final themeProvider = Provider.of<ThemeProvider>(context);

  return Scaffold(
    appBar: AppBar(
      title: Text(
        "Settle Now (New Update Available)",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
            onPressed: () async {
              final provider =
                  Provider.of<ThemeProvider>(context, listen: false);
              provider.toggleTheme(!themeProvider.darkTheme);
              setBoolPrefs('darkTheme', themeProvider.darkTheme);
            },
            icon: Icon(
              Icons.brightness_2,
              color: themeProvider.darkTheme ? Colors.white : Colors.black87,
            ))
      ],
    ),
    body: UpdatePage(versionInfo: versionInfo),
  );
}

class UpdatePage extends StatelessWidget {
  final VersionInfo versionInfo;
  UpdatePage({Key? key, required this.versionInfo}) : super(key: key);

  _launchURL(BuildContext context) async {
    launchUrl(
      Uri.parse(versionInfo.link),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Version: ${versionInfo.version.split('+').first}",
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "What\'s new \n ${versionInfo.description.split(',').map((e) => '  * ' + e).join('\n')}",
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 45,
                  child: OutlinedButton(
                    child: Text(
                      'Download',
                      style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      _launchURL(context);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
