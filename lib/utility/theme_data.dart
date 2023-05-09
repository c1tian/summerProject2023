import 'package:flutter/material.dart';

ThemeData lightTheme() {
  return ThemeData(
    primaryColor: Colors.white,
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.blue,
      textTheme: ButtonTextTheme.primary,
    ),
    appBarTheme: const AppBarTheme(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 27, fontWeight: FontWeight.bold)),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.blueAccent,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      displayMedium: TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: Colors.blueAccent, brightness: Brightness.light),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: Colors.white,
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hourMinuteTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      dialHandColor: Colors.blue,
      dialBackgroundColor: Colors.white,
      dayPeriodShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      dayPeriodTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      dayPeriodColor: Colors.blue,
      dayPeriodBorderSide: const BorderSide(color: Colors.blue),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    primaryColor: const Color(0xFF121212),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.orange,
      textTheme: ButtonTextTheme.primary,
    ),
    appBarTheme: const AppBarTheme(
        foregroundColor: Colors.orange,
        backgroundColor: Color(0xFF121212),
        titleTextStyle: TextStyle(
            color: Colors.orange, fontSize: 27, fontWeight: FontWeight.bold)),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF121212),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.orange,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      displayMedium: TextStyle(color: Colors.white, fontSize: 14),
    ),
    iconTheme: const IconThemeData(
      color: Colors.orange,
    ),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: Colors.orange, brightness: Brightness.dark),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.orange,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.orange,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: const Color(0xFF121212),
      dialHandColor: Colors.black,
      dialBackgroundColor: Colors.orange,
      dayPeriodColor: Colors.black,
      dayPeriodTextColor: Colors.black,
      dayPeriodShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      dayPeriodTextStyle: const TextStyle(
        color: Colors.orange,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      hourMinuteColor: Colors.orange,
      hourMinuteTextColor: Colors.black,
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hourMinuteTextStyle: const TextStyle(
        color: Colors.orange,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      helpTextStyle: const TextStyle(
        color: Colors.orange,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      entryModeIconColor: Colors.orange,
    ),
  );
}