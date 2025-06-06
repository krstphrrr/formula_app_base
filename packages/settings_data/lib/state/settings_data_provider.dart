import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:settings_data/domain/settings_data_service.dart';

class SettingsDataProvider extends ChangeNotifier {
  String selectedFeature = 'IFRA'; // Default selected feature
  File? csvFile;
 



  String? _csvFilePath;
  String get csvFileName => _csvFilePath != null ? _csvFilePath!.split('/').last : '';

  final SettingsDataService _service;

  SettingsDataProvider(this._service);

  // Future<void> importData(BuildContext context) async {
  //   // var isImporting = true;
  //   notifyListeners();
  //   try {
  //     final result = await _service.pickCSVLocation();
  //     if (result != null) {
  //       String filePath = result.files.single.path!;
  //       await _service.importFromCSV(filePath);
  //       // Check if the widget is still mounted before showing the Snackbar
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Data imported successfully!')));
  //       }
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Failed to import csv: $e')));
  //     }
  //   } finally {
  //     // isImporting = false;
  //     notifyListeners();
  //   }
  // }

 Future<void> truncateTable() async {
    // Use the selected feature to determine which table to truncate
    if (selectedFeature == 'IFRA') {
      await _service.truncateIfraTable();
    } else if (selectedFeature == 'Ingredients') {
      await _service.truncateIngredientsTable();
      // await _service.debugPrintIngredientsTable();
    }
  }

  // Future<void> ingestCsv() async {
  //   if (_csvFilePath != null) {
  //     var data = await _service.processCsv(_csvFilePath!);
  //     // print()
  //     notifyListeners();
  //   }
  // }

  void setSelectedFeature(String feature) {
    selectedFeature = feature;
    notifyListeners();
  }

Future<void> importData(BuildContext context) async {
  // Pick the CSV file using FilePicker
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  // Check if a file was picked
  if (result != null && result.files.isNotEmpty) {
    // Create a File object from the picked file path
    final filePath = result.files.first.path;
    if (filePath != null) {
      csvFile = File(filePath);
      _csvFilePath = csvFile!.path.split('/').last;
      notifyListeners();
    }
  } else {
    // Handle case where no file was selected
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No file selected. Please try again.")),
    );
  }
}
  // Future<void> truncateTable() async {
  //   // Use the selected feature to determine which table to truncate
  //   if (selectedFeature == 'IFRA') {
  //     await _service.truncateIfraTable();
  //   } else if (selectedFeature == 'Ingredients') {
  //     await _service.truncateIngredientsTable();
  //   }
  // }

  // Future<void> ingestCsv() async {
  //   // Use the selected feature to determine which table to ingest data into
  //   if (selectedFeature == 'IFRA') {
  //     await _service.ingestIfraCsv(csvFile);
  //   } else if (selectedFeature == 'Ingredients') {
  //     await _service.ingestIngredientsCsv(csvFile);
  //   }
  // }

  List<Map<String, dynamic>> _parseIfraCsv(List<List<dynamic>> rows) {
  return rows.skip(1).map((row) {
    return {
      'key': row[0]?.toString(),
      'amendment_number': int.tryParse(row[1]?.toString() ?? '0'),
      'year_previous_publication': row[2]?.toString(),
      'year_last_publication': int.tryParse(row[3]?.toString() ?? '0'),
      'implementation_deadline_existing': row[4]?.toString(),
      'implementation_deadline_new': row[5]?.toString(),
      'name_of_ifra_standard': row[6]?.toString(),
      'cas_numbers': row[7]?.toString(),
      'cas_numbers_comment': row[8]?.toString(),
      'synonyms': row[9]?.toString(),
      'ifra_standard_type': row[10]?.toString(),
      'intrinsic_property': row[11]?.toString(),
      'flavor_use_consideration': row[12]?.toString(),
      'prohibited_fragrance_notes': row[13]?.toString(),
      'phototoxicity_notes': row[14]?.toString(),
      'restricted_ingredients_notes': row[15]?.toString(),
      'specified_ingredients_notes': row[16]?.toString(),
      'contributions_other_sources': row[17]?.toString(),
      'contributions_other_sources_notes': row[18]?.toString(),
      'category_1': row[19]?.toString(),
      'category_2': row[20]?.toString(),
      'category_3': row[21]?.toString(),
      'category_4': row[22]?.toString(),
      'category_5a': row[23]?.toString(),
      'category_5b': row[24]?.toString(),
      'category_5c': row[25]?.toString(),
      'category_5d': row[26]?.toString(),
      'category_6': row[27]?.toString(),
      'category_7a': row[28]?.toString(),
      'category_7b': row[29]?.toString(),
      'category_8': row[30]?.toString(),
      'category_9': row[31]?.toString(),
      'category_10a': row[32]?.toString(),
      'category_10b': row[33]?.toString(),
      'category_11a': row[34]?.toString(),
      'category_11b': row[35]?.toString(),
      'category_12': row[36]?.toString(),
      'category_0': 'Custom',  // **Auto-assign category_0**
    };
  }).toList();
}
  // Helper method to classify pyramid place based on substantivity
