import 'package:flutter/material.dart';
import 'package:formula_ingredient/domain/formula_ingredient_service.dart';
import 'package:provider/provider.dart';

import 'package:formula_list/formula_list.dart';

class FormulaIngredientProvider extends ChangeNotifier {
  final FormulaIngredientService _service;
  FormulaIngredientProvider(this._service){
  
  }
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Map<String, dynamic>? _currentFormula;
  Map<String, dynamic>? get currentFormula => _currentFormula;

   String _formulaDisplayName = '';
  String get formulaDisplayName => _formulaDisplayName;
  
  int? _currentFormulaId = 1;
  int? get currentFormulaId => _currentFormulaId;

   List<Map<String, dynamic>> _availableIngredients = []; // List of all available ingredients
   List<Map<String, dynamic>> get availableIngredients => _availableIngredients; 

  List<Map<String, dynamic>> _filteredIngredients = []; // Filtered ingredients for the search
  List<Map<String, dynamic>> get filteredIngredients => _filteredIngredients;

  List<Map<String, dynamic>> _formulaIngredients = []; // Ingredients in the current formula
  List<Map<String, dynamic>> get formulaIngredients => _formulaIngredients;

  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;

  List<TextEditingController> _amountControllers = [];
  List<TextEditingController> get amountControllers => _amountControllers;

  List<TextEditingController> _dilutionControllers = [];
  List<TextEditingController> get dilutionControllers => _dilutionControllers;

  double _totalAmount = 0.0;
  double get totalAmount => _totalAmount;

  List<FocusNode> _amountFocusNodes = [];
  List<FocusNode> get amountFocusNodes =>  _amountFocusNodes;
  List<FocusNode> _dilutionFocusNodes = [];
  List<FocusNode> get dilutionFocusNodes => _dilutionFocusNodes;
  Map<String, dynamic>? _ifraFormula;

  int _targetTotalAmount = 15; // Default value
  bool _isTargetTotalEnabled = true;

  int get targetTotalAmount => _targetTotalAmount;
  bool get isTargetTotalEnabled => _isTargetTotalEnabled;

  bool _isRatioInput = false;
bool get isRatioInput => _isRatioInput;

List<TextEditingController> _ratioControllers = [];
List<TextEditingController> get ratioControllers => _ratioControllers;

double _totalRatioAmount = 0.0;
double get totalRatioAmount => _totalRatioAmount;

List<FocusNode> _ratioFocusNodes = [];
List<FocusNode> get ratioFocusNodes => _ratioFocusNodes;

bool _isInputModeLocked = false;
bool get isInputModeLocked => _isInputModeLocked;

String _selectedSortOption = 'Add Order';
String get selectedSortOption => _selectedSortOption;

bool _isReverseSort = false;
bool get isReverseSort => _isReverseSort;

List<Map<String, dynamic>> _availableAccords = [];
List<Map<String, dynamic>> get availableAccords => _availableAccords;

List<Map<String, dynamic>> _filteredAccords = [];
List<Map<String, dynamic>> get filteredAccords => _filteredAccords;


bool _isAccordFormula = false;
bool get isAccordFormula => _isAccordFormula;

Future<void> setFormula(Map<String, dynamic> formula) async {
  _currentFormulaId = formula['id'];
  _formulaDisplayName = formula['name'];
  _currentFormula = formula;

  // Determine if the formula is an accord
  _isAccordFormula = (formula['type'] == 'Accord');

  notifyListeners();

  // Fetch data
  await fetchFormulaIngredients(formula['id']);
  await fetchAvailableIngredients();
  await fetchAvailableAccords();
  calculateTotalAmount();

  if (_isTargetTotalEnabled) {
    await checkIfraCompliance();
  }
}
   set currentFormulaId(int? value) {
    // if (_currentFormula!['formula_id'] != null) {
    _currentFormulaId = value;
    notifyListeners();
    // }
  }
    set formulaDisplayName(String? value){
    _formulaDisplayName = value!;
    notifyListeners();
  }

@override
void dispose() {
  _searchController.dispose();
  _amountControllers.forEach((controller) => controller.dispose());
  _dilutionControllers.forEach((controller) => controller.dispose());
  _amountFocusNodes.forEach((focusNode) => focusNode.dispose());
  _dilutionFocusNodes.forEach((focusNode) => focusNode.dispose());
  _ratioControllers.forEach((controller) => controller.dispose());
  _ratioFocusNodes.forEach((focusNode) => focusNode.dispose());
  super.dispose();
}

    void clearControllers() {
    _searchController.clear();

     notifyListeners();
  }
    void setTargetTotalAmount(int value) {
    _targetTotalAmount = value;
    notifyListeners();
  }

