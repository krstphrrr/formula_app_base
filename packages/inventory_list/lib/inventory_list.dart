library inventory_list;

import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:inventory_list/state/inventory_list_provider.dart';
import 'package:inventory_list/domain/inventory_list_service.dart';
import 'package:inventory_list/data/inventory_list_repository.dart';

export 'package:inventory_list/data/inventory_list_repository.dart';
export 'package:inventory_list/domain/inventory_list_service.dart';
export 'package:inventory_list/state/inventory_list_provider.dart';
export 'package:inventory_list/presentation/inventory_list_page.dart';

List<ChangeNotifierProvider<InventoryListProvider>> loadFeatureProviders(Database db) {
  return [
    ChangeNotifierProvider<InventoryListProvider>(
      create: (context) => InventoryListProvider(
        InventoryListService(InventoryListRepository(db)),
      ),
    ),
  ];
}