String _classifySubstantivity(double substantivityValue) {
  if (substantivityValue <= 0.06) {
    return 'top';
  } else if (substantivityValue <= 1.045) {
    return 'top-mid';
  } else if (substantivityValue <= 2.03) {
    return 'mid';
  } else if (substantivityValue <= 3.015) {
    return 'mid-base';
  } else {
    return 'base';
  }
}

  // Helper method to parse Ingredient CSV data
List<Map<String, dynamic>> _parseIngredientCsv(List<List<dynamic>> rows) {
  return rows.skip(1).map((row) {
    // Ensure the row has enough columns before accessing
    final int columnCount = row.length;

    final String name = columnCount > 1 ? row[1]?.toString() ?? '' : ''; // Corrected
    final String casNumber = columnCount > 2 ? row[2]?.toString() ?? '' : ''; // Corrected
    final String category = columnCount > 3 ? row[3]?.toString() ?? '' : ''; // Corrected
    final String description = columnCount > 4 ? row[4]?.toString() ?? '' : ''; // Corrected

    final double substantivity = columnCount > 5
        ? double.tryParse(row[5]?.toString() ?? '0.0') ?? 0.0
        : 0.0;
    final String pyramidPlace = _classifySubstantivity(substantivity);

    final double? boilingPoint = columnCount > 6
        ? double.tryParse(row[6]?.toString() ?? '0.0')
        : null;
    final double? vaporPressure = columnCount > 7
        ? double.tryParse(row[7]?.toString() ?? '0.0')
        : null;
    final double? molecularWeight = columnCount > 8
        ? double.tryParse(row[8]?.toString() ?? '0.0')
        : null;

    // Ensure safe extraction of synonyms
    final String synonymsString = columnCount > 9 ? row[9]?.toString() ?? '' : '';
    final List<String> synonyms = synonymsString
        .split('|') // Ensure proper delimiter from Python
        .map((synonym) => synonym.trim())
        .where((synonym) => synonym.isNotEmpty)
        .toList();

    final String? preferredSynonym = synonyms.isNotEmpty ? synonyms.first : null;

    return {
      'name': name,  // Now correctly mapped
      'cas_number': casNumber,  // Now correctly mapped
      'category': category,  // Now correctly mapped
      'description': description,  // Now correctly mapped
      'substantivity': substantivity,
      'boiling_point': boilingPoint,
      'vapor_pressure': vaporPressure,
      'molecular_weight': molecularWeight,
      'pyramid_place': pyramidPlace,
      'synonyms': synonyms,
      'preferred_synonym': preferredSynonym,
    };
  }).toList();
}


 Future<void> ingestCsv() async {
  if (csvFile == null) {
    print("No CSV file selected.");
    return;
  }

  final csvData = await csvFile!.readAsString();
  final rows = const CsvToListConverter().convert(csvData);

  if (selectedFeature == 'IFRA') {
    final List<Map<String, dynamic>> ifraData = _parseIfraCsv(rows);
    await _service.ingestIfraCsv(ifraData);

  } else if (selectedFeature == 'Ingredients') {
    final List<Map<String, dynamic>> ingredientData = _parseIngredientCsv(rows);
    await _service.ingestIngredientsCsv(ingredientData);
  }
}

// Future<void> ingestCsv() async {
//   if (csvFile == null) {
//     print("No CSV file selected.");
//     return;
//   }

//   final csvData = await csvFile!.readAsString();
//   final rows = const CsvToListConverter().convert(csvData);

//   // DEBUG: Print the first few rows of the CSV before processing
//   for (var i = 0; i < (rows.length < 5 ? rows.length : 5); i++) {
//     print("CSV Row $i: ${rows[i]}");
//   }

//   if (selectedFeature == 'IFRA') {
//     final List<Map<String, dynamic>> ifraData = _parseIfraCsv(rows);
//     await _service.ingestIfraCsv(ifraData);
//   } else if (selectedFeature == 'Ingredients') {
//     final List<Map<String, dynamic>> ingredientData = _parseIngredientCsv(rows);
//     await _service.ingestIngredientsCsv(ingredientData);
//   }
// }

  
  
}