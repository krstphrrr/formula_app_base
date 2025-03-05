import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:formula_ingredient/data/formula_ingredient_repository.dart';
import 'package:path_provider/path_provider.dart';

class FormulaIngredientService {
static const platform = MethodChannel('com.example.formula_composer/file_operations');
  final FormulaIngredientRepository _repository;
  FormulaIngredientService(this._repository);

  Future<List<Map<String, dynamic>>> getAvailableIngredients() async {
    return await _repository.fetchAvailableIngredients();
  }

  Future<List<Map<String, dynamic>>> getIngredientsForFormula(int formulaId) async {
    return await _repository.fetchIngredientsForFormula(formulaId);
  }

  Future<Map<String, dynamic>?> getIngredientById(int ingredientId) async {
    return await _repository.fetchIngredientById(ingredientId);
  }


  Future<void> updateIngredientInFormulaAmount(int formulaId, int ingredientId, double amount, double dilution) async {
    print("UPDATING FROM SERVICE");
    await _repository.updateFormulaIngredientAmount(formulaId, ingredientId, amount, dilution);
  }

   Future<void> updateIngredientInFormulaRatio(int formulaId, int ingredientId, double ratio, double dilution) async {
    print("UPDATING FROM SERVICE");
    await _repository.updateFormulaIngredientRatio(formulaId, ingredientId, ratio, dilution);
  }

  Future<void>  deleteFormulaIngredient(int formulaId, int ingredientId) async {
    print("REMOVING FROM SERVICE");
    await _repository.deleteFormulaIngredient(formulaId, ingredientId);
  }

  Future<void> saveFormulaIngredients(int formulaId, List<Map<String, dynamic>> ingredients) async {
    return await _repository.saveFormulaIngredients(formulaId, ingredients);
}


   Future<List<Map<String, dynamic>>> fetchFormulaIngredients(int formulaId) async {
    return await _repository.fetchFormulaIngredients(formulaId);
  }
    Future<void> addFormulaIngredient(int formulaId, int ingredientId, double amount, double dilution) async {
    await _repository.addFormulaIngredient(formulaId, ingredientId, amount, dilution);
  }

  Future<void> saveAllIngredients(int formulaId, List<Map<String, dynamic>> ingredients) async {
    await _repository.updateAllIngredients(formulaId, ingredients);
  }

    Future<List<Map<String, dynamic>>> fetchAvailableIngredients() async {
    return await _repository.fetchAvailableIngredients();
  }

    Future<Map<String, dynamic>?> fetchFormulaForIFRA(int formulaId) async{
    return await _repository.fetchFormulaForIFRA(formulaId);
  }

  
  double calculateTotalAmount(List<Map<String, dynamic>> formulaIngredients) {
    double total = 0.0;
    for (var ingredient in formulaIngredients) {
      total += ingredient['amount'] * (ingredient['dilution'] ?? 1.0);
      print("CALCULATING: ${total}");
    }
    return total;
  }

  
 Future<List<Map<String, dynamic>>> fetchIfraStandards(String category) async {
  return await _repository.fetchIfraStandards(category);
 }
Future<List<String>> fetchCasNumbers(int ingredientId) async {
    return await _repository.fetchCasNumbers(ingredientId);
  }

   Future<Map<String, dynamic>?> fetchFormulaById(int formulaId) async {
  return await _repository.fetchFormulaById(formulaId);
}

      Future<int?> saveFormulaToDatabase(Map<String, dynamic> formula) async {
      return await _repository.saveFormulaToDatabase(formula);
  }

   Future<void> updateFormulaInputMode(int formulaId, bool isRatioInput) async {
     return await _repository.updateFormulaInputMode(formulaId,isRatioInput);
   }


