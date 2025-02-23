library settings_data;

import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'state/settings_data_provider.dart';
import 'domain/settings_data_service.dart';
import 'data/settings_data_repository.dart';

export 'data/settings_data_repository.dart';
export 'domain/settings_data_service.dart';
export 'state/settings_data_provider.dart'; 
export 'presentation/settings_data_page.dart';

List<ChangeNotifierProvider> loadFeatureProviders(Database db) {
  return [
    ChangeNotifierProvider(
      create: (context) => SettingsDataProvider(
        SettingsDataService(SettingsDataRepository(db)),
      ),
    ),
  ];
}