import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:settings_data/data/settings_data_repository.dart';
import 'package:settings_data/settings_data.dart';

class SettingsDataService {
  final SettingsDataRepository _repository;

  SettingsDataService(this._repository);

    Future<List> processCsv(String filePath) async {
    final input = File(filePath).openRead();
    return await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();
  }

  // Future<void> truncateTable() async {
  //   await _repository.truncateTable();

  // }

  Future<FilePickerResult?> pickCSVLocation()async{
  // Use file picker to select CSV file
   return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'], // Only allow CSV files
    );
}


  Future<void> importFromCSV(String filePath) async {
    final file = File(filePath);
    final csvString = await file.readAsString();

    // Convert CSV to list
    List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);


    
    for (var i = 1; i < csvData.length; i++) { // Skip the header row
      final row = csvData[i];

      // Convert values to string if necessary
      final ifraStandard = {
        'key': row[0].toString(),
        'amendment_number': int.tryParse(row[1].toString()) ?? 0,
        'year_previous_publication': row[2].toString(),
        'year_last_publication': int.tryParse(row[3].toString()) ?? 0,
        'implementation_deadline_existing': row[4].toString(),
        'implementation_deadline_new': row[5].toString(),
        'name_of_ifra_standard': row[6].toString(),
        'cas_numbers': row[7].toString(),
        'cas_numbers_comment': row[8].toString(),
        'synonyms': row[9].toString(),
        'ifra_standard_type': row[10].toString(),
        'intrinsic_property': row[11].toString(),
        'flavor_use_consideration': row[12].toString(),
        'prohibited_fragrance_notes': row[13].toString(),
        'phototoxicity_notes': row[14].toString(),
        'restricted_ingredients_notes': row[15].toString(),
        'specified_ingredients_notes': row[16].toString(),
        'contributions_other_sources': row[17].toString(),
        'contributions_other_sources_notes': row[18].toString(),
        'category_1': row[19].toString(),
        'category_2': row[20].toString(),
        'category_3': row[21].toString(),
        'category_4': row[22].toString(),
        'category_5a': row[23].toString(),
        'category_5b': row[24].toString(),
        'category_5c': row[25].toString(),
        'category_5d': row[26].toString(),
        'category_6': row[27].toString(),
        'category_7a': row[28].toString(),
        'category_7b': row[29].toString(),
        'category_8': row[30].toString(),
        'category_9': row[31].toString(),
        'category_10a': row[32].toString(),
        'category_10b': row[33].toString(),
        'category_11a': row[34].toString(),
        'category_11b': row[35].toString(),
        'category_12': row[36].toString(),
      };

      // Insert into the database
      await _repository.insertIfraStandardIntoDatabase(ifraStandard);
    }
  }

  Future<void> truncateIfraTable() async {
    await _repository.truncateTable('ifra_standards');
  }
  Future<void> truncateIngredientsTable() async {
    await _repository.truncateTable('ingredients'); 
  }

 // Ingest IFRA data into the database
  Future<void> ingestIfraCsv(List<Map<String, dynamic>> ifraData) async {
    if (ifraData.isNotEmpty) {
      for (final data in ifraData) {
        // Ensure `category_0` exists
        data['category_0'] = data['category_0'] ?? 'Custom';
        await _repository.insertDataIntoTable(data, 'ifra_standards');
      }
    }
  }

  // Ingest Ingredients data into the database
Future<void> ingestIngredientsCsv(List<Map<String, dynamic>> ingredientData) async {
  if (ingredientData.isNotEmpty) {
    for (final data in ingredientData) {
      final casNumbers = (data['cas_number'] as String).split(',').map((e) => e.trim()).toList();
      final List<String> synonyms = (data['synonyms'] is String) 
          ? (data['synonyms'] as String).split('|').map((e) => e.trim()).toList() 
          : List<String>.from(data['synonyms'] ?? []);
      final String? preferredSynonym = data['preferred_synonym'];

      // Insert ingredient into database and get ID
      final int ingredientId = await _repository.insertIngredientWithDetails(data, casNumbers, preferredSynonym);

      // Ensure the ingredient ID is valid before inserting synonyms
      if (ingredientId != -1) {
        for (String synonym in synonyms) {
          if (synonym.isNotEmpty) {
            await _repository.addSynonym(ingredientId, synonym);
          }
        }
      }
    }
  }
}

Future<void> debugPrintIngredientsTable() async {
  await _repository.debugPrintIngredientsTable();
}
}