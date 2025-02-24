library formula_ingredient;

import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:formula_ingredient/state/formula_ingredient_provider.dart';
import 'package:formula_ingredient/domain/formula_ingredient_service.dart';
import 'package:formula_ingredient/data/formula_ingredient_repository.dart';

export 'package:formula_ingredient/data/formula_ingredient_repository.dart';
export 'package:formula_ingredient/domain/formula_ingredient_service.dart';
export 'package:formula_ingredient/state/formula_ingredient_provider.dart';
export 'package:formula_ingredient/presentation/formula_ingredient_page.dart';

List<ChangeNotifierProvider<FormulaIngredientProvider>> loadFeatureProviders(Database db) {
  return [
    ChangeNotifierProvider<FormulaIngredientProvider>(
      create: (context) => FormulaIngredientProvider(
        FormulaIngredientService(FormulaIngredientRepository(db)),
      ),
    ),
  ];
}