import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:core/core.dart';

class FormulaAddRepository {
  final Database db;  // Inject SQLite database instance

  FormulaAddRepository(this.db);

// GET A SINGLE 
   Future<Map<String, dynamic>?> fetchFormula(int id) async {
    final db = await DatabaseHelper().database;
    print("Fetching formula with id: $id");
    try {
      final data = await db.query('formulas', where: 'id = ?', whereArgs: [id]);
      if (data.isNotEmpty) {
        if (kDebugMode) {
          print("Fetched formula: ${data.first}");
        }
        return data.first;
      }
    } catch (e) {
      print("Error fetching formula: $e");
    }
    return null;
  }

    Future<void> addFormula(Map<String, dynamic> formula) async {
    final db = await DatabaseHelper().database;
    print("Adding new formula with name: ${formula['name']}");
    try {
      await db.insert('formulas', {
        'name': formula['name'],
        'creation_date': formula['creation_date'],
        'notes': formula['notes'],
        'type': formula['type'],
      });
      print("Formula added successfully.");
    } catch (e) {
      print("Error adding formula: $e");
    }
  }

  Future<List<Map<String, dynamic>>> loadCategories() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> categoryData = await db.query('ifra_categories');

    return categoryData;
  }

  Future<void> updateFormula(int id, Map<String, dynamic> updatedFormula) async {
    await db.update(
      'formulas',
      updatedFormula,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
}