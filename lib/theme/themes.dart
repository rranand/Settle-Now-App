import 'package:flutter/material.dart';
import 'package:settlenow_v2/constant/ui_constant.dart';

class CustomTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: UiConstant.cardElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.deepPurple),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionColor: Colors.deepPurple.withAlpha(77),
        selectionHandleColor: Colors.deepPurple.withAlpha(77),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.white),
      ).apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
        decorationColor: Colors.black87,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurpleAccent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.black54,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black87),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black87),
        ),
        labelStyle: TextStyle(color: Colors.black),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(4),
        thumbColor: WidgetStateProperty.all(Colors.deepPurpleAccent),
      ),
      sliderTheme: SliderThemeData(
        thumbColor: Colors.deepPurpleAccent,
        activeTrackColor: Colors.deepPurpleAccent.withAlpha(128),
        valueIndicatorColor: Colors.grey.withAlpha(77),
        valueIndicatorTextStyle: const TextStyle(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.deepPurple),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.deepPurpleAccent),
        trackColor: WidgetStateProperty.all(
          Colors.deepPurpleAccent.withAlpha(60),
        ),
      ),
      snackBarTheme: SnackBarThemeData(backgroundColor: Colors.black87),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.black87),
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
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.greenAccent,
      brightness: Brightness.dark,
    ),
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
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.black87,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.black38,
      elevation: UiConstant.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    drawerTheme: DrawerThemeData(),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.black54),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: Colors.greenAccent.withAlpha(70),
      selectionHandleColor: Colors.greenAccent.withAlpha(70),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.black),
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
      decorationColor: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.greenAccent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: Colors.greenAccent,
      unselectedItemColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusColor: Colors.greenAccent,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.greenAccent),
      ),
      outlineBorder: BorderSide(color: Colors.greenAccent),
      labelStyle: TextStyle(color: Colors.white),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStateProperty.all(4),
      thumbColor: WidgetStateProperty.all(Color.fromARGB(255, 105, 240, 174)),
    ),
    sliderTheme: SliderThemeData(
      thumbColor: Colors.greenAccent,
      activeTrackColor: Colors.greenAccent.withValues(alpha: 0.5),
      valueIndicatorColor: Colors.grey.withValues(alpha: 0.3),
      valueIndicatorTextStyle: TextStyle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.greenAccent),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.greenAccent),
      trackColor: WidgetStateProperty.all(Colors.greenAccent.withAlpha(60)),
    ),
    snackBarTheme: SnackBarThemeData(backgroundColor: Colors.black38),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all(TextStyle(color: Colors.white)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.greenAccent,
    ),
  );
}
