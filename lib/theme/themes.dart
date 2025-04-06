import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.deepPurple,
      primaryColor: Colors.deepPurple.shade900,
      appBarTheme: AppBarTheme(),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.deepPurple),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionColor: Colors.deepPurple.withAlpha(70),
        selectionHandleColor: Colors.deepPurple.withAlpha(70),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(),
        bodyMedium: TextStyle(),
      ).apply(bodyColor: Colors.black87, displayColor: Colors.white),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurpleAccent,
      ),
      scaffoldBackgroundColor: Colors.white,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurpleAccent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurpleAccent),
        ),
        labelStyle: TextStyle(color: Colors.black),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(4),
        thumbColor: WidgetStateProperty.all(Colors.deepPurpleAccent),
      ),
      sliderTheme: SliderThemeData(
        thumbColor: Colors.deepPurpleAccent,
        activeTrackColor: Colors.deepPurpleAccent.withOpacity(0.5),
        valueIndicatorColor: Colors.grey.withOpacity(0.3),
        valueIndicatorTextStyle: TextStyle(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.deepPurple,
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) => ThemeData(
    useMaterial3: true,
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
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.greenAccent,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStateProperty.all(4),
      thumbColor: WidgetStateProperty.all(Color.fromARGB(255, 105, 240, 174)),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: Colors.greenAccent.withAlpha(70),
      selectionHandleColor: Colors.greenAccent.withAlpha(70),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(),
      bodyMedium: TextStyle(),
    ).apply(bodyColor: Colors.white, displayColor: Colors.black),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.greenAccent,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.white),
      toolbarTextStyle: Theme.of(context).textTheme.bodyMedium,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
    ),
    drawerTheme: DrawerThemeData(),
    inputDecorationTheme: InputDecorationTheme(
      focusColor: Colors.greenAccent,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent),
      ),
      labelStyle: TextStyle(color: Colors.white),
    ),
    sliderTheme: SliderThemeData(
      thumbColor: Colors.greenAccent,
      activeTrackColor: Colors.greenAccent.withOpacity(0.5),
      valueIndicatorColor: Colors.grey.withOpacity(0.3),
      valueIndicatorTextStyle: TextStyle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.greenAccent),
      ),
    ),
  );
}
