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

  Future<void> deleteAccord(int accordId) async {
  print("DEBUG: Removing Accord with ID: $accordId");

  await _repository.deleteAccordIngredients(accordId); // Remove ingredients linked to accord
  await _repository.deleteAccord(accordId); // Remove the accord itself
  await _repository.deleteFormula(accordId); // Remove the formula entry

  print("SUCCESS: Accord and its associated data removed.");
}


}