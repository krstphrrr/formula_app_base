import 'package:sqflite/sqflite.dart';
import 'package:core/core.dart';

class FormulaListRepository {
  final Database db;  // Inject SQLite database instance

  FormulaListRepository(this.db);

Future<List<Map<String, dynamic>>> fetchFormulas() async {
    final db = await DatabaseHelper().database;
     // Fetch the shared database instance
    try {
      print("Fetching formulas from the database...");
      final data = await db.query('formulas');
      print("Fetched formulas: $data");
      return data;  // Return the raw data to the provider
    } catch (e) {
      print("Error fetching formulas: $e");
      return [];  // Return an empty list in case of error
    }
  }

  Future<void> deleteFormula(int id) async {
    final db = await DatabaseHelper().database;
    print("Deleting formula with id: $id");
    try {
      await db.delete('formulas', where: 'id = ?', whereArgs: [id]);
      print("Formula deleted successfully.");
    } catch (e) {
      print("Error deleting formula: $e");
    }
  }


}
// Let's say that I have a couple of features, each with its own page: formula list page, formula add page, ingredient list page. each has it's own provider separate from the actual widget implementation. If occassionally there are moments where providers need information from the state of another provider, is it recommended to have crosstalk between providers? or should each provider populate its own state and keep it independently? for instance, formula add page needs to know about which formula Let's say that I have a couple of features, each with its own page: formula list page, formula add page, ingredient list page. each has it's own provider separate from the actual widget implementation. If occassionally there are moments where providers need information from the state of another provider, is it recommended to have crosstalk between providers? or should each provider populate its own state and keep it independently? for instance, formula add page needs to know about which formula 