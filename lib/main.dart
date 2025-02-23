import 'package:formula_list/formula_list.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';
import 'core/feature_loader.dart';

import 'package:formula_list/state/formula_list_provider.dart';
import 'package:formula_list/domain/formula_list_service.dart';
import 'package:formula_list/data/formula_list_repository.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  windowManager.setAspectRatio(9 / 19.5);

  // // If running on desktop or testing, use sqflite_common_ffi
  if (isDesktopPlatform()) {
    // Initialize FFI for desktop platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi; // Set the database factory for FFI
  }

  
  final database = await DatabaseHelper().database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ...FeatureLoader.loadProviders(database),  // Pass the database to FeatureLoader
      ],
      child: MainApp(),
    ),
  );
}

bool isDesktopPlatform() {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    WakelockPlus.enable();
    return MaterialApp(
      // home: Scaffold(
      //   body: Center(
      //     child: Text('Hello World!'),
      //   ),
      // ),
    debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: MainNavBar(),
    );
  }
}