  Future<void> fetchAvailableAccords() async {
  _availableAccords = await _service.fetchAvailableAccords();
  print("DEBUG: Available Accords Loaded: $_availableAccords");
  notifyListeners();
}

Future<void> saveFormulaIngredients() async {
  if (_currentFormulaId == null) {
    print("ERROR: No formula ID found, cannot save.");
    return;
  }

  print("DEBUG: Saving Formula Ingredients for Formula ID: $_currentFormulaId");

  for (var ingredient in _formulaIngredients) {
    final ingredientId = ingredient['ingredient_id'];
    final amount = ingredient['amount'];
    final dilution = ingredient['dilution'];
    final ratio = ingredient['ratio'] ?? 0.0; // Default ratio to 0.0 if null

    print("DEBUG: Preparing to save ingredient ID: $ingredientId | Amount: $amount | Dilution: $dilution | Ratio: $ratio");

    try {
      if (_isAccordFormula) {
        print("DEBUG: Saving as an Accord Formula.");
        await _service.addAccordIngredient(
          _currentFormulaId!,
          ingredientId,
          ratio, // Save the ratio instead of amount
        );
      } else {
        await _service.addFormulaIngredient(
          _currentFormulaId!,
          ingredientId,
          amount,
          dilution,
        );
      }
      print("SUCCESS: Ingredient $ingredientId saved successfully.");
    } catch (e) {
      print("ERROR: Failed to save ingredient $ingredientId - $e");
    }
  }
}



void addAccordToFormula(int accordId, double accordAmount) async {
  final accordIngredients = await _service.fetchAccordIngredients(accordId);
    print("DEBUG: Adding Accord ID: $accordId to Formula ID: $_currentFormulaId");


  // Get total weight of the accord
  final double totalAccordWeight = accordIngredients.fold(0.0, (sum, item) => sum + item['ratio']);

   if (totalAccordWeight == 0) {
    print("DEBUG: Skipping Accord Addition (Total Weight is 0)");
    return;
  }

  // Add the accord itself as a row
  _formulaIngredients.add({
    'ingredient_id': accordId,
    'amount': accordAmount,
    'dilution': 1.0,
    'name': "Accord - ${accordIngredients.first['name']}",
    'is_accord': true,
  });

  _amountControllers.add(TextEditingController(text: accordAmount.toString()));
  _dilutionControllers.add(TextEditingController(text: "1.0"));

  // Add accord ingredients, adjusting for the new accord amount
  for (var ingredient in accordIngredients) {
    double ingredientAmount = (ingredient['ratio'] / totalAccordWeight) * accordAmount;

    _formulaIngredients.add({
      'ingredient_id': ingredient['ingredient_id'],
      'amount': ingredientAmount,
      'dilution': 1.0,
      'name': ingredient['name'],
      'is_accord_ingredient': true,
      'parent_accord_id': accordId,
    });

        print("DEBUG: Accord Ingredient Added - ${ingredient['name']} | Calculated Amount: $ingredientAmount");


    _amountControllers.add(TextEditingController(text: ingredientAmount.toString()));
  }

  notifyListeners();
}


void filterAvailableAccords(String query) {
  if (query.isEmpty) {
    _filteredAccords = List.from(_availableAccords);
  } else {
    _filteredAccords = _availableAccords.where((accord) {
      final name = accord['name']?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();
  }
  notifyListeners();
}

// void addAccordToFormula(int accordId, double accordAmount) async {
//   final accordIngredients = await _service.fetchAccordIngredients(accordId);

//   // Ensure total weight is correct
//   final double totalAccordWeight = accordIngredients.fold(0.0, (sum, item) => sum + item['amount']);

//   if (totalAccordWeight == 0) return;

//   // Add the accord as a single row
//   _formulaIngredients.add({
//     'ingredient_id': accordId,
//     'amount': accordAmount,
//     'dilution': 1.0,
//     'name': "Accord - ${accordIngredients.first['accord_name']}",
//     'is_accord': true,
//   });

//   _amountControllers.add(TextEditingController(text: accordAmount.toString()));
//   _dilutionControllers.add(TextEditingController(text: "1.0"));

//   // Add individual ingredients from the accord
//   for (var ingredient in accordIngredients) {
//     double ingredientAmount = (ingredient['amount'] / totalAccordWeight) * accordAmount;

//     _formulaIngredients.add({
//       'ingredient_id': ingredient['ingredient_id'],
//       'amount': ingredientAmount,
//       'dilution': 1.0,
//       'name': ingredient['name'],
//       'is_accord_ingredient': true, // Mark it as part of an accord
//       'parent_accord_id': accordId,
//     });

//     _amountControllers.add(TextEditingController(text: ingredientAmount.toString()));
//   }

//   notifyListeners();
// }


  void toggleTargetTotalEnabled(bool isEnabled) async {
    _isTargetTotalEnabled = isEnabled;

    print("TOGGLED: ${_isTargetTotalEnabled}");
    print("TARGET TOTAL: ${_targetTotalAmount}");
    notifyListeners();
     if (_isTargetTotalEnabled) {
    await checkIfraCompliance();
  }
  }

void _initializeFocusNodes(int index) {
  FocusNode amountFocusNode = FocusNode();
  FocusNode dilutionFocusNode = FocusNode();
  FocusNode ratioFocusNode = FocusNode();

  amountFocusNode.addListener(() {
    if (!amountFocusNode.hasFocus) {
      double amount = double.tryParse(_amountControllers[index].text) ?? 0.0;
      updateIngredientInFormula(
        index,
        _formulaIngredients[index]['ingredient_id'],
        amount,
        _formulaIngredients[index]['dilution'],
      );
      print("CHANGED AMOUNT");
    }
  });

  dilutionFocusNode.addListener(() {
    if (!dilutionFocusNode.hasFocus) {
      double dilution = double.tryParse(_dilutionControllers[index].text) ?? 1.0;
      updateIngredientInFormula(
        index,
        _formulaIngredients[index]['ingredient_id'],
        _formulaIngredients[index]['amount'],
        dilution,
      );
      print("CHANGE DILUTION");
    }
  });

    // Listener for ratio focus change
    ratioFocusNode.addListener(() {
      if (!ratioFocusNode.hasFocus) {
        double ratio = double.tryParse(_ratioControllers[index].text) ?? 0.0;
        updateIngredientInFormula(
          index,
          _formulaIngredients[index]['ingredient_id'],
          ratio,
          _formulaIngredients[index]['dilution'],
        );
        print("CHANGED RATIO");
        calculateTotalAmount();
      }
    });

  _amountFocusNodes.add(amountFocusNode);
  _dilutionFocusNodes.add(dilutionFocusNode);
  _ratioFocusNodes.add(ratioFocusNode);
}

clearState(){
  // Clear existing state
  _formulaIngredients.clear();
  _amountControllers.forEach((controller) => controller.dispose());
  _dilutionControllers.forEach((controller) => controller.dispose());
   _ratioControllers.forEach((controller) => controller.dispose());
  _amountControllers.clear();
  _dilutionControllers.clear();
  _amountFocusNodes.forEach((focusNode) => focusNode.dispose());
  _dilutionFocusNodes.forEach((focusNode) => focusNode.dispose());
   _ratioFocusNodes.forEach((focusNode) => focusNode.dispose());
  _amountFocusNodes.clear();
  _dilutionFocusNodes.clear();
  _ratioControllers.clear();
  _ratioFocusNodes.clear();
  _totalAmount = 0.0;
  _totalRatioAmount = 0.0;

  _ratioControllers.forEach((controller) => controller.dispose());
_ratioControllers.clear();
}

// Future<void> setFormula(Map<String, dynamic> formula) async {
//   _currentFormulaId = formula['id'];
//   _formulaDisplayName = formula['name'];
//   _currentFormula = formula;
//   print("FORMULA: $_currentFormula");	

//   notifyListeners();

//   // Fetch related data after setting the current formula
//   await fetchFormulaIngredients(formula['id']);
//   await fetchAvailableIngredients();
//   calculateTotalAmount();

//   if (_isTargetTotalEnabled) {
//     await checkIfraCompliance();
//   }
// }

Future<void> fetchFormulaIngredients(int formulaId) async {
  clearState();
  print("DEBUG: Fetching formula ingredients for formula ID: $formulaId");

  List<Map<String, dynamic>> ingredients;

  // ✅ Ensure `_isAccordFormula` is set before fetching ingredients
  // if (_currentFormula == null) {
    print("DEBUG: Fetching formula details to determine formula type.");
    await fetchFormula(formulaId);
  // }

  if (_isAccordFormula) {
    print("DEBUG: Pulling ingredients from accord_ingredients (Accord Formula)");
    _formulaIngredients = await _service.fetchAccordIngredients(formulaId);
  } else {
    print("DEBUG: Pulling ingredients from formula_ingredient (Regular Formula)");
    _formulaIngredients = await _service.fetchFormulaIngredients(formulaId);
  }

  // Fetch ingredients from the service
   ingredients = await _service.fetchFormulaIngredients(formulaId);
  // _formulaIngredients = ingredients.map((ingredient) => Map<String, dynamic>.from(ingredient)).toList();
   _formulaIngredients = await Future.wait(ingredients.map((ingredient) async {
    print("INGREDIENT: $ingredient");
    final category = ingredient['category'] ?? 'Unknown';
    print("CATEGORY: $category");

    // Await the asynchronous call to get the category color
    final hexColor = await _service.getCategoryColor(category);
    print("HEX COLOR: $hexColor");

    // Parse the hex string into a `Color` object, defaulting to light gray if null or invalid
   final categoryColor = (hexColor != null && hexColor.isNotEmpty)
    ? Color(int.tryParse(hexColor.replaceFirst('#', '0xFF')) ?? 0xFFCCCCCC)
    : const Color(0xFFCCCCCC);

    return {
      ...ingredient,
      'categoryColor': categoryColor,
    };
  }).toList());

  print("FORMULA INGREDIENTS: $_formulaIngredients");
_formulaIngredients = []; // Clear before adding new data
  _amountControllers.clear();
  _dilutionControllers.clear();
  _ratioControllers.clear();

  for (var ingredient in ingredients) {
    final mutableIngredient = Map<String, dynamic>.from(ingredient); // ✅ Ensure it’s mutable

    if (_formulaIngredients.any((existing) => existing['ingredient_id'] == mutableIngredient['ingredient_id'])) {
      print("WARNING: Duplicate ingredient detected, skipping: ${mutableIngredient['name']}");
      continue;
    }

    _formulaIngredients.add(mutableIngredient);
    _amountControllers.add(TextEditingController(text: mutableIngredient['amount']?.toString() ?? '0.0'));
    _dilutionControllers.add(TextEditingController(text: mutableIngredient['dilution']?.toString() ?? '1.0'));
    _ratioControllers.add(TextEditingController(text: mutableIngredient['ratio']?.toString() ?? '0.0'));
  }

  print("DEBUG: Loaded ${_formulaIngredients.length} ingredients into formula.");

  // Check if there are any ingredients
  if (_formulaIngredients.isNotEmpty) {
    // Lock the input mode since there is already an ingredient
    _isInputModeLocked = true;
  } else {
    _isInputModeLocked = false;
  }

  // Fetch the current formula details to check for ratio input mode
  _currentFormula = await _service.fetchFormulaForIFRA(formulaId);
  if (_currentFormula != null) {
    // Set the input mode based on the saved formula
    _isRatioInput = _currentFormula!['is_ratio_formula'] == 1;

    // If the formula was saved with ratio input, lock the input mode toggle
    if (_isRatioInput && _formulaIngredients.length>0) {
      _isInputModeLocked = true;
    }else{
      _isInputModeLocked = false;
    }
  }

  // Initialize controllers based on the input mode
  _amountControllers = _formulaIngredients.map((ingredient) {
    return _isRatioInput
        ? TextEditingController(text: ingredient['ratio']?.toString() ?? '0.0')
        : TextEditingController(text: ingredient['amount']?.toString() ?? '0.0');
  }).toList();

  _dilutionControllers = _formulaIngredients.map((ingredient) {
    return TextEditingController(text: ingredient['dilution'].toString());
  }).toList();

  _ratioControllers = _formulaIngredients.map((ingredient) {
    return TextEditingController(text: ingredient['ratio']?.toString() ?? '0.0');
  }).toList();

  // Initialize focus nodes
  for (int i = 0; i < _formulaIngredients.length; i++) {
    _initializeFocusNodes(i);
  }

  // Calculate the total amount or ratio based on the input mode
  calculateTotalAmount();
  checkIfraCompliance();
  notifyListeners();
}

bool isIngredientCompliant(int index) {
  if (!_isTargetTotalEnabled) return true; // Always compliant if IFRA check is disabled
  return !(_formulaIngredients[index]['is_exceeding_limit'] ?? false);
}


  Future<void> checkIfraCompliance() async {
  // Only perform compliance check if target total is enabled
  if (!_isTargetTotalEnabled) return; 
  // ALSO RETURN IF CATEGORY_0

  _ifraFormula = await _service.fetchFormulaForIFRA(_currentFormulaId!);
  // print("INSIDE IFRA: $_ifraFormula");
  final String? selectedCategory = _ifraFormula!['type'];
  // print("category: $selectedCategory");

  if (selectedCategory == null || selectedCategory.isEmpty) {
    return; // No category selected, nothing to check
  }

  double totalVolumeWithSolvent;

  if (_isRatioInput) {
    // In ratio mode, use the total ratio amount to determine the volume
    totalVolumeWithSolvent = _totalRatioAmount / (_targetTotalAmount / 100);
  } else {
    // In amount mode, use the total amount
    totalVolumeWithSolvent = _totalAmount / (_targetTotalAmount / 100);
  }

  // Fetch the IFRA standards based on the selected category
  final List<Map<String, dynamic>> ifraStandards = await _service.fetchIfraStandards(selectedCategory);

  for (var ingredient in _formulaIngredients) {
    final int ingredientId = ingredient['ingredient_id'];
    print("Ingredientsss: $ingredient");

    // Query CAS numbers for the ingredient
    final List<String> casNumbers = await _service.fetchCasNumbers(ingredientId);

    // Calculate the relative percentage of the ingredient
    double relativeAmount;
    if (_isRatioInput) {
      double ratio = ingredient['ratio'] ?? 0.0;
      relativeAmount = (ratio / _totalRatioAmount) * 100;
    } else {
      double amount = ingredient['amount'] ?? 0.0;
      double dilution = ingredient['dilution'] ?? 1.0;
      relativeAmount = (amount * dilution / totalVolumeWithSolvent) * 100;
    }

    // Check if the ingredient exceeds IFRA standards
    for (var ifraStandard in ifraStandards) {
      List<String> ifraCasNumbers = ifraStandard['cas_numbers'].split(RegExp(r'[\s\n]+'));

      for (String casNumber in casNumbers) {
        if (ifraCasNumbers.contains(casNumber.trim())) {
          // print("Matched CAS Number: $casNumber");
          final double allowedLimit = double.tryParse(ifraStandard[selectedCategory]) ?? double.infinity;

          print("Ingredient Relative Amount: $relativeAmount%");
          print("Allowed Limit: $allowedLimit%");

          if (relativeAmount > allowedLimit) {
            print("Ingredient exceeds IFRA limit");
            ingredient['is_exceeding_limit'] = true;
          } else {
            ingredient['is_exceeding_limit'] = false;
          }
        }
      }
    }
  }

  notifyListeners(); // Update the UI after checking compliance
}



//    // Fetch available ingredients
  Future<void> fetchAvailableIngredients() async {
    _availableIngredients =
        List.from(await _service.fetchAvailableIngredients());
    _filteredIngredients = _availableIngredients;
    notifyListeners();
  }

void filterAvailableIngredients(String query) {
  print("Filtering ingredients with query: '$query'");

  if (query.isEmpty) {
    print("Query is empty, showing all ingredients.");
    _filteredIngredients = List.from(_availableIngredients);
    notifyListeners();
    return;
  }

  final keywords = query.toLowerCase().split(' ');

  _filteredIngredients = _availableIngredients.where((ingredient) {
    final commonName = ingredient['name']?.toLowerCase() ?? '';
    final category = ingredient['category']?.toLowerCase() ?? '';
    final synonyms = ingredient['synonyms']?.toLowerCase() ?? ''; 
    // final casNumbers = ingredient['cas_numbers']?.toLowerCase() ?? ''; 

    final matches = keywords.every((keyword) {
      return commonName.contains(keyword) ||
             category.contains(keyword) ||
             synonyms.contains(keyword);
            //  casNumbers.contains(keyword);
    });

    if (matches) {
      print("MATCH: ${ingredient['name']} | Synonyms: $synonyms");
    }

    return matches;
  }).toList();

  print("Filtered ingredients count: ${_filteredIngredients.length}");
  notifyListeners();
}


Future<void> addIngredientToFormula(int ingredientId) async {
  // Find the formula ingredient row by ingredient ID
  final rowIndex = _formulaIngredients.indexWhere(
    (ingredient) => ingredient['ingredient_id'] == ingredientId,
  );

  if (rowIndex == -1) return; // Exit if ingredient not found

  // Update the formula ingredients table in the database
  await _service.addFormulaIngredient(
    _currentFormulaId!,
    ingredientId,
    double.tryParse(_amountControllers[rowIndex].text) ?? 0.0,
    double.tryParse(_dilutionControllers[rowIndex].text) ?? 1.0,
  );

  if (_formulaIngredients.isNotEmpty) {
    _isInputModeLocked = true;
  }
  _searchController.clear();


  notifyListeners();
  await checkIfraCompliance();
}

void addIngredientRow(BuildContext context, int ingredientId, {bool isAccord = false}) async {
  // Check if the ingredient already exists
  final existingIndex = _formulaIngredients.indexWhere((ingredient) => 
    ingredient['ingredient_id'] == ingredientId && ingredient['is_accord'] == false
  );

  // Prevent duplicate non-accord ingredients
  if (existingIndex != -1 && !isAccord) {
    print("Ingredient already exists in formula!");
    return;
  }

  final selectedIngredient = _availableIngredients.firstWhere(
    (ingredient) => ingredient['id'] == ingredientId,
    orElse: () => {},
  );

  if (selectedIngredient.isEmpty) return;

  final List<Map<String, dynamic>> mutableIngredientList = List.from(_formulaIngredients);

  mutableIngredientList.add({
    'ingredient_id': selectedIngredient['id'],
    'amount': 0.0,
    'dilution': 1.0,
    'name': selectedIngredient['name'],
    'ratio': 0.0,
    'is_accord': isAccord, // Track if it's an accord
  });

  _formulaIngredients = mutableIngredientList;
  
  // Add controllers
  _amountControllers.add(TextEditingController(text: '0.0'));
  _dilutionControllers.add(TextEditingController(text: '1.0'));
  _ratioControllers.add(TextEditingController(text: '0.0'));

  _initializeFocusNodes(_formulaIngredients.length - 1);

  notifyListeners();

  // **AUTO-SAVE IMMEDIATELY AFTER ADDING**
  print("DEBUG: Auto-saving after ingredient addition");
  await saveFormulaIngredients();
}

  void removeIngredient(int index) async {
    final ingredient = _formulaIngredients[index];
    final isAccord = ingredient['is_accord'] ?? false;

    if (isAccord) {
      print("DEBUG: Removing an Accord - ${ingredient['name']}");
    } else {
      print("DEBUG: Removing an Ingredient - ${ingredient['name']}");
    }
    // print("PRE REM: ${_formulaIngredients}");
    // int ingredientId = _formulaIngredients[index]['id'];
    // await _service.removeIngredientFromFormula(ingredientId);
    await _service.deleteFormulaIngredient(
        _currentFormulaId!, _formulaIngredients[index]['ingredient_id']);
    
    _formulaIngredients.removeAt(index);
    _amountControllers.removeAt(index);
    _dilutionControllers.removeAt(index);
    _amountFocusNodes.removeAt(index).dispose();  // Dispose of the FocusNode properly
    _dilutionFocusNodes.removeAt(index).dispose();  // Dispose of the FocusNode properly
    //  print("POST REM: ${_formulaIngredients}");
    //  final ingredient = _formulaIngredients[index];
    if(_formulaIngredients.length<1){
      _isInputModeLocked = false;
    }

     
    
    // notifyListeners();
    notifyListeners();
  }

    // Delete a formula ingredient
  Future<void> deleteFormulaIngredient(int formulaId, int ingredientId) async {
    await _service.deleteFormulaIngredient(
        formulaId, ingredientId);
    await fetchFormulaIngredients(formulaId); // Refresh the list after deleting
  }

  void updateIngredientInFormula(
    int index, 
    int ingredientId, 
    double amount, 
    double dilution) async {
      print("updating from provider: ${amount}");

    if (_isRatioInput) {
    _formulaIngredients[index]['ratio'] = amount;
  } else {
    _formulaIngredients[index]['amount'] = amount;
  }
    _formulaIngredients[index]['dilution'] = dilution;

      if (_isRatioInput) {
    await _service.updateIngredientInFormulaRatio(_currentFormulaId!, ingredientId, amount, dilution);
  } else {
    await _service.updateIngredientInFormulaAmount(_currentFormulaId!, ingredientId, amount, dilution);
  }
    // await _service.updateIngredientInFormula(_currentFormulaId!, ingredientId, amount, dilution);

    _totalAmount =
        _service.calculateTotalAmount(formulaIngredients);
    notifyListeners();
  if (_isTargetTotalEnabled) {
    await checkIfraCompliance();
  }
  }

void calculateTotalAmount() {
  if (_isRatioInput) {
    // Calculate the total based on ratios
    _totalRatioAmount = _formulaIngredients.asMap().entries.fold(0.0, (sum, entry) {
      final index = entry.key;
      final ratio = double.tryParse(_ratioControllers[index].text) ?? 0.0;
      return sum + ratio;
    });
    print("Total Ratio Amount: $_totalRatioAmount");
  } else {
    // Calculate the total based on amounts (grams)
    _totalAmount = _formulaIngredients.asMap().entries.fold(0.0, (sum, entry) {
      final index = entry.key;
      final ingredient = entry.value;
      final dilution = double.tryParse(_dilutionControllers[index].text) ?? 1.0;
      return sum + (ingredient['amount'] * dilution);
    });
    print("Total Amount: $_totalAmount");
  }

  notifyListeners();
}


void updateDilutionFactor(int index, String value) {
    final dilution = double.tryParse(value) ?? 1.0;
    _formulaIngredients[index]['dilution'] = dilution;
    calculateTotalAmount(); // Recalculate total when dilution changes
    notifyListeners();
  }


  Future<void> iterateOnFormula(context) async {
  if (_formulaIngredients.isEmpty) {
    // Ensure there's at least one ingredient before iterating
    print('Cannot iterate on an empty formula.');
    return;
  }
   _currentFormula = await _service.fetchFormulaById(_currentFormulaId!);


  // Generate the new formula name with the next iteration
  String newFormulaName = getNextIterationName(_currentFormula!['name']);

  // Create a new formula object with the updated name and a null ID (to be generated later)
  Map<String, dynamic> newFormula = {
    'name': newFormulaName,
    'type': _currentFormula!['type'],
    'notes': _currentFormula!['notes'],
    'creation_date': DateTime.now().toIso8601String(),
  };

  // Save the new formula to the database and get the new formula ID
  int? newFormulaId = await _service.saveFormulaToDatabase(newFormula);

  // // Save the ingredients for the new formula in the formula_ingredient table
  await _service.saveFormulaIngredients(newFormulaId!, _formulaIngredients);
  Provider.of<FormulaListProvider>(context, listen: false).fetchFormulas();

  notifyListeners();
  // Navigate back to the formula list page after iteration is complete
  Navigator.pop(context, true);
}

   String getNextIterationName(String formulaName) {
  final RegExp regex = RegExp(r'^(.*?)(-(\d{3}))?$');
  final Match? match = regex.firstMatch(formulaName);

  if (match != null) {
    String baseName = match.group(1) ?? formulaName;
    String? iteration = match.group(3);

    int nextIteration = iteration != null ? int.parse(iteration) + 1 : 1;
    return '$baseName-${nextIteration.toString().padLeft(3, '0')}';
  } else {
    return '$formulaName-001';
  }
}

void toggleRatioInput(BuildContext context, bool value) async {
  if (_isInputModeLocked) {
    print("Input mode is locked. Cannot toggle.");
    return; // Prevent toggling if the input mode is locked
  }

  _isRatioInput = value;
  notifyListeners();

  // Update the is_ratio_formula field in the database
  if (_currentFormulaId != null) {
    await _service.updateFormulaInputMode(_currentFormulaId!, _isRatioInput);
    Provider.of<FormulaListProvider>(context, listen: false).fetchFormulas();
  }

  // Update the controllers based on the input mode
  if (_isRatioInput) {
    for (int i = 0; i < _formulaIngredients.length; i++) {
      double ratio = _formulaIngredients[i]['ratio'] ?? 0.0;
      _amountControllers[i].text = ratio.toString();
    }
  } else {
    for (int i = 0; i < _formulaIngredients.length; i++) {
      double amount = _formulaIngredients[i]['amount'] ?? 0.0;
      _amountControllers[i].text = amount.toString();
    }
  }

  notifyListeners();
}


void handleDilutionChange(int index, String value)  async{
  double dilution = double.tryParse(value) ?? 1.0;
  print("DIL VALUE CHANGED: $value");

  final ingredient = _formulaIngredients[index];

  if (ingredient['ingredient_id'] != null) {
    // Update the dilution factor
    updateDilutionFactor(index, value);

    // Update the ingredient in the formula with the new dilution
    updateIngredientInFormula(
      index,
      ingredient['ingredient_id']!,
      ingredient['amount'],
      dilution,
    );
  } else {
    print("Warning: ingredient_id is null for index $index");
  }

  notifyListeners();

  // **AUTO-SAVE AFTER DILUTION CHANGE**
  print("DEBUG: Auto-saving after dilution change");
  await saveFormulaIngredients();
}

// void handleAmountChange(int index, String value) {
//   double amount = double.tryParse(value) ?? 0.0;
//   print("AMOUNT VALUE CHANGED: $amount");

//   final ingredient = _formulaIngredients[index];

//   if (ingredient['ingredient_id'] != null) {
//     // Update the ingredient in the formula with the new amount
//     updateIngredientInFormula(
//       index,
//       ingredient['ingredient_id']!,
//       amount,
//       ingredient['dilution'],
//     );
//   } else {
//     print("Warning: ingredient_id is null for index $index");
//   }

//   // Optionally, you can recalculate the total amount if needed
//   calculateTotalAmount();
//   notifyListeners();
// }

void handleAmountChange(int index, String value) async {
  double amount = double.tryParse(value) ?? 0.0;
  final ingredient = _formulaIngredients[index];

  if (ingredient['is_accord'] == true) {
    _updateAccordIngredients(ingredient['ingredient_id'], amount);
  } else {
    updateIngredientInFormula(index, ingredient['ingredient_id']!, amount, ingredient['dilution']);
  }

  calculateTotalAmount();
  notifyListeners();

  // **AUTO-SAVE AFTER AMOUNT CHANGE**
  print("DEBUG: Auto-saving after amount change");
  await saveFormulaIngredients();
}

void _updateAccordIngredients(int accordId, double newAmount) {
  for (var ingredient in _formulaIngredients) {
    if (ingredient['parent_accord_id'] == accordId) {
      double ratio = ingredient['amount'] / (_formulaIngredients.firstWhere(
        (item) => item['ingredient_id'] == accordId)['amount']);

      ingredient['amount'] = newAmount * ratio;
      ingredient['locked'] = true; // Prevent manual editing
    }
  }
}


void handleRatioChange(int index, String value) {
  double ratio = double.tryParse(value) ?? 0.0;
  print("RATIO VALUE CHANGED: $ratio");

  final ingredient = _formulaIngredients[index];

  if (ingredient['ingredient_id'] != null) {
    updateIngredientInFormula(
      index,
      ingredient['ingredient_id']!,
      ratio,
      ingredient['dilution'],
    );
    calculateTotalAmount();
    notifyListeners();
  } else {
    print("Warning: ingredient_id is null for index $index");
  }
}

// do we need focus nodes for ratio?
// what about dilution? 
// what else depends on amount in mating page? should they  get conditional  for ratio?
// pulling ration with fetch formula
// update all functions that have an older ingredient object(no ratio)
  void importData() async {
    final filePath = await _service.importData();

    if (filePath != null) {
      String finalPath = filePath.files.single.path!;
      await _service.importFormulaIngredients(
          finalPath, _currentFormulaId!);
      fetchFormulaIngredients(
          _currentFormulaId!); // Refresh the formula ingredients after import
      notifyListeners();
    }
  }

  Future<void> fetchFormula(int formulaId) async {
  print("DEBUG: Fetching formula with id: $formulaId");

  try {
    final formula = await _service.fetchFormulaById(formulaId);
    
    if (formula != null) {
      print("DEBUG: Fetched formula: $formula");

      _currentFormulaId = formulaId;
      _currentFormula = formula;
      
      // ✅ Use the new `is_accord` field from the database query
      _isAccordFormula = formula['type'] == 'category_0';
      print("DEBUG: Is Accord Formula: $_isAccordFormula");

      notifyListeners();
    } else {
      print("ERROR: No formula found with id: $formulaId");
    }
  } catch (e) {
    print("ERROR: Failed to fetch formula: $e");
  }
}



    void exportData(String format) async {
      
    await exportFormulaIngredients(_currentFormulaId!, format);
  }

    Future<void> exportFormulaIngredients(int formulaId, String format) async {
    // Fetch the formula ingredients
    await fetchFormulaIngredients(formulaId);

    // Calculate the total amount of ingredients
    double totalAmount =
        _formulaIngredients.fold(0.0, (sum, item) => sum + item['amount']);

    await _service.exportFormulaIngredients(
        _formulaIngredients, totalAmount, formulaId, format);
  }


  void updateSorting(String newSortOption) {
  if (_selectedSortOption == newSortOption) {
    // If the same option is selected again, reverse the sorting order
    _isReverseSort = !_isReverseSort;
  } else {
    // If a new sorting option is selected, set it and disable reverse sorting
    _selectedSortOption = newSortOption;
    _isReverseSort = false;
  }

  _sortIngredients();
  notifyListeners();
}

void _sortIngredients() {
  switch (_selectedSortOption) {
    case 'Add Order':
      _formulaIngredients.sort((a, b) => 
        (a['id'] ?? 0).compareTo(b['id'] ?? 0)
      );
      break;
    case 'Name':
      _formulaIngredients.sort((a, b) => 
        (a['name'] ?? '').compareTo(b['name'] ?? '')
      );
      break;
    case 'Category':
      _formulaIngredients.sort((a, b) => 
        (a['category'] ?? '').compareTo(b['category'] ?? '')
      );
      break;
     case 'Amount':
      _formulaIngredients.sort((a, b) {
        final double aAmount = (a['amount'] ?? 0.0) * (a['dilution'] ?? 1.0);
        final double bAmount = (b['amount'] ?? 0.0) * (b['dilution'] ?? 1.0);
        return aAmount.compareTo(bAmount);
      });
      break;
  }

  if (_isReverseSort) {
    _formulaIngredients = _formulaIngredients.reversed.toList();
  }

  notifyListeners();
}



}
