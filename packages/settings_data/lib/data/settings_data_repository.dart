import 'package:sqflite/sqflite.dart';
import 'package:core/core.dart';

class SettingsDataRepository {
  final Database db; 

  SettingsDataRepository(this.db);

  //   Future<void> truncateTable() async {
  //   final db = await DatabaseHelper().database;  // Fetch the shared database instance
  //   await db.execute('DELETE FROM ifra_standards');
  // }

  Future<void> insertIfraStandardIntoDatabase(Map<String, dynamic> ifraStandard) async {
    final db = await DatabaseHelper().database;
    try {
      await db.insert('ifra_standards', ifraStandard);
        print("Inserted IFRA standard: $ifraStandard");
    } catch (e) {
        print("Failed to insert IFRA standard: $e");
    }
  }

// Generalized method to truncate a table and reset the autoincrement index
Future<void> truncateTable(String tableName) async {
  final db = await DatabaseHelper().database;
  try {
    // Delete all rows from the table
    await db.execute('DELETE FROM $tableName');
    
    // Reset the autoincrement counter if applicable
    await db.execute('DELETE FROM sqlite_sequence WHERE name = ?', [tableName]);
    
    print("Truncated table: $tableName and reset autoincrement index.");
  } catch (e) {
    print("Failed to truncate table $tableName: $e");
  }
}

  // Generalized method to insert data into a specified table
  Future<void> insertDataIntoTable(Map<String, dynamic> data, String tableName) async {
  final db = await DatabaseHelper().database;
  try {
    // Ensure category_0 is set before inserting
    if (!data.containsKey('category_0') || data['category_0'] == null) {
      data['category_0'] = 'Custom';
    }

    await db.insert(tableName, data);
    print("Inserted data into $tableName: $data");
  } catch (e) {
    print("Failed to insert data into $tableName: $e");
  }
}

Future<int> insertIngredientWithDetails(
    Map<String, dynamic> ingredientData, List<String> casNumbers, String? preferredSynonym) async {
  final db = await DatabaseHelper().database;
  int? preferredSynonymId;

  try {
    // Insert the ingredient first
    final int ingredientId = await db.insert('ingredients', {
      'name': ingredientData['name'],
      'cas_number': ingredientData['cas_number'],
      'category': ingredientData['category'],
      'description': ingredientData['description'],
      'substantivity': ingredientData['substantivity'] ?? 0.0,
      'boiling_point': ingredientData['boiling_point'],
      'vapor_pressure': ingredientData['vapor_pressure'],
      'molecular_weight': ingredientData['molecular_weight'],
      'pyramid_place': ingredientData['pyramid_place'],
    });

    print("Inserted ingredient with ID: $ingredientId");

    // Handle CAS numbers
    for (String cas in casNumbers) {
      if (cas.isNotEmpty) {
        await addCASNumber(ingredientId, cas);
      }
    }

    // Insert preferred synonym if provided
    if (preferredSynonym != null && preferredSynonym.isNotEmpty) {
      preferredSynonymId = await addSynonym(ingredientId, preferredSynonym);
    }

    // Update the ingredient with the preferred synonym ID
    if (preferredSynonymId != null) {
      await db.update('ingredients', {
        'preferred_synonym_id': preferredSynonymId,
      }, where: 'id = ?', whereArgs: [ingredientId]);
    }

    return ingredientId;
  } catch (e) {
    print("Error inserting ingredient: $e");
    return -1; // Return -1 in case of an error
  }
}




  // Helper method to add or update the category in olfactive_categories
  Future<void> addOrUpdateCategory(String category) async {
    final db = await DatabaseHelper().database;
    try {
      // Check if the category already exists
      final existingCategory = await db.query(
        'olfactive_categories',
        where: 'name = ?',
        whereArgs: [category],
      );

      if (existingCategory.isEmpty) {
        // Category does not exist, insert it
        await db.insert('olfactive_categories', {'name': category, 'color': null});
        print("Added new category: $category");
      } else {
        print("Category already exists: $category");
      }
    } catch (e) {
      print("Error handling category: $e");
    }
  }

  // Helper method to add a CAS number to the cas_numbers table
  Future<void> addCASNumber(int ingredientId, String casNumber) async {
    final db = await DatabaseHelper().database;
    try {
      await db.insert('cas_numbers', {
        'ingredient_id': ingredientId,
        'cas_number': casNumber,
      });
      print("CAS number $casNumber added for ingredient $ingredientId");
    } catch (e) {
      print("Error adding CAS number: $e");
    }
  }

  // Method to add a synonym to the ingredient_synonyms table
Future<int> addSynonym(int ingredientId, String synonym) async {
  final db = await DatabaseHelper().database;
  try {
    final int synonymId = await db.insert('ingredient_synonyms', {
      'ingredient_id': ingredientId,
      'synonym': synonym,
    });
    print("Synonym '$synonym' added for ingredient ID $ingredientId with ID $synonymId");
    return synonymId;
  } catch (e) {
    print("Error adding synonym: $e");
    return -1; // Return -1 if an error occurs
  }
}


  
}