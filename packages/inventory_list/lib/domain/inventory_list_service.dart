import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:inventory_list/inventory_list.dart';

class InventoryListService {
  static const platform = MethodChannel('com.example.formula/file_operations');

  final InventoryListRepository _repository;

  InventoryListService(this._repository);

  Future<List<Map<String, dynamic>>> fetchInventory() async {
    return await _repository.fetchAllInventory();
  }

  Future<void> deleteInventoryItem(int id) async {
    try {
        await _repository.deleteInventoryItem(id);
    } catch (e) {
        print("inventory_service: Error deleting inventory item: $e");
    }
}
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

  Future<void> exportCSV(String directory) async {
    try {
        final inventoryItems = await _repository.fetchAllInventory();
        int inventoryCount = inventoryItems.length;
        String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String fileName = '_${inventoryCount}inv_$currentDate.csv';
        directory = directory.replaceAll('.csv', '');
        String filePath = '$directory$fileName';

        List<List<String>> csvData = [
            ["id", "name", "inventory_amount", "cost_per_gram", "acquisition_date", "personal_notes", "preferred_synonym"],
            ...inventoryItems.map((item) => [
                (item['id'] ?? '').toString(),
                (item['name'] ?? '').toString(),
                (item['inventory_amount'] ?? 0).toString(),
                (item['cost_per_gram'] ?? 0).toString(),
                (item['acquisition_date'] ?? '').toString(),
                (item['personal_notes'] ?? '').toString(),
                (item['preferred_synonym'] ?? '').toString(),
            ])
        ];

        String csvContent = const ListToCsvConverter().convert(csvData);

        final file = File(filePath);
        await file.writeAsString(csvContent);

        print('Inventory data exported successfully!');
    } catch (e) {
        print('Error during inventory export: $e');
    }
}


    Future<FilePickerResult?> pickCSVLocation() async {
    // Use file picker to select CSV file
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'], // Only allow CSV files
    );
  }

  Future<void> importFromCSV(String filePath) async {
    final file = File(filePath);
    final csvString = await file.readAsString();

    List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

    for (var i = 1; i < csvData.length; i++) {
        final row = csvData[i];

        final inventoryItem = {
            'ingredient_id': int.tryParse(row[0].toString()),  // Ensure integer conversion
            'inventory_amount': double.tryParse(row[1].toString()) ?? 0.0,
            'cost_per_gram': double.tryParse(row[2].toString()) ?? 0.0,
            'acquisition_date': row[3].toString(),
            'personal_notes': row[4].toString(),
            'preferred_synonym_id': int.tryParse(row[5].toString()),  // Ensure integer conversion
        };

        await _repository.insertInventoryItem(inventoryItem);
    }
}


    Future<Color> getCategoryColor(String categoryName) async {
    // Fetch the hex color code from the repository
    final colorHex = await _repository.getCategoryColor(categoryName);
    print("cat: ${categoryName} color: ${colorHex}");

    // If color is null (not set), provide a default color, else parse the color
    return colorHex != null
        ? Color(int.parse(colorHex.replaceFirst('#', '0xFF'))) // Convert hex to Color
        : Colors.grey; // Default color if none set
  }

  
  Future<void> addToInventory({
    int? ingredientId,
    int? accordId,
    double amount = 0.0,
    double costPerGram = 0.0,
    String acquisitionDate = '',
    String personalNotes = '',
    int? preferredSynonymId,
}) async {
    if (ingredientId == null && accordId == null) {
        print("Error: No valid ingredient or accord selected.");
        return;
    }

    final inventoryItem = {
        'ingredient_id': ingredientId,
        'accord_id': accordId,
        'inventory_amount': amount,
        'cost_per_gram': costPerGram,
        'acquisition_date': acquisitionDate.isNotEmpty ? acquisitionDate : DateTime.now().toIso8601String(),
        'personal_notes': personalNotes,
        'preferred_synonym_id': preferredSynonymId,
    };

    await _repository.insertInventoryItem(inventoryItem);
}


}
