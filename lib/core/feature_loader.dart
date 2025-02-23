import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:formula_list/formula_list.dart' as formula_list;
import 'package:formula_add/formula_add.dart' as formula_add;
import 'package:settings_data/settings_data.dart' as settings_data;

typedef FeatureLoaderFunction = List<ChangeNotifierProvider> Function(Database db);

class FeatureLoader {
  static final List<FeatureLoaderFunction> _featureLoaders = [
    formula_list.loadFeatureProviders,
    formula_add.loadFeatureProviders,
    settings_data.loadFeatureProviders,
  ];

  static List<ChangeNotifierProvider> loadProviders(Database db) {
    return _featureLoaders.expand((loader) => loader(db)).toList();
  }
}