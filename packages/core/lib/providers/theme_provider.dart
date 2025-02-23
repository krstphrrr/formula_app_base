import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  // Getter to expose the current theme state
  bool get isDarkMode => _isDarkMode;

  // Method to toggle the theme
  void toggleTheme() {
    print(_isDarkMode);
    _isDarkMode = !_isDarkMode;
    notifyListeners();  // Notify listeners to rebuild UI
  }

  // // Get the current theme based on the dark mode state
  // ThemeData get currentTheme {
  //   return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  // }

  ThemeData get lightTheme {
    return ThemeData(
      // brightness: Brightness.light,
      // primarySwatch: Colors.blue,
      scaffoldBackgroundColor:  Colors.grey[300],
      appBarTheme: AppBarTheme(
        backgroundColor:  Colors.grey[300], // Light mode AppBar color
        // foregroundColor: Colors.grey[300], // Text and icon color in light mode
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black), // Light mode body text color
        bodyMedium: TextStyle(color: Colors.black), // Light mode secondary text color
        titleLarge: TextStyle(color: Colors.blueGrey), // Light mode headline text color
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[300], // Background color of the bottom nav bar
        selectedItemColor: Colors.black, // Color of selected item
        unselectedItemColor: Colors.grey, // Color of unselected items
        selectedIconTheme: IconThemeData(size: 30), // Size of selected icon
        unselectedIconTheme: IconThemeData(size: 25), // Size of unselected icon
        elevation: 8, // Elevation of the bottom nav bar
      ),
    );
  }

  // Define the dark theme
  ThemeData get darkTheme {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212), // Dark background for app
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF333333), // Dark AppBar color
      foregroundColor: Colors.white, // White text and icons for contrast
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white), // Main body text in white
      bodyMedium: TextStyle(color: Colors.grey), // Secondary text in gray
      titleLarge: TextStyle(color: Colors.white), // Headline text in white
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBB86FC), // Accent color for buttons
        foregroundColor: Colors.black, // Black text on light button background
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF333333), // Dark background color for the bottom nav bar
        selectedItemColor: const Color(0xFFBB86FC), // Color of selected item in dark mode
        unselectedItemColor: Colors.grey, // Color of unselected items in dark mode
        selectedIconTheme: IconThemeData(size: 30), // Size of selected icon
        unselectedIconTheme: IconThemeData(size: 25), // Size of unselected icon
        elevation: 8, // Elevation of the bottom nav bar
      ),
  );
}

  // This getter returns the current theme based on isDarkMode
  ThemeData get currentTheme {
    return _isDarkMode ? darkTheme : lightTheme;
  }
}