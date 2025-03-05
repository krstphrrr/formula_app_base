import 'package:sqflite/sqflite.dart';

import 'package:core/database/database_helper.dart';

class FormulaIngredientRepository {
  final Database db;  // Inject SQLite database instance

  FormulaIngredientRepository(this.db);

  Future<List<Map<String, dynamic>>> fetchAvailableIngredients() async {
  final db = await DatabaseHelper().database;
  print("Fetching ingredients without CAS numbers...");

  try {
    final data = await db.rawQuery('''
      SELECT i.id, i.name, i.category, 
             (SELECT GROUP_CONCAT(s.synonym, ', ') 
              FROM ingredient_synonyms s 
              WHERE s.ingredient_id = i.id) AS synonyms
      FROM ingredients i;
    ''');

    print("Fetched ${data.length} ingredients (without CAS numbers).");
    return data;
  } catch (e) {
    print("Error fetching ingredients: $e");
    return [];
  }
}



// Future<void> debugCheckTables() async {
//   final db = await DatabaseHelper().database;

//   final test = Sqflite.firstIntValue(
//       await db.rawQuery('''
// SELECT i.id, i.name, i.category, 
//              (SELECT GROUP_CONCAT(s.synonym, ', ') 
//               FROM ingredient_synonyms s 
//               WHERE s.ingredient_id = i.id) AS synonyms,
//              (SELECT GROUP_CONCAT(c.cas_number, ', ') 
//               FROM cas_numbers c 
//               WHERE c.ingredient_id = i.id) AS cas_numbers
//       FROM ingredients i;
// LIMIT 10;

// ''')) ?? 0;
  

//   print("DEBUG: Ingredients Count = $test");
// }


