import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:formula_ingredient/formula_ingredient.dart';
// import '../../ingredient_edit/state/ingredient_edit_provider.dart';
import '../domain/formula_scale_service.dart';

class FormulaScaleProvider extends ChangeNotifier {
  final FormulaScaleService _service;
  FormulaScaleProvider(this._service);

    List<Map<String, dynamic>> _formulaDetails = [];
  Map<int, double> _ingredientCosts = {};
  List<Map<String, dynamic>>? _scaledDetails = [];

  double _totalCost = 0.0;
  double _scaler = 1.0;
  TextEditingController _scalerController = TextEditingController();

  List<Map<String, dynamic>> get formulaDetails => _formulaDetails;
  Map<int, double> get ingredientCosts => _ingredientCosts;
  List<Map<String, dynamic>>? get scaledDetails => _scaledDetails;
  double get totalCost => _totalCost;
  double get scaler => _scaler;
  TextEditingController get scalerController => _scalerController;

  List<Map<String, dynamic>> _formulaIngredients = [];
   List<Map<String, dynamic>> get formulaIngredients => _formulaIngredients;
  bool _isLoading = false;
   bool get isLoading => _isLoading;

   int? _currentFormulaId = 1;
   int? get currentFormulaId => _currentFormulaId;

     set currentFormulaId(int? value) {
    // if (_currentFormula!['formula_id'] != null) {
    _currentFormulaId = value;
    notifyListeners();
    // }
  }

  @override
void dispose() {
  _scalerController.dispose();
  // Clear the scaler list
  super.dispose();
}

void clear() {
  _formulaDetails = [];
  _scaledDetails = [];
  scalerController.clear();
  notifyListeners();
}


  // Use the formula from the FormulaProvider to load ingredients
void fetchFormulaDetails(BuildContext context) async {
  clear();
  _isLoading = true;
  notifyListeners();

  final details = await _service.fetchFormulaIngredients(_currentFormulaId!);

  // Ensure uniqueness in fetched ingredients
  final Set<int> seenIngredients = {};
  List<Map<String, dynamic>> uniqueDetails = [];

  for (var ingredient in details) {
    int ingredientId = ingredient['ingredient_id'];
    if (!seenIngredients.contains(ingredientId)) {
      seenIngredients.add(ingredientId);
      uniqueDetails.add(Map<String, dynamic>.from(ingredient));
    }
    await fetchIngredientCost(context, ingredientId);  // Fetch cost separately
  }

  _formulaDetails = uniqueDetails;
  _totalCost = _service.calculateTotalCost(_formulaDetails, _ingredientCosts);
  _isLoading = false;
  notifyListeners();
}


   Future<void> exportScalerCSV(BuildContext context) async {
  String replaceSpacesWithUnderscores(String input) {
    return input.replaceAll(' ', '_');
  }

  // Fetch the formula details using the formulaId
  final formulaIngredientProvider =
      Provider.of<FormulaIngredientProvider>(context, listen: false);
  final formula = await formulaIngredientProvider.fetchFormulaById(_currentFormulaId!);
  print("formula!! ${formula}");
  // Check if formula exists and fetch the name, else assign a default name
  String formName = formula != null
      ? formula['name'] ?? 'default_formula'
      : 'default_formula';
  formName = replaceSpacesWithUnderscores(formName);

  double targetAmount = double.tryParse(scalerController.text) ?? 0.0;

  // Use a post-frame callback to avoid calling notifyListeners during the build phase
  WidgetsBinding.instance.addPostFrameCallback((_) {
    scaleFormula(targetAmount);
     if(targetAmount==0.0){
      _scaledDetails = _formulaDetails;
    }
    List<Map<String, dynamic>> scaledDetails = _scaledDetails!;
   

    List<List<dynamic>> rows = [
      ['Ingredient', 'Amount (g)'], // CSV headers
    ];

    for (var ingredient in scaledDetails) {
      rows.add([
        ingredient['name'],
        ingredient['scaledAmount'].toStringAsFixed(5),
      ]);
    }

    // Export the CSV
    _service.exportScalerCSV(formName, rows);
  });
}

bool isRatioBased(List<Map<String, dynamic>> formulaIngredients) {
  return formulaIngredients.any((ingredient) => ingredient.containsKey('ratio'));
}

bool isRatioBasedFormula() {
  print("IS IT RATIO BASED? Formula Details: $_formulaDetails");
  
  // Check if any formula ingredient has a non-null ratio
  return formulaDetails.isNotEmpty &&
      formulaDetails.any((ingredient) => ingredient['ratio'] != null);
}


    // Function to scale ingredients based on the input target amount and recalculate cost
 void scaleFormula(double targetAmount) {
  if (_formulaDetails.isEmpty) {
    print("No formula details available to scale.");
    return;
  }

  // Convert to a Map to remove duplicates based on ingredient_id
  final Map<int, Map<String, dynamic>> uniqueScaledDetails = {};

  if (isRatioBasedFormula()) {
    double totalRatio = _formulaDetails.fold(
        0.0, (sum, ingredient) => sum + (ingredient['ratio'] ?? 0.0));

    if (totalRatio > 0) {
      for (var ingredient in _formulaDetails) {
        int ingredientId = ingredient['ingredient_id'];
        double ratio = ingredient['ratio'] ?? 0.0;
        double scaledAmount = targetAmount * (ratio / totalRatio);
        uniqueScaledDetails[ingredientId] = {
          ...ingredient,
          'scaledAmount': scaledAmount,
        };
      }
    } else {
      print("Invalid total ratio: $totalRatio");
      _scaledDetails = [];
    }
  } else {
    double currentTotal = _formulaDetails.fold(
        0.0, (sum, ingredient) => sum + (ingredient['amount'] ?? 0.0));
    double scaleFactor = targetAmount / currentTotal;

    for (var ingredient in _formulaDetails) {
      int ingredientId = ingredient['ingredient_id'];
      double scaledAmount = (ingredient['amount'] ?? 0.0) * scaleFactor;
      uniqueScaledDetails[ingredientId] = {
        'ingredient_id': ingredientId,
        'name': ingredient['name'] ?? 'Unknown ingredient',
        'scaledAmount': scaledAmount,
      };
    }
  }

  _scaledDetails = uniqueScaledDetails.values.toList();  // Store only unique ingredients
  notifyListeners();
}



    // Fetch the cost per gram for an ingredient
  Future<void> fetchIngredientCost(
      BuildContext context, int ingredientId) async {
    final formulaIngredientProvider =
        Provider.of<FormulaIngredientProvider>(context, listen: false);
    formulaIngredientProvider.getIngredientById(ingredientId);
    final ingredient = formulaIngredientProvider.singleIngredientDetails;

    if (ingredient != null && ingredient['cost_per_gram'] != null) {
      _ingredientCosts[ingredientId] = ingredient['cost_per_gram'];
      notifyListeners();
    }
  }
}