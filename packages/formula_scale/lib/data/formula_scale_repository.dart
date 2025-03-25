import 'package:sqflite/sqflite.dart';
import 'package:core/core.dart';

class FormulaScaleRepository {
  final db;

  FormulaScaleRepository(this.db);
  
   // Fetch all ingredients for a specific formula
 Future<List<Map<String, dynamic>>> fetchFormulaIngredients(int formulaId) async {
  print("Fetching formula ingredients for formula ID $formulaId from the database...");
  try {
    // Query to join `formula_ingredients` with `ingredients` table based on the ingredient_id
    final data = await db.rawQuery('''
      SELECT fi.ingredient_id, fi.amount, fi.dilution, fi.ratio, i.name
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
}