  Future<List<Map<String, dynamic>>> fetchIngredientsForFormula(int formulaId) async {
    final db = await DatabaseHelper().database;
    print("fetching formula ${formulaId}...");
    try {
      return await db.query(
        'formula_ingredient',
        where: 'formula_id = ?',
        whereArgs: [formulaId],
      );
    } catch (e) {
      print("Error fetching ingredients for formula $formulaId: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchIngredientById(int ingredientId) async {
    final db = await DatabaseHelper().database;
    try {
      final result = await db.query(
        'ingredients',
        where: 'id = ?',
        whereArgs: [ingredientId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print("Error fetching ingredient with id $ingredientId: $e");
      return null;
    }
  }

  // Update a formula ingredient
  Future<void> updateFormulaIngredientAmount(int formulaId, int ingredientId, double amount, double dilution) async {
    final db = await DatabaseHelper().database;

    print("updating ${ingredientId} with ${amount} and ${dilution} dil");
    try {
      await db.update(
        'formula_ingredient',
        {
          'amount': amount,
          'dilution': dilution,
        },
        where: 'formula_id = ? AND ingredient_id = ?',
        whereArgs: [formulaId, ingredientId],
      );
      // if (kDebugMode) {
        print("Formula ingredient updated successfully.");
      // }
    } catch (e) {
      // if (kDebugMode) {
        print("Error updating formula ingredient: $e");
      // }
    }
  }

  // Update a formula ingredient
  Future<void> updateFormulaIngredientRatio(int formulaId, int ingredientId, double ratio, double dilution) async {
    final db = await DatabaseHelper().database;

    print("updating ${ingredientId} with ${ratio} and ${dilution} dil");
    try {
      await db.update(
        'formula_ingredient',
        {
          'ratio': ratio,
          'dilution': dilution,
        },
        where: 'formula_id = ? AND ingredient_id = ?',
        whereArgs: [formulaId, ingredientId],
      );
      // if (kDebugMode) {
        print("Formula ingredient updated successfully.");
      // }
    } catch (e) {
      // if (kDebugMode) {
        print("Error updating formula ingredient: $e");
      // }
    }
  }

  Future<void> deleteFormulaIngredient(int formulaId, int ingredientId) async {
     final db = await DatabaseHelper().database;
    try {
      await db.delete(
        'formula_ingredient',
        where: 'formula_id = ? AND ingredient_id = ?',
        whereArgs: [formulaId, ingredientId],
      );
      // if (kDebugMode) {
        print("Formula ingredient deleted successfully.");
      // }
    } catch (e) {
      // if (kDebugMode) {
        print("Error deleting formula ingredient: $e");
      // }
    }
  }

Future<void> saveFormulaIngredients(int formulaId, List<Map<String, dynamic>> ingredients) async {
  final db = await DatabaseHelper().database;

  for (var ingredient in ingredients) {
    await db.insert(
      'formula_ingredient',
      {
        'formula_id': formulaId,
        'ingredient_id': ingredient['ingredient_id'],
        'amount': ingredient['amount'],
        'dilution': ingredient['dilution'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Ensures it updates instead of inserting duplicate rows
    );
  }
}

  Future<int?> saveFormulaToDatabase(Map<String, dynamic> formula) async {
    final db = await DatabaseHelper().database;
   print("Adding new formula with name: ${formula['name']}");
    try {
      int formulaId = await db.insert('formulas', {
        'name': formula['name'],
        'creation_date': formula['creation_date'],
        'notes': formula['notes'],
        'type': formula['type'],
      });

      return formulaId;
    } catch (e) {
      print("Error adding formula: $e");
       return null;
    }
  }

Future<List<Map<String, dynamic>>> fetchFormulaIngredients(int formulaId) async {
  print("Fetching formula ingredients for formula ID $formulaId from the database...");
  try {
    // Query to join `formula_ingredient` with `ingredients` table based on the ingredient_id
    final data = await db.rawQuery('''
      SELECT fi.ingredient_id, fi.amount, fi.dilution, fi.ratio, i.name, i.category
      FROM formula_ingredient fi
      INNER JOIN ingredients i ON fi.ingredient_id = i.id
      WHERE fi.formula_id = ?
    ''', [formulaId]);
    print("Fetched formula ingredients: $data");
    return data;
  } catch (e) {
    print("Error fetching formula ingredients: $e");
    return [];
  }
}

  // Add a new ingredient to a formula
  Future<void> addFormulaIngredient(int formulaId, int ingredientId, double amount, double dilution) async {
    final db = await DatabaseHelper().database;
    try {
      await db.insert('formula_ingredient', {
        'formula_id': formulaId,
        'ingredient_id': ingredientId,
        'amount': amount,
        'dilution': dilution
      });
      print("Formula ingredient added successfully.");
    } catch (e) {
      print("Error adding formula ingredient: $e");
    }
  }

  Future<void> updateIngredient(int ingredientId, double amount, double dilution) async {
    final db = await DatabaseHelper().database;
     print("updating ${ingredientId} with ${amount} and ${dilution} dil");
    await db.update(
      'formula_ingredient',
      {
        'amount': amount,
        'dilution': dilution,
      },
      where: 'id = ?',
      whereArgs: [ingredientId],
    );
  }

  Future<void> updateAllIngredients(int formulaId, List<Map<String, dynamic>> ingredients) async {
    final db = await DatabaseHelper().database;

    // Use a batch to perform all updates in a single transaction
    Batch batch = db.batch();
     print("updating all. ${ingredients} and id: ${formulaId}");

    for (var ingredient in ingredients) {
      batch.update(
        'formula_ingredient',
        {
          'amount': ingredient['amount'],
          'dilution': ingredient['dilution'],
        },
        where: 'formula_id = ? AND ingredient_id = ?',
        whereArgs: [formulaId, ingredient['ingredient_id']],
      );
    }

    await batch.commit(noResult: true);
  }

    // GET A SINGLE 
   Future<Map<String, dynamic>?> fetchFormulaForIFRA(int id) async {
    final db = await DatabaseHelper().database;
    print("Fetching formula with id: $id");
    try {
      final data = await db.query('formulas', where: 'id = ?', whereArgs: [id]);
      if (data.isNotEmpty) {
        print("Fetched formula: ${data.first}");
        return data.first;
      }
    } catch (e) {
      print("Error fetching formula: $e");
    }
    return null;
  }

    Future<List<Map<String, dynamic>>> fetchIfraStandards(String category) async {
  final db = await DatabaseHelper().database;

  try {
    // Query the `ifra_standards` table to fetch CAS numbers and limits for the specified category.
    final data = await db.rawQuery('''
      SELECT cas_numbers, $category
      FROM ifra_standards
    ''');

    // Log the fetched data
    // if (kDebugMode) {
      // print("Fetched IFRA standards for category $category: $data");
    // }

    return data;
  } catch (e) {
    // if (kDebugMode) {
      print("Error fetching IFRA standards: $e");
    // }
    return [];
  }
}

Future<List<String>> fetchCasNumbers(int ingredientId) async {
  final db = await DatabaseHelper().database;

  try {
    // Query the `cas_table` to fetch CAS numbers for the given ingredient ID
    final data = await db.query(
      'cas_numbers',
      columns: ['cas_number'],
      where: 'ingredient_id = ?',
      whereArgs: [ingredientId],
    );

    // Extract CAS numbers from the result
    List<String> casNumbers = data.map((e) => e['cas_number'] as String).toList();

    // if (kDebugMode) {
      print("Fetched CAS numbers for ingredient ID $ingredientId: $casNumbers");
    // }

    return casNumbers;
  } catch (e) {
    // if (kDebugMode) {
      print("Error fetching CAS numbers: $e");
    // }
    return [];
  }
}

Future<Map<String, dynamic>?> fetchFormulaById(int formulaId) async {
  final db = await DatabaseHelper().database;
  print("Fetching formula with id: $formulaId");

  try {
    final data = await db.query(
      'formulas',
      where: 'id = ?',
      whereArgs: [formulaId],
    );

   if (data.isNotEmpty) {
    final formula = Map<String, dynamic>.from(data.first); // Convert to mutable map
    print("Fetched formula: $formula");

    formula['is_accord'] = (formula['type'] == 'category_0'); // Modify safely
    print("formula with accord check: $formula");

    return formula;
  }
  } catch (e) {
    print("Error fetching formula: $e");
  }
  
  return null;
}


  Future<void> updateFormulaInputMode(int formulaId, bool isRatioInput) async {
  final isRatio = isRatioInput ? 1 : 0; // SQLite uses 1 for true and 0 for false
  await db.rawUpdate(
    'UPDATE formulas SET is_ratio_formula = ? WHERE id = ?',
    [isRatio, formulaId],
  );
}

Future<String?> getCategoryColor(String categoryName) async {
  try {
    final result = await db.query(
      'olfactive_categories',
      columns: ['color'],
      where: 'name = ?',
      whereArgs: [categoryName],
    );
    
    String? color = result.isNotEmpty ? result.first['color'] as String? : null;
    print("Fetched category color: $color for category: $categoryName");

    // If the fetched color is null or empty, return a default hex string
    return (color != null && color.isNotEmpty) ? color : '#CCCCCC';
  } catch (e) {
    print("Error fetching color for category $categoryName: $e");
    return '#CCCCCC'; // Return default if an error occurs
  }
}

// ACCORD MAGIC

Future<int?> getAccordIdByFormulaId(int formulaId) async {
  final db = await DatabaseHelper().database;
  final result = await db.query(
    'accords',
    columns: ['id'],
    where: 'formula_id = ?',
    whereArgs: [formulaId],
  );

  return result.isNotEmpty ? result.first['id'] as int : null;
}

Future<List<Map<String, dynamic>>> fetchAvailableAccords() async {
  final db = await DatabaseHelper().database;
  print("Fetching available accords...");

  try {
    final data = await db.rawQuery('''
      SELECT a.id, a.name, 
             (SELECT GROUP_CONCAT(ai.ingredient_id || ':' || ai.ratio, ',') 
              FROM accord_ingredients ai 
              WHERE ai.accord_id = a.id) AS ingredient_ratios
      FROM accords a;
    ''');

    print("Fetched ${data.length} accords.");
    return data;
  } catch (e) {
    print("Error fetching accords: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchAccordIngredients(int accordId) async {
  final db = await DatabaseHelper().database;
  print("Fetching ingredients for accord ID $accordId...");

  try {
    final data = await db.rawQuery('''
      SELECT ai.ingredient_id, ai.ratio, i.name
      FROM accord_ingredients ai
      INNER JOIN ingredients i ON ai.ingredient_id = i.id
      WHERE ai.accord_id = ?;
    ''', [accordId]);

    print("Fetched accord ingredients: $data");
    return data;
  } catch (e) {
    print("Error fetching accord ingredients: $e");
    return [];
  }
}

Future<int> addAccord(String accordName) async {
  final db = await DatabaseHelper().database;

  return await db.insert(
    'accords',
    {
      'name': accordName,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

Future<int?> getAccordIdByName(String accordName) async {
  final db = await DatabaseHelper().database;
  final result = await db.query(
    'accords',
    columns: ['id'],
    where: 'name = ?',
    whereArgs: [accordName],
  );
  return result.isNotEmpty ? result.first['id'] as int : null;
}



Future<void> addAccordIngredient(int accordId, int ingredientId, double ratio) async {
  final db = await DatabaseHelper().database;
  print("Saving ingredient $ingredientId with ratio $ratio for accord $accordId...");

  try {
    await db.insert(
      'accord_ingredients',
      {
        'accord_id': accordId,
        'ingredient_id': ingredientId,
        'ratio': ratio
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Ensures it updates duplicates
    );
    print("Ingredient added to accord.");
  } catch (e) {
    print("Error adding ingredient to accord: $e");
  }
}


Future<void> deleteAccordIngredient(int accordId, int ingredientId) async {
  final db = await DatabaseHelper().database;
  print("Deleting ingredient $ingredientId from accord $accordId...");

  try {
    await db.delete(
      'accord_ingredients',
      where: 'accord_id = ? AND ingredient_id = ?',
      whereArgs: [accordId, ingredientId],
    );
    print("Ingredient deleted from accord.");
  } catch (e) {
    print("Error deleting ingredient from accord: $e");
  }
 }

 Future<bool> isIngredientInInventory(int ingredientId) async {
  final db = await DatabaseHelper().database;
  final result = await db.query(
    'inventory',
    where: 'ingredient_id = ?',
    whereArgs: [ingredientId],
  );
  return result.isNotEmpty;
}

Future<void> addIngredientToInventory(int ingredientId) async {
  final db = await DatabaseHelper().database;
  await db.insert(
    'inventory',
    {
      'ingredient_id': ingredientId,
      'inventory_amount': 0.0,
      'acquisition_date': DateTime.now().toIso8601String(),
      'personal_notes': '',
      'cost_per_gram': 0.0,
      'preferred_synonym_id': null,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}



 

}