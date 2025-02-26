import 'package:flutter/material.dart';
import 'package:inventory_list/inventory_list.dart';

class InventoryListProvider extends ChangeNotifier {
  // properties
  final InventoryListService _service;
  InventoryListProvider(this._service);

  List<Map<String, dynamic>> _filteredInventory = [];
  List<Map<String, dynamic>> get filteredInventory => _filteredInventory;

  List<Map<String, dynamic>> _inventoryItems = [];
  List<Map<String, dynamic>> get inventoryItems => _inventoryItems;

  Map<String, dynamic>? _singleIngredientDetails = {};
  Map<String, dynamic>? get singleIngredientDetails => _singleIngredientDetails;

  bool _isLoading = false;
  bool _hasError = false;
  bool isReverseSortEnabled = false;

  bool isExporting = false;
  bool isImporting = false;
  String? csvPath;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;

  String? lastSortOption;

  final Map<String, Color> _categoryColorCache = {};

  int get totalInventory => _inventoryItems.length;

  Map<String, Color> _categoryColors = {};



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void clearControllers() {
    // _selectedIngredient = null;
    _searchController.clear();
    notifyListeners(); // Ensure UI gets updated
  }

  set inventoryItems(List<Map<String, dynamic>> value) {
    _inventoryItems = value;
    notifyListeners();
  }

  // methods
  Future<void> fetchInventory() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
        _inventoryItems = await _service.fetchInventory();
        _filteredInventory = _inventoryItems;

        // Assign colors based on category if available
        for (var item in _inventoryItems) {
            final category = item['category'];
            if (_categoryColors.containsKey(category)) {
                item['color'] = _categoryColors[category];
            }
        }
    } catch (e) {
        _hasError = true;
        print("Error loading inventory: $e");
    } finally {
        _isLoading = false;
        notifyListeners();
    }
}


  Future<void> deleteInventoryItem(int inventoryItemId) async {
    _isLoading = true;
    _hasError = false;
    try {
        await _service.deleteInventoryItem(inventoryItemId);
        clearControllers();
    } catch (e) {
        _hasError = true;
        print("Error deleting inventory item: $e");
    } finally {
        _isLoading = false;
        notifyListeners();
        fetchInventory();
    }
}


  void sortInventory(String criterion) {
    _filteredInventory.sort((a, b) {
        switch (criterion) {
            case 'cost':
                double costA = double.tryParse(a['cost_per_gram']?.toString() ?? '0') ?? 0.0;
                double costB = double.tryParse(b['cost_per_gram']?.toString() ?? '0') ?? 0.0;
                return costA.compareTo(costB);

            case 'acquisition_date':
                DateTime dateA = DateTime.parse(a['acquisition_date']?.toString() ?? '2000-01-01');
                DateTime dateB = DateTime.parse(b['acquisition_date']?.toString() ?? '2000-01-01');
                return dateA.compareTo(dateB);

            case 'inventory_amount':
                double amountA = double.tryParse(a['inventory_amount']?.toString() ?? '0') ?? 0.0;
                double amountB = double.tryParse(b['inventory_amount']?.toString() ?? '0') ?? 0.0;
                return amountA.compareTo(amountB);

            case 'name':
            default:
                return a['name'].toString().compareTo(b['name'].toString());
        }
    });

    if (isReverseSortEnabled) {
        _filteredInventory = _filteredInventory.reversed.toList();
    }

    notifyListeners();
}


  void reverseSort() {
    isReverseSortEnabled = !isReverseSortEnabled;
    _filteredInventory = _filteredInventory.reversed.toList();
    notifyListeners();
  }

  Future<void> importData(BuildContext context) async {
    isImporting = true;
    notifyListeners();
    try {
      final result = await _service.pickCSVLocation();
      if (result != null) {
        String filePath = result.files.single.path!;
        await _service.importFromCSV(filePath);
        // Check if the widget is still mounted before showing the Snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data imported successfully!')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to import csv: $e')));
      }
    } finally {
      isImporting = false;
      notifyListeners();
    }
  }

  Future<void> exportData(BuildContext context) async {
    isExporting = true;
    notifyListeners();

    try {
        String? filePath = await _service.exportPathPicker();

        if (filePath != null) {
            await _service.exportCSV(filePath);
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inventory data exported successfully!'))
                );
            }
        } else {
            if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to select file for export.'))
                );
            }
        }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
        isExporting = false;
        notifyListeners();
    }
}


  Future<Color> getCategoryColor(String categoryName) async {
    // Check if color is already in cache
    // if (_categoryColorCache.containsKey(categoryName)) {
    //   return _categoryColorCache[categoryName]!;
    // }

    // Fetch color from service and cache it
    final color = await _service.getCategoryColor(categoryName);
    _categoryColorCache[categoryName] = color;
    return color;
  }

  // Method to update a specific category's color
  void updateCategoryColor(String category, Color color) {
    _categoryColors[category] = color;

    // Update colors in the ingredient list as well
    for (var ingredient in _inventoryItems) {
      if (ingredient['category'] == category) {
        ingredient['color'] = color;
      }
    }

    notifyListeners(); // Notify to refresh UI with new color
  }

  // filter inventoryIngredients logic

  void filterInventory(String query) {
    final keywords = query.toLowerCase().split(' ');

    _filteredInventory = _inventoryItems.where((item) {
        final commonName = item['name']?.toLowerCase() ?? '';
        final personalNotes = item['personal_notes']?.toLowerCase() ?? '';
        final acquisitionDate = item['acquisition_date']?.toLowerCase() ?? '';
        final cost = item['cost_per_gram']?.toString() ?? '';
        final inventoryAmount = item['inventory_amount']?.toString() ?? '';
        final preferredSynonym = item['preferred_synonym']?.toLowerCase() ?? '';

        return keywords.every((keyword) {
            return commonName.contains(keyword) ||
                personalNotes.contains(keyword) ||
                acquisitionDate.contains(keyword) ||
                cost.contains(keyword) ||
                inventoryAmount.contains(keyword) ||
                preferredSynonym.contains(keyword);
        });
    }).toList();

    notifyListeners();
}

  Future<void> addToInventory({
    int? ingredientId,
    int? accordId,
    double amount = 0.0,
    double costPerGram = 0.0,
    String acquisitionDate = '',
    String personalNotes = '',
    int? preferredSynonymId,
}) async {
    if (ingredientId == null && accordId == null) {
        print("Error: No valid ingredient or accord selected.");
        return;
    }

    await _service.addToInventory(
        ingredientId: ingredientId,
        accordId: accordId,
        amount: amount,
        costPerGram: costPerGram,
        acquisitionDate: acquisitionDate,
        personalNotes: personalNotes,
        preferredSynonymId: preferredSynonymId,
    );

    fetchInventory(); // Refresh the list after adding an item
}

}
