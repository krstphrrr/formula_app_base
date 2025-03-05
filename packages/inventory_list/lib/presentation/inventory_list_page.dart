import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'package:formula_composer/features/ingredient_edit/state/ingredient_edit_provider.dart';
import 'package:inventory_list/inventory_list.dart';
import 'package:core/core.dart';
// import '../../ingredient_edit/presentation/ingredient_edit_page.dart';
// import '../../ingredient_view/presentation/ingredient_view_page.dart';

class InventoryListPage extends StatefulWidget {
  const InventoryListPage({Key? key}) : super(key: key);

  @override
  _InventoryListPageState createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {

@override
void initState() {
  super.initState();

  Future.microtask(() async {
    if (!mounted) return; // Ensure widget is still in the tree
    final inventoryProvider =
        Provider.of<InventoryListProvider>(context, listen: false);

    if (inventoryProvider.inventoryItems.isEmpty) { // Prevent unnecessary calls
      await inventoryProvider.fetchInventory();
    }
  });
}

 Future<void> openDeleteBox(int inventoryIngredientId) async {
  final inventoryListProvider =
      Provider.of<InventoryListProvider>(context, listen: false);

  // Fetch the inventory using the ID from the original list
 final inventoryIngredient = inventoryListProvider.inventoryItems.firstWhere(
  (inventoryIngredient) => inventoryIngredient['id'] == inventoryIngredientId,
  orElse: () => <String, dynamic>{}, // Return an empty map instead of null
);

if (inventoryIngredient.isEmpty) return;// Exit if inventoryIngredient is not found

  // Show a confirmation dialog before deletion
  final confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Inventory'),
        content: const Text('Are you sure you want to delete this inventoryIngredient?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    await inventoryListProvider.deleteInventoryItem(inventoryIngredientId);

    // setState(() {
      inventoryListProvider.fetchInventory(); // Rebuild after fetching inventoryItems
      // Provider.of<InventoryEditProvider>(context, listen: false)
      //     .clearControllers();
    // });
  }
}


void openEditBox(int inventoryIngredientId) {
  final inventoryListProvider =
      Provider.of<InventoryListProvider>(context, listen: false);

  // Fetch the inventory using the ID from the original list
  final inventoryIngredient = inventoryListProvider.inventoryItems.firstWhere(
  (inventoryIngredient) => inventoryIngredient['id'] == inventoryIngredientId,
  orElse: () => <String, dynamic>{}, // Return an empty map instead of null
);

if (inventoryIngredient.isEmpty) return;
  // if (inventoryIngredient == null) return; 

  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => InventoryEditPage(
  //       inventoryIngredientId: inventoryIngredientId,
  //     ),
  //   ),
  // ).then((_) {
  //   Provider.of<InventoryListProvider>(context, listen: false)
  //       .fetchInventory();
  // });
}
  void _showSortDialog() {
  final inventoryProvider =
      Provider.of<InventoryListProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('Name'),
              onTap: () {
                Navigator.pop(context);
                inventoryProvider.sortInventory('name');
              },
            ),
            ListTile(
              title: const Text('Acquisition Date'),
              onTap: () {
                Navigator.pop(context);
                inventoryProvider.sortInventory('acquisition_date');
              },
            ),
            ListTile(
              title: const Text('Inventory Amount'),
              onTap: () {
                Navigator.pop(context);
                inventoryProvider.sortInventory('inventory_amount');
              },
            ),
            ListTile(
              title: const Text('Cost per Gram'),
              onTap: () {
                Navigator.pop(context);
                inventoryProvider.sortInventory('cost_per_gram');
              },
            ),
          ],
        ),
      );
    },
  );
}


