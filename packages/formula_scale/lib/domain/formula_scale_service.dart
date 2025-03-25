import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import 'package:formula_scale/data/formula_scale_repository.dart';

class FormulaScaleService {

  final FormulaScaleRepository _repository;
    static const platform = MethodChannel('com.example.formula_composer/file_operations');

  
  FormulaScaleService(this._repository);

   Future<List<Map<String, dynamic>>> fetchFormulaIngredients(int formulaId) async {
    return await _repository.fetchFormulaIngredients(formulaId);
  }

    double calculateTotalCost(List<Map<String, dynamic>> ingredients, Map<int, double> ingredientCosts) {
    double cost = 0.0;

    for (var ingredient in ingredients) {
      int ingredientId = ingredient['ingredient_id'];
      double amount = ingredient['scaledAmount'] ?? ingredient['amount'] ?? 0.0;
      double costPerGram = ingredientCosts[ingredientId] ?? 0.0;
      cost += amount * costPerGram;
    }

    return cost;
  }

    Future<void> exportScalerCSV(String formName, List<List<dynamic>> rows ) async {


    String csvData = const ListToCsvConverter().convert(rows);

    print("CSV DATA SCALER: $csvData");
    // Use FilePicker to pick a file location
    String? outputFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Scaled Formula as CSV',
      fileName: 'scaled_${formName}_export.csv',
      type: FileType.custom,
      bytes: Uint8List(0),
      allowedExtensions: ['csv'],
    );

    if (outputFilePath != null) {
      final file = File(outputFilePath);
      await file.writeAsString(csvData);
      print('CSV Exported to: $outputFilePath');
      // Optionally show a success message here
    } else {
      print('File saving canceled.');
    }
  }

  Future<List<Map<String, dynamic>>> scaleFormulaByRatio(
    List<Map<String, dynamic>> formulaIngredients, double targetAmount) async {
    if (formulaIngredients.isEmpty) {
      throw ArgumentError("Formula ingredients list is empty");
    }

    // Calculate the total ratio (sum of ingredient ratios)
    double totalRatio = formulaIngredients.fold(
        0.0, (sum, ingredient) => sum + (ingredient['ratio'] ?? 0.0));

    if (totalRatio <= 0) {
      throw ArgumentError("Invalid total ratio: $totalRatio");
    }

    // Scale ingredients based on targetAmount and their respective ratios
    return formulaIngredients.map((ingredient) {
      double ratio = ingredient['ratio'] ?? 0.0;
      double scaledAmount = targetAmount * (ratio / totalRatio);
      return {
        ...ingredient,
        'scaledAmount': scaledAmount,
      };
    }).toList();
  }
}