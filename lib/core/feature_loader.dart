import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:formula_list/formula_list.dart';
import 'package:formula_add/formula_add.dart';
import 'package:settings_data/settings_data.dart';

class FeatureLoader {
  static List<ChangeNotifierProvider> loadProviders(Database db) {
    return [
      ChangeNotifierProvider(
        create: (context) => FormulaListProvider(
          FormulaListService(FormulaListRepository(db)),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => FormulaAddProvider(
          FormulaAddService(FormulaAddRepository(db)),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => SettingsDataProvider(
          SettingsDataService(SettingsDataRepository(db)),
        ),
      ),
    ];
  }
}