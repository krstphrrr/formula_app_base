import 'dart:ui';

import 'package:settings_category/settings_category.dart';

class SettingsCategoryService {
final SettingsCategoryRepository _repository;

SettingsCategoryService(this._repository);

Future<List<Map<String, dynamic>>> fetchCategories() async {
    return await _repository.loadCategories();
  }

  Future<void> updateCategoryColor(String category, Color color) async {
    final colorHex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
    await _repository.updateCategoryColor(category, colorHex);
  }

  Future<void> addCategory(String category) async {
    await _repository.addNewCategory(category);
  }

  Future<void> consolidateCategories(Map<String, String> categoryMapping) async {
    await _repository.consolidateCategories(categoryMapping);
  }

  Future<void> updateCategoryName(String oldName, String newName) async {
    await _repository.updateCategoryName(oldName, newName);
  }

  Future<void> consolidateCategoriesWithDeduplication(Map<String, String> categoryMapping) async {
  await _repository.consolidateCategoriesWithDeduplication(categoryMapping);
}
}