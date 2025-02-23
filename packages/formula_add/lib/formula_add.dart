library formula_add;

import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'data/formula_add_repository.dart';
import 'domain/formula_add_service.dart';
import 'state/formula_add_provider.dart';

export 'data/formula_add_repository.dart';
export 'domain/formula_add_service.dart';
export 'state/formula_add_provider.dart';
export 'presentation/formula_add_page.dart';

List<ChangeNotifierProvider<FormulaAddProvider>> loadFeatureProviders(Database db) {
  return [
    ChangeNotifierProvider<FormulaAddProvider>(
      create: (context) => FormulaAddProvider(
        FormulaAddService(FormulaAddRepository(db)),
      ),
    ),
  ];
}