    // select export path with filepicker
  Future<String?> exportPathPicker() async {
    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'export.csv', // Default file name
      type: FileType.custom,
      bytes: Uint8List(0),
      allowedExtensions: ['csv'], // Only allow CSV files
    );
    return filePath;
  }


 Future<void> exportFormulaIngredients(
  List<Map<String, dynamic>> formulaIngredients,
  double totalAmount,
  int formulaId,
  String format,
) async {
  List<List<String>> csvData = [];

  // Fetch the formula details (including the name)
  final formula = await _repository.fetchFormulaForIFRA(formulaId);
  final formulaName = formula?['name'] ?? 'UnnamedFormula';

  // Check if formulaIngredients is empty
  if (formulaIngredients.isEmpty) {
    print("No ingredients found for formula ID: $formulaId. Export aborted.");
    return;
  }

  // Add CSV headers
  csvData.add(['Ingredient', 'Amount (g)']);

  // Prepare the CSV data with ingredient name and formatted amount
  for (var ingredient in formulaIngredients) {
    if (ingredient.isEmpty) continue;

    double amount = ingredient['amount'] * (ingredient['dilution_factor'] ?? 1.0);

    String formattedAmount;
    if (format == 'ppt') {
      formattedAmount = ((amount / totalAmount) * 1000).toStringAsFixed(2); // Parts per thousand
    } else if (format == 'pph') {
      formattedAmount = ((amount / totalAmount) * 100).toStringAsFixed(2); // Parts per hundred
    } else {
      formattedAmount = (amount / totalAmount).toStringAsFixed(2); // Percent fraction
    }

    // Add the ingredient data to csvData
    csvData.add([ingredient['name'] ?? 'Unknown Ingredient', formattedAmount]);
  }

  // Debug print the CSV data
  print("CSV DATA: $csvData");

  // Check if csvData has only the headers (meaning no data was added)
  if (csvData.length <= 1) {
    print("No ingredient data to export. The CSV file will not be saved.");
    return;
  }

  // Convert the data to CSV format

  // Save the CSV to a file with the formula name in the filename
  String? filePath = await FilePicker.platform.saveFile(
    dialogTitle: 'Save File',
    fileName: 'formula_${formulaName}_export.csv',
    type: FileType.custom,
    bytes: Uint8List(0),
    allowedExtensions: ['csv'],
  );
print(filePath);
 if (filePath != null) {
  try {
    final file = File(filePath);
    String csvContent = const ListToCsvConverter().convert(csvData);
    // await file.writeAsString(csvContent, flush: true);
    if (!file.existsSync()) {
      await file.writeAsString(csvContent, flush: true);
    }
    print("File saved successfully at: $filePath");
  } catch (e) {
    print("Error writing to file: $e");
  }
} else {
  print("File path is null. Export aborted.");
}
}


    Future<FilePickerResult?> importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    return result;
  }

    Future<void> importFormulaIngredients(String filePath, int formulaId) async {
    final file = File(filePath);
    final csvString = await file.readAsString();

    // Convert CSV to list
    List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

    // Insert data into the formula_ingredient table
    for (var row in csvData) {
      await _repository.addFormulaIngredient(formulaId, row[0], double.parse(row[1]), 1.0);
    }
  }

  Future<String?> getCategoryColor(String categoryName) async {
  return await _repository.getCategoryColor(categoryName);
}


Future<List<Map<String, dynamic>>> fetchAvailableAccords() async {
  return await _repository.fetchAvailableAccords();
}


Future<List<Map<String, dynamic>>> fetchAccordIngredients(int accordId) async {
  return await _repository.fetchAccordIngredients(accordId);
}



// ACCORD MAGIC

Future<void> addAccordIngredient(int accordId, int ingredientId, double ratio) async {
  return await _repository.addAccordIngredient(accordId, ingredientId, ratio);
}

Future<int> addAccord(String accordName) async {
  // Check if the accord already exists
  int? existingAccordId = await _repository.getAccordIdByName(accordName);

  if (existingAccordId != null) {
    print("DEBUG: Accord '$accordName' already exists with ID: $existingAccordId");
    return existingAccordId; // Return the existing accord ID
  }

  // If the accord doesn't exist, create a new one
  return await _repository.addAccord(accordName);
}

Future<int> getAccordIdByFormulaId(int formulaId) async {
  final accordId = await _repository.getAccordIdByFormulaId(formulaId);
  if (accordId == null) {
    throw Exception('Accord ID not found for formula ID: $formulaId');
  }
  return accordId;
  }

Future<void> deleteAccordIngredient(int accordId, int ingredientId) async {
  return await _repository.deleteAccordIngredient(accordId, ingredientId);
}

Future<int> getOrCreateAccord(String accordName) async {
  final accordId = await _repository.getAccordIdByName(accordName);
  if (accordId != null) return accordId;

  return await _repository.addAccord(accordName);
}

Future<bool> isIngredientInInventory(int ingredientId) async {
  return await _repository.isIngredientInInventory(ingredientId);

}

Future<void> addIngredientToInventory(int ingredientId) async {
  return await _repository.addIngredientToInventory(ingredientId);
}







}
