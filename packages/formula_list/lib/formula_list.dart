library formula_list;

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:formula_list/state/formula_list_provider.dart';
import 'package:formula_list/domain/formula_list_service.dart';
import 'package:formula_list/data/formula_list_repository.dart';

export 'package:formula_list/data/formula_list_repository.dart';
export 'package:formula_list/domain/formula_list_service.dart';
export 'package:formula_list/state/formula_list_provider.dart';
export 'package:formula_list/presentation/formula_list_page.dart';


List<ChangeNotifierProvider<FormulaListProvider>> loadFeatureProviders(Database db) {
  debugPrint('✅ Registering FormulaListProvider...');

  return [
    ChangeNotifierProvider<FormulaListProvider>(
      create: (context) => FormulaListProvider(
        FormulaListService(FormulaListRepository(db)),
      ),
    ),
  ];
}