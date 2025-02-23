library formula_list;

import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'state/formula_list_provider.dart';
import 'domain/formula_list_service.dart';
import 'data/formula_list_repositiory.dart';

export 'data/formula_list_repositiory.dart';
export 'domain/formula_list_service.dart';
export 'state/formula_list_provider.dart';
export 'presentation/formula_list_page.dart';

List<ChangeNotifierProvider> loadFeatureProviders(Database db) {
  return [
    ChangeNotifierProvider(
      create: (context) => FormulaListProvider(
        FormulaListService(FormulaListRepository(db)),
      ),
    ),
  ];
}