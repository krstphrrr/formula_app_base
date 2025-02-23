// import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:formula_composer/features/formula_list/data/formula_list_repositiory.dart';
// import 'package:formula_composer/features/formula_list/domain/formula_list_service.dart';
// import 'package:formula_composer/features/formula_list/state/formula_list_provider.dart';
// import 'package:formula_composer/features/ingredient_list/data/ingredient_list_repository.dart';
// import 'package:formula_composer/features/ingredient_list/domain/ingredient_list_service.dart';
// import 'core/database/database_helper.dart';
// import 'core/providers/theme_provider.dart';
// import 'core/widgets/main_nav_bar.dart';
import 'package:core/core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For non-mobile platforms
import 'package:wakelock_plus/wakelock_plus.dart'; // Updated to wakelock_plus

import 'package:provider/provider.dart';
import 'package:settings_data/settings_data.dart';
// import 'features/formula_add/data/formula_add_repository.dart';
// import 'features/formula_add/domain/formula_add_service.dart';
// import 'features/formula_add/state/formula_add_provider.dart';
// import 'features/formula_ingredients/data/formula_ingredient_repository.dart';
// import 'features/formula_ingredients/domain/formula_ingredient_service.dart';
// import 'features/formula_ingredients/state/formula_ingredient_provider.dart';
// import 'features/formula_scaling/data/formula_scale_repository.dart';
// import 'features/formula_scaling/domain/formula_scale_service.dart';
// import 'features/formula_scaling/state/formula_scale_provider.dart';
// import 'features/ingredient_edit/data/ingredient_edit_repository.dart';
// import 'features/ingredient_edit/domain/ingredient_edit_service.dart';
// import 'features/ingredient_edit/state/ingredient_edit_provider.dart';
// import 'features/ingredient_list/state/ingredient_list_provider.dart';
// import 'features/ingredient_view/data/ingredient_view_repository.dart';
// import 'features/ingredient_view/domain/ingredient_view_service.dart';
// import 'features/ingredient_view/state/ingredient_view_provider.dart';
// import 'features/settings_categories_color/data/settings_category_repository.dart';
// import 'features/settings_categories_color/domain/settings_category_service.dart';
// import 'features/settings_categories_color/state/settings_category_provider.dart';
// import 'features/settings_data/data/settings_data_repository.dart';
// import 'features/settings_data/domain/settings_data_service.dart';
// import 'features/settings_data/state/settings_data_provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await windowManager.ensureInitialized();

//   // Set the window size to match Galaxy S25's screen resolution
//   windowManager.setAspectRatio(9 / 19.5);
//   runApp(const MainApp());
// }

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
  // final formulaListRepository = FormulaListRepository(database);
  // final formulaListService = FormulaListService(formulaListRepository);
  // final formulaListProvider = FormulaListProvider(formulaListService);

  // final formulaAddRepository = FormulaAddRepository(database);
  // final formulaAddService = FormulaAddService(formulaAddRepository);
  // final formulaAddProvider = FormulaAddProvider(formulaAddService);

  // final formulaIngredientRepository = FormulaIngredientRepository(database);
  // final formulaIngredientService = FormulaIngredientService(formulaIngredientRepository);
  // final formulaIngredientProvider = FormulaIngredientProvider(formulaIngredientService);

  // final ingredientListRepository = IngredientListRepository(database);
  // final ingredientListService = IngredientListService(ingredientListRepository);
  // final ingredientListProvider = IngredientListProvider(ingredientListService);

  // final ingredientEditRepository = IngredientEditRepository(database);
  // final ingredientEditService = IngredientEditService(ingredientEditRepository);
  // final ingredientEditProvider = IngredientEditProvider(ingredientEditService);

  final settingsDataRepository = SettingsDataRepository(database);
  final settingsDataService = SettingsDataService(settingsDataRepository);
  final settingsDataProvider = SettingsDataProvider(settingsDataService);

  // final settingsCategoryRepository = SettingsCategoryRepository(database);
  // final settingsCategoryService = SettingsCategoryService(settingsCategoryRepository);
  // final settingsCategoryProvider = SettingsCategoryProvider(settingsCategoryService);

  // final ingredientViewRepository = IngredientViewRepository(database);
  // final ingredientViewService = IngredientViewService(ingredientViewRepository);
  // final ingredientViewProvider = IngredientViewProvider(ingredientViewService);

  // final formulaScaleRepository = FormulaScaleRepository(database);
  // final formulaScaleService = FormulaScaleService(formulaScaleRepository);
  // final formulaScaleProvider = FormulaScaleProvider(formulaScaleService);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // ChangeNotifierProvider(create: (context) => formulaListProvider),
        // ChangeNotifierProvider(create: (context) => formulaAddProvider),
        // ChangeNotifierProvider(create: (context) => formulaIngredientProvider),
        // ChangeNotifierProvider(create: (context) => ingredientListProvider),
        // ChangeNotifierProvider(create: (context) => ingredientEditProvider),
        // ChangeNotifierProvider(create: (context) => ingredientViewProvider),
        // ChangeNotifierProvider(create: (context) => formulaScaleProvider),
        ChangeNotifierProvider(create: (context) => settingsDataProvider),
        // ChangeNotifierProvider(create: (context) => settingsCategoryProvider)
        // ChangeNotifierProvider(create: (context) => settingsProvider)
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