library formula_scale;

import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:formula_scale/state/formula_scale_provider.dart';
import 'package:formula_scale/domain/formula_scale_service.dart';
import 'package:formula_scale/data/formula_scale_repository.dart';

export 'package:formula_scale/data/formula_scale_repository.dart';
export 'package:formula_scale/domain/formula_scale_service.dart';
export 'package:formula_scale/state/formula_scale_provider.dart';
export 'package:formula_scale/presentation/formula_scale_page.dart';

List<ChangeNotifierProvider<FormulaScaleProvider>> loadFeatureProviders(Database db) {
  return [
    ChangeNotifierProvider<FormulaScaleProvider>(
      create: (context) => FormulaScaleProvider(
        FormulaScaleService(FormulaScaleRepository(db)),
      ),
    ),
  ];
}