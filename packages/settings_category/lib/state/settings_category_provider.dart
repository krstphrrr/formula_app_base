import 'package:flutter/material.dart';
import 'package:inventory_list/inventory_list.dart';
import 'package:provider/provider.dart';
import 'package:settings_category/settings_category.dart';

import '../domain/settings_category_service.dart';

class SettingsCategoryProvider extends ChangeNotifier {

  final SettingsCategoryService _service;
  SettingsCategoryProvider(this._service);

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  
  Color? _selectedColor;
  Color? get selectedColor => _selectedColor;

  final TextEditingController _newCategoryController = TextEditingController();
  TextEditingController get newCategoryController => _newCategoryController;
  // Database? db;
   VoidCallback? onColorUpdated;

  void clearSelection() {
    _selectedCategory = null;
    _selectedColor = null;
    notifyListeners();
  }

  
  Future<void> loadCategories() async {
    _categories = await _service.fetchCategories();
     print("Categories:");
  for (var category in _categories) {
    print(category);
  }
    notifyListeners();
  }

void selectCategory(String category) {
  _selectedCategory = category;
  
  // Find the category's current color if it exists
  final selectedCategoryData = _categories.firstWhere(
    (cat) => cat['name'] == category,
    orElse: () => {},
  );

  if (selectedCategoryData['color'] != null) {
    // Parse color hex from database to Color object
    _selectedColor = Color(int.parse(selectedCategoryData['color'].replaceFirst('#', '0xFF')));
  } else {
    _selectedColor = null; // No color assigned
  }

  notifyListeners();
}

  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  Future<void> saveCategoryColor(BuildContext context) async {
    if (selectedCategory != null && selectedColor != null) {
      await _service.updateCategoryColor(selectedCategory!, selectedColor!);
      await loadCategories(); // Refresh the list after update

      // Notify InventoryListProvider of the new color
      final inventoryListProvider = Provider.of<InventoryListProvider>(context, listen: false);
      inventoryListProvider.updateCategoryColor(selectedCategory!, selectedColor!);
      clearSelection();
    }
  }

  Future<void> addCategory(String category) async {
    await _service.addCategory(category);
    await loadCategories(); // Refresh list after adding
  }

