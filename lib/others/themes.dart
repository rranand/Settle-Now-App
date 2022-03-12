import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ThemeProvider extends ChangeNotifier {
  bool darkTheme = false;

  bool get isDarkTheme => darkTheme;

  void toggleTheme(bool flag) {
    darkTheme = flag;
    notifyListeners();
  }
}

class ColorProvider extends ChangeNotifier {
  MaterialColor color = Colors.deepPurple;
  MaterialColor get getPrimaryColor => color;

  void changeColor(Color nColor) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = nColor.red, g = nColor.green, b = nColor.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    
    color = MaterialColor(nColor.value, swatch);
    notifyListeners();
  }
}


class MyTheme {
  static ThemeData lightTheme(BuildContext context, MaterialColor primaryColor) { 
    return ThemeData(
      primarySwatch: primaryColor,
      fontFamily: GoogleFonts.lato().fontFamily,
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black), 
        toolbarTextStyle: Theme.of(context).textTheme.bodyText2, 
        titleTextStyle: Theme.of(context).textTheme.headline6,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: primaryColor,
      ), 
      textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
      textTheme: TextTheme(
        bodyText1: TextStyle(),
        bodyText2: TextStyle(),
      ).apply(
        bodyColor: Colors.black,
        displayColor: Colors.white
      ),
      scaffoldBackgroundColor: Colors.white,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(Colors.grey.shade800),
      ),
      
    );
  }

  static ThemeData darTheme(BuildContext context) => ThemeData(
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.lato().fontFamily,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 65, 105, 225)
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all(Color.fromARGB(255, 65, 105, 225)),
    ),
    textTheme: TextTheme(
        bodyText1: TextStyle(),
        bodyText2: TextStyle(),
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.black
      ),
  );
}
