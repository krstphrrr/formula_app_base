library settings_category;

import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:settings_category/state/settings_category_provider.dart';
import 'package:settings_category/domain/settings_category_service.dart';
import 'package:settings_category/data/settings_category_repository.dart';

export 'package:settings_category/data/settings_category_repository.dart';
export 'package:settings_category/domain/settings_category_service.dart';
export 'package:settings_category/state/settings_category_provider.dart';
export 'package:settings_category/presentation/settings_category_page.dart';

List<ChangeNotifierProvider<SettingsCategoryProvider>> loadFeatureProviders(Database db) {
  return [
    ChangeNotifierProvider<SettingsCategoryProvider>(
      create: (context) => SettingsCategoryProvider(
        SettingsCategoryService(SettingsCategoryRepository(db)),
      ),
    ),
  ];
}