    Future<void> consolidateCategories() async {
    final Map<String, String> categoryMapping = {
      // Citrus
  'mandarin': 'citrus',
  'orange': 'citrus',
  'lemon': 'citrus',
  'citrus': 'citrus',
  'bergamot': 'citrus',

  // Floral
  'floral': 'floral',
  'rose': 'floral',
  'jasmine': 'floral',
  'lavender': 'floral',
  'orris': 'floral',
  'muguet': 'floral',
  'violet': 'floral',
  'geranium': 'floral',
  'citronella': 'floral',

  // Herbal
  'tea': 'herbal',
  'herbal': 'herbal',
  'camphoreous': 'herbal',
  'eucalyptus': 'herbal',
  'aromatic': 'herbal',
  'minty': 'herbal',
  'dill': 'herbal',
  'sage': 'herbal',
  'thyme': 'herbal',

  // Fruity
  'fruity': 'fruity',
  'melon': 'fruity',
  'berry': 'fruity',
  'apple': 'fruity',
  'pear': 'fruity',
  'banana': 'fruity',
  'peach': 'fruity',
  'pineapple': 'fruity',
  'mango': 'fruity',
  'tropical': 'fruity',

// Ambery
  'amber': 'ambery',
  'ambery': 'ambery',
  'ambergris': 'ambery',

  // Woody
  
  'woody': 'woody',
  'pine': 'woody',
  'cedar': 'woody',
  'sandalwood': 'woody',
  'resinous': 'terpenic',
  'tobacco': 'woody',

  // Balsamic
  'balsamic': 'balsamic',
  'balsam': 'balsamic',



  // Spicy
  'spicy': 'spicy',
  'peppery': 'spicy',
  'clove': 'spicy',
  'cinnamon': 'spicy',
  'cardamom': 'spicy',
  'ginger': 'spicy',
  'nutmeg': 'spicy',
  'cumin': 'spicy',
  'saffron': 'spicy',
  'licorice': 'spicy',
  'anise': 'spicy',
  'fennel': 'spicy',
  'caraway': 'spicy',
  'coriander': 'spicy',
  'anisic': 'spicy',
  'cuminic': 'spicy',
  'carvone': 'spicy',


  // Sweet
  'sweet': 'sweet',
  'chocolate': 'sweet',
  'cocoa': 'sweet',
  'cacao': 'sweet',
  'vanilla': 'sweet',
  'caramellic': 'sweet',
  'honey': 'sweet',
  'candy': 'sweet',
  'sugar': 'sweet',
  'tonka': 'sweet',
  'marshmallow': 'sweet',
  'cotton candy': 'sweet',
  'gourmand': 'sweet',
  'coumarin': 'sweet',
  'coumarinic': 'sweet',
  'fenugreek': 'sweet',
  'maple': 'sweet',
  'coffee': 'sweet',
  'jammy': 'sweet',
  'hay': 'sweet',
  'hay-like': 'sweet',
  

  // Nutty
  'nutty': 'nutty',
  'almond': 'nutty',
  'hazelnut': 'nutty',
  'peanut': 'nutty',

  // Earthy
  'earthy': 'earthy',
  // 'moss': 'earthy',
  'mushroom': 'earthy',
  'truffle': 'earthy',
  'soil': 'earthy',
  'fungal': 'earthy',
  'musty': 'earthy',
  'dirt': 'earthy',
  'dusty': 'earthy',
  'humus': 'earthy',
  'geosmin': 'earthy',
  'geosminic': 'earthy',
  'geosminous': 'earthy',
  'brown': 'earthy',
  'soily': 'earthy',
  'rooty': 'earthy',
  'potato': 'earthy',


  // Fresh
  'fresh': 'green',
  'green': 'green',
  'grassy': 'green',
  'watercress': 'green',
  'agrestic': 'green',
  'vegetable': 'green',
  'cucumber': 'green',

  // Marine
  'marine': 'marine',
  'ocean': 'marine',
  'seaweed': 'marine',
  'algae': 'marine',
  'salty': 'marine',

  // terpe
  'terpenic': 'terpenic',
  'terpene': 'terpenic',
  'turpentine': 'terpenic',
  'pinene': 'terpenic',
  'thujone': 'terpenic',
  'thujonic': 'terpenic',
  'fir needle': 'terpenic',
  'pine needle': 'terpenic',



  // Smoky
  'smoky': 'smoky',
  'burnt': 'smoky',
  'roasted': 'smoky',
  'ash': 'smoky',
  'toasted': 'smoky',

  // Musky
  'musky': 'musky',
  'musk': 'musky',
  'animal': 'musky',
  'clean': 'musky',

  // Powdery
  'powdery': 'powdery',
  'soapy': 'powdery',

  // Chemical
  'chemical': 'chemical',
  'phenolic': 'chemical',
  'solvent': 'chemical',
  'plastic': 'chemical',
  'styrene': 'chemical',
  'rubber': 'chemical',
  'petroleum': 'chemical',
  'gasoline': 'chemical',
  'acrylate': 'chemical',
  'ethereal': 'chemical',
  'acetone': 'chemical',
  'metallic': 'chemical',
  'estery': 'chemical',
  'rubbery': 'chemical',


  // Medicinal
  'medicinal': 'medicinal',
  'mentholic': 'medicinal',
  'camphor': 'medicinal',
  'band-aid': 'medicinal',
  'iodine': 'medicinal',
  'hospital': 'medicinal',
  'napthalene': 'medicinal',
  'naphthyl': 'medicinal',
  'mothball': 'medicinal',
  'cooling': 'medicinal',
  'menthol': 'medicinal',
  'eugenol': 'medicinal',
  'ammoniacal': 'medicinal',
  'ammonia': 'medicinal',
  'dry': 'medicinal',
  'astringent': 'medicinal',
  'bitter': 'medicinal',

  // sour
  'sour': 'sour',
  'acidic': 'sour',
  'tart': 'sour',
  'acetic': 'sour',
  'pungent': 'sour',
  // 'citric': 'sour',

  // rummy
  'rummy': 'rummy',
  'rum': 'rummy',
  'whiskey': 'rummy',
  'bourbon': 'rummy',
  'brandy': 'rummy',
  'cognac': 'rummy',
  'winey': 'rummy',
  'wine': 'rummy',
  'alcoholic': 'rummy',


  // mossy
  'mossy': 'mossy',
  'moss': 'mossy', 
  'lichen': 'mossy',
  'lichenous': 'mossy',

  // Savory
  'dairy': 'savory',
  'savory': 'savory',
  'umami': 'savory',
  'meaty': 'savory',
  'cheesy': 'savory',
  'bready': 'savory',
  'fermented': 'savory',
  'allium': 'savory',
  'alliaceous': 'savory',
  'onion': 'savory',
  'garlic': 'savory',
  'chive': 'savory',
  'leek': 'savory',
  'scallion': 'savory',
  'shallot': 'savory',
  'sulfur': 'savory',
  'sulfurous': 'savory',
  'moldy': 'savory',
  'mold': 'savory',
  'rancid': 'savory',
  'malty': 'savory',
  'yeasty': 'savory',
  'buttery': 'savory',
  'popcorn': 'savory',
  'gassy': 'savory',
  'cooked': 'savory',
  'cabbage': 'savory',
  'broccoli': 'savory',
  'cauliflower': 'savory',
  'brussels sprout': 'savory',
  'radish': 'savory',
  'turnip': 'savory',
  'mustard': 'savory',
  'bean': 'savory',
  'beany': 'savory',
  'fishy': 'savory',
  'starchy': 'savory',
  'cereal': 'savory',
  'corn chip': 'savory',
  'kokumi': 'savory',
  'fried': 'savory',
  'seafood': 'savory',

  // lactonic
  'coconut': 'lactonic',
  'lactonic': 'lactonic',
  'milky': 'lactonic',
  'creamy': 'lactonic',

  // 
  'aldehydic': 'aldehydic',
  'waxy': 'aldehydic',
  'fat': 'aldehydic',
  'fatty': 'aldehydic',
  'oily': 'aldehydic',
  'tallow': 'aldehydic',

  
  // Animalic
  'animalic': 'animalic',
  'leathery': 'animalic',
  'sweaty': 'animalic',
  'urinous': 'animalic',
  'leather': 'animalic',
  'civet': 'animalic',
  'goaty': 'animalic',
  'mutton': 'animalic',

  // Default
  'unknown': 'unknown',
  'odorless': 'unknown',
     };

  // Convert the keys of the mapping to lowercase
  final lowerCaseMapping = categoryMapping.map((key, value) => MapEntry(key.toLowerCase(), value));

  // Fetch all categories from the database
  final categories = await _service.fetchCategories();

  // Normalize and update each category based on the mapping
  for (var category in categories) {
    var categoryName = category['name'].toString().toLowerCase();

    // Remove prefixes like 'Flavor Type: ' from the category name
    if (categoryName.startsWith('flavor type:')) {
      categoryName = categoryName.replaceFirst('flavor type:', '').trim();
    }

    if (lowerCaseMapping.containsKey(categoryName)) {
      final newCategoryName = lowerCaseMapping[categoryName]!;
      await _service.updateCategoryName(category['name'], newCategoryName);
    }
  }
  await _service.consolidateCategoriesWithDeduplication(lowerCaseMapping);
  await loadCategories(); // Reload the updated categories
}


  
}