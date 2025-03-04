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
  // notifyListeners();
}


// Future<void> fetchFormulas() async {
//   if (_isLoading) return; // Prevent infinite loop

//   _isLoading = true;
//   notifyListeners(); // Notify UI that loading has started

//   bool _isFetching = true; // NEW local variable to control fetch timing

//   try {
//     final newFormulas = await _service.fetchFormulas();

//     if (!listEquals(_formulas, newFormulas)) {
//       _formulas = newFormulas;
//       _filteredFormulas = List.from(newFormulas);
//       notifyListeners(); // Only notify when there's a change
//     }
//   } catch (e) {
//     print("ERROR: Failed to fetch formulas - $e");
//   } finally {
//     _isFetching = false; // Prevent further calls
//     _isLoading = false;
    
//     if (!_isFetching) {
//       notifyListeners(); // Notify UI that loading has ended
//     }
//   }
// }


Future<void> deleteFormula(int id, String type) async {
  if (type == 'category_0') {
    print("DEBUG: Deleting an Accord Formula with ID: $id");
    await _service.deleteAccord(id); // Calls service to delete accord and related ingredients
  } else {
    print("DEBUG: Deleting a Regular Formula with ID: $id");
    await _service.deleteFormula(id);
  }
  
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