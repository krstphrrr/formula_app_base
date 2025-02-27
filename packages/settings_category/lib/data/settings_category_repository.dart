import 'package:sqflite/sqflite.dart';

class SettingsCategoryRepository {
final Database db;  // Inject SQLite database instance

  SettingsCategoryRepository(this.db);

  Future<List<Map<String, dynamic>>> loadCategories() async {
    return await db.query('olfactive_categories');
  }

  Future<void> updateCategoryColor(String category, String colorHex) async {
    await db.update(
      'olfactive_categories',
      {'color': colorHex},
      where: 'name = ?',
      whereArgs: [category],
    );
    print(await db.query("olfactive_categories"));
  }

  Future<void> addNewCategory(String category) async {
    await db.insert('olfactive_categories', {'name': category, 'color': null});
  }

  Future<void> consolidateCategories(Map<String, String> categoryMapping) async {
    for (var entry in categoryMapping.entries) {
      await db.update(
        'olfactive_categories',
        {'name': entry.value},
        where: 'name = ?',
        whereArgs: [entry.key],
      );
    }
  }

  Future<void> updateCategoryName(String oldName, String newName) async {
    await db.update(
      'olfactive_categories',
      {'name': newName},
      where: 'name = ?',
      whereArgs: [oldName],
    );
  }

  Future<void> consolidateCategoriesWithDeduplication(Map<String, String> categoryMapping) async {
  final batch = db.batch();

  // Update categories to their consolidated names
  for (var entry in categoryMapping.entries) {
    batch.update(
      'olfactive_categories',
      {'name': entry.value},
      where: 'name = ?',
      whereArgs: [entry.key],
    );

        // Update corresponding categories in `ingredients`
    batch.update(
      'ingredients',
      {'category': entry.value},
      where: 'category = ?',
      whereArgs: [entry.key],
    );
  }

  

  await batch.commit(noResult: true);

  // Remove duplicates, keeping only the row with the smallest ID for each category
  final uniqueCategories = await db.rawQuery(
    '''
    SELECT MIN(id) as id, name 
    FROM olfactive_categories 
    GROUP BY name
    '''
  );

  final uniqueIds = uniqueCategories.map((e) => e['id']).toSet();

  await db.delete(
    'olfactive_categories',
    where: 'id NOT IN (${uniqueIds.join(',')})',
  );
}
}