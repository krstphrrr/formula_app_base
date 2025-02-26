import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:core/core.dart';

class InventoryListRepository {
  final Database db;  // Inject SQLite database instance

  InventoryListRepository(this.db);

  Future<List<Map<String, dynamic>>> fetchAllInventory() async {
    final db = await DatabaseHelper().database;  // Fetch the shared database instance

    if (kDebugMode) {
      print("Fetching inventoryIngredients from the database...");
    }
    try {
      var inventoryIngredientsData =await db.rawQuery('''
              SELECT inv.id, 
                    COALESCE(i.name, a.name) AS name, 
                    inv.inventory_amount, inv.acquisition_date, 
                    inv.personal_notes, inv.cost_per_gram, 
                    s.synonym AS preferred_synonym,
                    (SELECT GROUP_CONCAT(c.cas_number, ', ') 
                      FROM cas_numbers c 
                      WHERE c.ingredient_id = i.id) AS cas_numbers
              FROM inventory inv
              LEFT JOIN ingredients i ON i.id = inv.ingredient_id
              LEFT JOIN accords a ON a.id = inv.accord_id
              LEFT JOIN ingredient_synonyms s ON s.id = inv.preferred_synonym_id
            ''');
      if (kDebugMode) {
        print("Fetched inventoryIngredients: $inventoryIngredientsData");
      }

      // For each inventoryIngredient, also fetch the related CAS numbers
      List<Map<String, dynamic>> updatedInventory = [];

      for (var inventoryIngredient in inventoryIngredientsData) {
        // Make a mutable copy of the inventoryIngredient map
        var inventoryIngredientCopy = Map<String, dynamic>.from(inventoryIngredient);

        var inventoryIngredientId = inventoryIngredient['id'];
        var casNumbersData = await db.query('cas_numbers',
            where: 'ingredient_id = ?', whereArgs: [inventoryIngredientId]);

        // Extract CAS numbers and add them to the inventoryIngredient map
        List<String> casNumbers =
            casNumbersData.map((cas) => cas['cas'].toString()).toList();
        inventoryIngredientCopy['cas'] = casNumbers;

        updatedInventory.add(inventoryIngredientCopy);
      }

    if (kDebugMode) {
      print("Fetched updated inventoryIngredients: $updatedInventory");
    }
    return updatedInventory; // Update the provider's inventoryIngredients list

    } catch (e) {
      if (kDebugMode) {
        print("Error fetching inventoryIngredients: $e");
      }
      return [];
    }
  }
    Future<void> deleteInventoryItem(int id) async {
    final db = await DatabaseHelper().database;
    try {
        await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
        print("Deleted inventory item with id: $id");
    } catch (e) {
        print("Error deleting inventory item: $e");
    }
}

    Future<void> insertInventoryItem(Map<String, dynamic> inventoryItem) async {
    final db = await DatabaseHelper().database;

    try {
        await db.insert('inventory', inventoryItem);
        print("Inserted inventory item: $inventoryItem");
    } catch (e) {
        print("Failed to insert inventory item: $e");
    }
}

    Future<void> addCASNumber(int inventoryIngredientId, String cas) async {
    final db = await DatabaseHelper().database;
    // if (kDebugMode) {
    print("Adding CAS number $cas for inventoryIngredient $inventoryIngredientId");
    // }
    try {
      await db.insert('cas_numbers', {
        'ingredient_id': inventoryIngredientId,
        'cas_number': cas,
      });
      // if (kDebugMode) {
      print("CAS number added successfully.");
      // }
    } catch (e) {
      // if (kDebugMode) {
      print("Error adding CAS number: $e");
      // }
    }
  }

    Future<String?> getCategoryColor(String categoryName) async {
    // Query the olfactive_categories table for the color based on the category name
    final result = await db.query(
      'olfactive_categories',
      columns: ['color'],
      where: 'name = ?',
      whereArgs: [categoryName],
    );

    // Return the color if found; otherwise, return null
    return result.isNotEmpty ? result.first['color'] as String? : null;
  }




}