void openViewPage(int inventoryIngredientId) {
  // Navigator.of(context).push(
  //   MaterialPageRoute(
  //     builder: (context) => InventoryViewPage(
  //       inventoryIngredientId: inventoryIngredientId,
  //     ),
  //   ),
  // );
}
String currentIconSet = 'bat-a-clear'; // Default icon set
// bat-b-clear
// bat-a-grey
// pyramid-clear
String getAssetPath(String pyramidPlace) {
  // Define the base path for the selected icon set
  final basePath = 'assets/images/$currentIconSet/4x/';

  // Map pyramid place values to corresponding asset file names
  final iconMap = {
    'top': '${currentIconSet}-topxxxhdpi.png',
    'top-mid': '${currentIconSet}-top_midxxxhdpi.png',
    'mid': '${currentIconSet}-midxxxhdpi.png',
    'mid-base': '${currentIconSet}-mid_basexxxhdpi.png',
    'base': '${currentIconSet}-basexxxhdpi.png',
    'none': '${currentIconSet}-nonexxxhdpi.png', // Default case
  };

  // Return the asset path based on the pyramid place or use 'none' as default
  return basePath + (iconMap[pyramidPlace] ?? iconMap['none']!);
}
  @override
  Widget build(BuildContext context) {
    final inventoryListProvider =
        Provider.of<InventoryListProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Inventory'),
        actions: [
            // Export Button
            IconButton(
              icon: const Icon(Icons.file_upload),
              onPressed: () {
                inventoryListProvider.exportData(context);
              }, // Call export function
            ),
            // Import Button
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () {
                inventoryListProvider.importData(context);
              }, // Call import function,
            ),
        ],
      ),
      body: Consumer<InventoryListProvider>(
        builder: (context, inventoryListProvider, child) {
          final inventoryItems = inventoryListProvider.filteredInventory;
          if (inventoryListProvider.isLoading) {
            // Show loading spinner while fetching data
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (inventoryListProvider.inventoryItems.isEmpty) {
            // Show message if no inventoryItems are found
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('No inventoryItems found in the database.')],
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: inventoryListProvider.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search inventoryItems',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: inventoryListProvider.filterInventory,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _showSortDialog,
                      child: const Text('Sort'),
                    ),
                    // Display the total number of inventoryItems
                    Text(
                      'Total: ${inventoryListProvider.totalInventory}',
                      style: TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: inventoryListProvider.reverseSort,
                      child: const Text('Reverse Sort'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: inventoryItems.length,
                    itemBuilder: (context, index) {
                      final inventoryItem = inventoryItems[index];

                      // Ensure proper field mapping
                      String assetPath = getAssetPath(inventoryItem['pyramid_place'] ?? 'assets/images/pyramid-clear/4x/pyramid-clear-nonexxxhdpi.png');
                      final casNumbers = inventoryItem['cas_numbers'] ?? 'N/A';
                      final subtitle = 'Amount: ${inventoryItem['inventory_amount']} g'
                          '\nCost/g: \$${inventoryItem['cost_per_gram'].toStringAsFixed(2)}'
                          '\nSynonym: ${inventoryItem['preferred_synonym'] ?? "N/A"}'
                          '\nCAS: ${casNumbers.toString()}'; // Ensure it's a string

                      return FutureBuilder<Color>(
                        future: inventoryListProvider.getCategoryColor(inventoryItem['category'] ?? "N/A"),
                        builder: (context, snapshot) {
                          final categoryColor = snapshot.data ?? Colors.grey;
                          return CustomListItem(
                            title: inventoryItem['name'],
                            subtitle: subtitle,
                            onEditPressed: (context) => openEditBox(inventoryItem['id']),
                            onDeletePressed: (context) => openDeleteBox(inventoryItem['id']),
                            centerImage: AssetImage(assetPath),
                            categoryColor: categoryColor,
                            onTap: () => openViewPage(inventoryItem['id']),
                          );
                        },
                      );
                    },
                  ),
                ),

            ],
            );
          }
        },
      ),
      floatingActionButton: Consumer<InventoryListProvider>(
        builder: (context, inventoryListProvider, child) {
          final inventoryItems = inventoryListProvider.inventoryItems;

          // If the list is empty, show 'Create inventory' button in the center
          if (inventoryItems.isEmpty) {
            return SizedBox(
              height: 70,
              width: 230,
              child: FloatingActionButton.extended(
                heroTag: "inventory_fab1",
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) =>
                  //           const InventoryEditPage(inventoryIngredientId: null)),
                  // ).then((_) {
                  //   setState(() {
                  //     inventoryListProvider
                  //         .fetchInventory(); // Rebuild after fetching inventoryItems
                  //   });
                  // });
                },
                label: const Text(
                    'Add Ingredient to inventory'), // Label for empty list
                icon: const Icon(Icons.add), // Icon with the label
                tooltip: 'Create a new inventory',
              ),
            );
          } else {
            // If there are inventoryIngredients, show 'plus' button in the bottom right
            return FloatingActionButton(
              heroTag: "inventory_fab2",
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) =>
                //           const InventoryEditPage(inventoryIngredientId: null)),
                // ).then((_) {
                //   setState(() {
                //     inventoryListProvider
                //         .fetchInventory(); // Rebuild after fetching inventoryIngredients
                //   });
                // });
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Ingredient',
            );
          }
        },
      ),
      floatingActionButtonLocation: inventoryListProvider.inventoryItems.isEmpty
          ? FloatingActionButtonLocation.centerFloat // Center if empty
          : FloatingActionButtonLocation.endFloat, // Bottom right if not empty
    );
  }
}
//  add optional properties to custom item widget
