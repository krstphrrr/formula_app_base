import 'package:formula_list/data/formula_list_repository.dart';

class FormulaListService {
  // FormulaListService() : super();
   final FormulaListRepository _repository;

  FormulaListService(this._repository);

  Future<List<Map<String, dynamic>>> fetchFormulas() async {
    return await _repository.fetchFormulas();
  }

  Future <void> deleteFormula(int formulaId) async {
    await _repository.deleteFormula(formulaId);
  }
}