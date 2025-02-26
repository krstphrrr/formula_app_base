import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:formula_list/domain/formula_list_service.dart';

class FormulaListProvider extends ChangeNotifier {
  final FormulaListService _service;
  FormulaListProvider(this._service);

  // properties
   
  List<Map<String, dynamic>> _formulas = [];
  // List<Map<String, dynamic>> get formulas => _formulas;
  List<Map<String, dynamic>> _filteredFormulas = [];
  List<Map<String, dynamic>> get formulas => _filteredFormulas;
  bool get isLoading => _isLoading;
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;
  
  
   @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

    void clearControllers() {
    _searchController.clear();
     notifyListeners();
  }

  // methods

Future<void> fetchFormulas() async {
  if (_isLoading) return; 
  _isLoading = true;

  final newFormulas = await _service.fetchFormulas();

  if (!listEquals(_formulas, newFormulas)) { 
    _formulas = newFormulas;
    _filteredFormulas = List.from(newFormulas); 

    notifyListeners(); 
  }

  _isLoading = false;
}

  Future<void> deleteFormula(int id) async {

    await _service.deleteFormula(id);
    await fetchFormulas();
    clearControllers();
    notifyListeners();
  }

    void filterFormulas(String query) {
    if (query.isEmpty) {
      _filteredFormulas = List.from(_formulas);
    } else {
      _filteredFormulas = _formulas
          .where((formula) => formula['name']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}