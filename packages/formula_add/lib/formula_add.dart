library formula_add;

import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:formula_add/data/formula_add_repository.dart';
import 'package:formula_add/domain/formula_add_service.dart';
import 'package:formula_add/state/formula_add_provider.dart';

export 'package:formula_add/data/formula_add_repository.dart';
export 'package:formula_add/domain/formula_add_service.dart';
export 'package:formula_add/state/formula_add_provider.dart';
export 'package:formula_add/presentation/formula_add_page.dart';

List<ChangeNotifierProvider<FormulaAddProvider>> loadFeatureProviders(Database db) {
  return [
    ChangeNotifierProvider<FormulaAddProvider>(
      create: (context) => FormulaAddProvider(
        FormulaAddService(FormulaAddRepository(db)),
      ),
    ),
  ];
}