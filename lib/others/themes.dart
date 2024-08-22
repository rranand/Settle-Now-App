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

class MyTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple.shade900,
        fontFamily: GoogleFonts.lato().fontFamily,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
          toolbarTextStyle: Theme.of(context).textTheme.bodyMedium,
          titleTextStyle: Theme.of(context).textTheme.titleLarge,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.deepPurple,
        ),
        textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
        textTheme: TextTheme(
          bodyLarge: TextStyle(),
          bodyMedium: TextStyle(),
        ).apply(bodyColor: Colors.black87, displayColor: Colors.white),
        scaffoldBackgroundColor: Colors.white,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(Colors.deepPurpleAccent),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.deepPurple,
        ));
  }

  static ThemeData darTheme(BuildContext context) => ThemeData(
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(0xFF69F0AE, <int, Color>{
        50: Color(0xFFEDFDF5),
        100: Color(0xFFD2FBE7),
        200: Color(0xFFB4F8D7),
        300: Color(0xFF96F5C6),
        400: Color(0xFF80F2BA),
        500: Color(0xFF69F0AE),
        600: Color(0xFF61EEA7),
        700: Color(0xFF56EC9D),
        800: Color(0xFF4CE994),
        900: Color(0xFF3BE584),
      }),
      primaryColor: Colors.greenAccent.withAlpha(205),
      fontFamily: GoogleFonts.lato().fontFamily,
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: Colors.greenAccent),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(Color.fromARGB(255, 105, 240, 174)),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(),
        bodyMedium: TextStyle(),
      ).apply(bodyColor: Colors.white, displayColor: Colors.black),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.greenAccent,
      ));
}
