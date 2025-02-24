library settings_data;

import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:settings_data/state/settings_data_provider.dart';
import 'package:settings_data/domain/settings_data_service.dart';
import 'package:settings_data/data/settings_data_repository.dart';

export 'package:settings_data/data/settings_data_repository.dart';
export 'package:settings_data/domain/settings_data_service.dart';
export 'package:settings_data/state/settings_data_provider.dart';
export 'package:settings_data/presentation/settings_data_page.dart';

List<ChangeNotifierProvider<SettingsDataProvider>> loadFeatureProviders(Database db) {
  return [
    ChangeNotifierProvider<SettingsDataProvider>(
      create: (context) => SettingsDataProvider(
        SettingsDataService(SettingsDataRepository(db)),
      ),
    ),
  ];
}