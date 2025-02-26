import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;
  static const int _dbVersion = 1;  // Reset to version 1
  static const String _dbName = 'formula_manager.db';

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, _dbName);

  print("Initializing database at: $path"); 

  return await openDatabase(
    path,
    version: _dbVersion,
    onCreate: (db, version) async {
      print("Database is being created...");
      await _createTables(db);
      await _seedData(db);
    },
    onOpen: (db) {
      print("Database opened successfully!");
    },
  );
}

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedData(db);
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE formulas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        notes TEXT,
        creation_date TEXT,
        modified_date TEXT,
        is_ratio_formula BOOLEAN DEFAULT FALSE
      );
    ''');

    await db.execute('''
      CREATE TABLE accords (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          description TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE accord_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accord_id INTEGER NOT NULL,
        ingredient_id INTEGER NOT NULL,
        ratio REAL NOT NULL,
        FOREIGN KEY (accord_id) REFERENCES accords(id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
    );
    ''');

    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_id INTEGER,
        accord_id INTEGER,
        inventory_amount REAL DEFAULT 0,
        acquisition_date TEXT,
        personal_notes TEXT,
        cost_per_gram REAL, 
        preferred_synonym_id INTEGER, 
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE,
        FOREIGN KEY (preferred_synonym_id) REFERENCES ingredient_synonyms(id) ON DELETE SET NULL,
        FOREIGN KEY (accord_id) REFERENCES accords(id) ON DELETE CASCADE
    );
    ''');

    await db.execute('''
      CREATE TABLE formula_ingredient (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        formula_id INTEGER NOT NULL,
        ingredient_id INTEGER,
        accord_id INTEGER,
        amount REAL NOT NULL,
        dilution REAL DEFAULT 1.0,
        ratio REAL DEFAULT NULL,
        FOREIGN KEY (formula_id) REFERENCES formulas(id) ON DELETE CASCADE,
        FOREIGN KEY (accord_id) REFERENCES accords(id),
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
    );
    ''');

    // link between formula and inventory
    await db.execute('''
      CREATE TABLE formula_inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        formula_id INTEGER NOT NULL,
        inventory_id INTEGER NOT NULL,
        amount_used REAL NOT NULL,
        FOREIGN KEY (formula_id) REFERENCES formulas(id) ON DELETE CASCADE,
        FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON DELETE CASCADE
    );
    ''');

    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        cas_number TEXT,
        category TEXT, 
        description TEXT,
        pyramid_place TEXT,
        substantivity REAL,
        boiling_point REAL, 
        vapor_pressure REAL, 
        molecular_weight REAL, 
        preferred_synonym_id INTEGER,
        FOREIGN KEY (preferred_synonym_id) REFERENCES ingredient_synonyms(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE cas_numbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_id INTEGER,
        cas_number TEXT,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE ingredient_synonyms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_id INTEGER NOT NULL,
        synonym TEXT NOT NULL,
        source TEXT, -- (Optional) Notes on where this synonym comes from
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE,
        UNIQUE (ingredient_id, synonym) -- Prevent duplicate synonyms per ingredient
    );
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY,
        tag_name TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE ingredient_tags (
        ingredient_id INTEGER,
        tag_id INTEGER,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(id),
        FOREIGN KEY (tag_id) REFERENCES tags(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE ifra_standards (
        key TEXT PRIMARY KEY,
        amendment_number INTEGER,
        year_previous_publication TEXT,
        year_last_publication INTEGER,
        implementation_deadline_existing TEXT,
        implementation_deadline_new TEXT,
        name_of_ifra_standard TEXT,
        cas_numbers TEXT,
        cas_numbers_comment TEXT,
        synonyms TEXT,
        ifra_standard_type TEXT,
        intrinsic_property TEXT,
        flavor_use_consideration TEXT,
        prohibited_fragrance_notes TEXT,
        phototoxicity_notes TEXT,
        restricted_ingredients_notes TEXT,
        specified_ingredients_notes TEXT,
        contributions_other_sources TEXT,
        contributions_other_sources_notes TEXT,
        category_0 TEXT, 
        category_1 TEXT,
        category_2 TEXT,
        category_3 TEXT,
        category_4 TEXT,
        category_5a TEXT,
        category_5b TEXT,
        category_5c TEXT,
        category_5d TEXT,
        category_6 TEXT,
        category_7a TEXT,
        category_7b TEXT,
        category_8 TEXT,
        category_9 TEXT,
        category_10a TEXT,
        category_10b TEXT,
        category_11a TEXT,
        category_11b TEXT,
        category_12 TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE ifra_categories (
        category_id TEXT PRIMARY KEY,
        description TEXT NOT NULL
      );
    ''');

    await _createOlfactiveCategories(db);
  }

  Future<void> _createOlfactiveCategories(Database db) async {
    await db.execute('''
      CREATE TABLE olfactive_categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        color TEXT
      );
    ''');

    final categories = [
      'Aldehydic', 'Ambery', 'Citrus', 'Floral', 'Fruity',
      'Gourmand', 'Green', 'Herbal', 'Agrestic', 'Leather',
      'Moss', 'Marine', 'Musky', 'Spicy', 'Terpenic', 'Woody'
    ];

    for (var category in categories) {
      await db.insert('olfactive_categories', {'name': category, 'color': null});
    }
  }

  Future<void> _seedData(Database db) async {
    final ifraCategories = [
      {'category_id': 'category_0', 'description': 'Accords'},
      {'category_id': 'category_1', 'description': 'Lip Products/Toys'},
      {'category_id': 'category_2', 'description': 'Deodorant/Antiperspirant'},
      {'category_id': 'category_3', 'description': 'Eye Products'},
      {'category_id': 'category_4', 'description': 'Perfume'},
      {'category_id': 'category_5a', 'description': 'Body Creams'},
      {'category_id': 'category_5b', 'description': 'Face Creams'},
      {'category_id': 'category_5c', 'description': 'Hand Sanitizers'},
      {'category_id': 'category_5d', 'description': 'Baby Products'},
      {'category_id': 'category_6', 'description': 'Mouthwash'},
      {'category_id': 'category_7a', 'description': 'Rinse off Hair Treatments'},
      {'category_id': 'category_7b', 'description': 'Leave on Hair Treatments'},
      {'category_id': 'category_8', 'description': 'Intimate Wipes'},
      {'category_id': 'category_9', 'description': 'Soap/Shampoo'},
      {'category_id': 'category_10a', 'description': 'Household Cleaning'},
      {'category_id': 'category_10b', 'description': 'Air Freshener Sprays'},
      {'category_id': 'category_11a', 'description': 'Diapers'},
      {'category_id': 'category_11b', 'description': 'Scented Clothing'},
      {'category_id': 'category_12', 'description': 'Candles/Incense'}
    ];

    for (var category in ifraCategories) {
      await db.insert('ifra_categories', category);
    }
  }
}
