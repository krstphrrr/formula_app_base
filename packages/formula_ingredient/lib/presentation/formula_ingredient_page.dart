import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';
// import '../../formula_scaling/presentation/formula_scale_page.dart';
// import 'package:formula_ingredient/state/formula_ingredient_provider.dart';
import 'package:formula_ingredient/formula_ingredient.dart'; 

class FormulaIngredientPage extends StatefulWidget {
  // final int formulaId;
  final Map<String, dynamic> formula;

  const FormulaIngredientPage(
      {Key? key,
      // required this.formulaId,
      required this.formula})
      : super(key: key);

  @override
  _FormulaIngredientPageState createState() => _FormulaIngredientPageState();
}

class _FormulaIngredientPageState extends State<FormulaIngredientPage> {
  late Future<void> complianceCheckFuture;

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final formulaIngredientProvider =
        Provider.of<FormulaIngredientProvider>(context, listen: false);
    formulaIngredientProvider.setFormula(widget.formula);
    formulaIngredientProvider.fetchAvailableIngredients();
    formulaIngredientProvider.calculateTotalAmount();

    // Print debug statement to check if editing an accord
    if (formulaIngredientProvider.isAccordFormula) {
      print("DEBUG: Editing an Accord - ${formulaIngredientProvider.formulaDisplayName}");
    } else {
      print("DEBUG: Editing a Regular Formula - ${formulaIngredientProvider.formulaDisplayName}");
    }

    if (formulaIngredientProvider.isTargetTotalEnabled) {
      complianceCheckFuture = formulaIngredientProvider.checkIfraCompliance();
    } else {
      complianceCheckFuture = Future.value();
    }
  });
}

 void _showAddIngredientModal(BuildContext context, {required bool isAccord}) {
  final formulaIngredientProvider = Provider.of<FormulaIngredientProvider>(context, listen: false);
  
  // Decide which list to use based on isAccord flag
  List<Map<String, dynamic>> options = isAccord
      ? formulaIngredientProvider.availableAccords
      : formulaIngredientProvider.availableIngredients;

  // Ensure search filtering applies to correct list
  void updateSearch(String query) {
    if (isAccord) {
      formulaIngredientProvider.filterAvailableAccords(query);
    } else {
      formulaIngredientProvider.filterAvailableIngredients(query);
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.75,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Draggable Handle
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  
                  // Title based on selection
                  Text(
                    isAccord ? 'Select an Accord' : 'Select an Ingredient',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 10),

                  // Search bar
                  TextField(
                    controller: formulaIngredientProvider.searchController,
                    decoration: InputDecoration(
                      hintText: isAccord ? 'Search accords...' : 'Search ingredients...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: updateSearch,
                  ),

                  const SizedBox(height: 10),

                  // List of ingredients or accords
                  Expanded(
                    child: Consumer<FormulaIngredientProvider>(
                      builder: (context, provider, child) {
                        final list = isAccord ? provider.filteredAccords : provider.filteredIngredients;

                        if (list.isEmpty) {
                          return Center(
                            child: Text(
                              isAccord ? 'No accords available' : 'No ingredients available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final item = list[index];
                            return ListTile(
                              title: Text(item['name']),
                              trailing: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  provider.addIngredientRow(context, item['id'], isAccord: isAccord);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}




  // Function to open the export options dialog
  void _showExportDialog() {
    final formulaIngredientProvider =
        Provider.of<FormulaIngredientProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export Format'),
          content: Text('Choose an export format:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                formulaIngredientProvider
                    .exportData('ppt'); // Export as Parts per Thousand
                formulaIngredientProvider.fetchFormulaIngredients(formulaIngredientProvider.currentFormulaId!);
              },
              child: Text('Parts per Thousand'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                formulaIngredientProvider
                    .exportData('pph'); // Export as Parts per Hundred
                formulaIngredientProvider.fetchFormulaIngredients(formulaIngredientProvider.currentFormulaId!);

              },
              child: Text('Parts per Hundred'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                formulaIngredientProvider
                    .exportData('percent'); // Export as Percent Fraction
                formulaIngredientProvider.fetchFormulaIngredients(formulaIngredientProvider.currentFormulaId!);

              },
              child: Text('Percent Fraction'),
            ),
          ],
        );
      },
    );
  }
void _showAddIngredientSelectionDialog(BuildContext context) {
  final formulaIngredientProvider = Provider.of<FormulaIngredientProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Select Type"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Ingredient"),
              enabled: formulaIngredientProvider.availableIngredients.isNotEmpty,
              onTap: () {
                Navigator.pop(context);
                _showAddIngredientModal(context, isAccord: false);
              },
            ),
            ListTile(
              title: Text("Accord"),
              enabled: !formulaIngredientProvider.isAccordFormula && formulaIngredientProvider.availableAccords.isNotEmpty,
              onTap: () {
                Navigator.pop(context);
                _showAddIngredientModal(context, isAccord: true);
              },
            ),
          ],
        ),
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    final formulaIngredientProvider = Provider.of<FormulaIngredientProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Consumer<FormulaIngredientProvider>(
        builder: (context, provider, child) {
      String title = provider.isAccordFormula
          ? "Editing Accord: ${provider.formulaDisplayName}"
          : provider.formulaDisplayName;
      return Text(title ?? 'Loading...');
    },
      ),

        actions: [
          IconButton(
              icon: Icon(Icons.scale), // Use a scale icon or any other icon
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => FormulaScalePage(
                //         formulaId: widget.formula['id']), // Pass the formula ID
                //   ),
                // );
              },
            ),
            IconButton(
              icon: Icon(Icons.file_upload),
              onPressed: _showExportDialog, // Export button
            ),
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: formulaIngredientProvider.importData, // Import button
            ),
        ],
      ),

      body: Column(
        children: [
          Expanded(child: Consumer<FormulaIngredientProvider>(
            builder: (context, formulaIngredientProvider, child) {
              return Column(
                  children: [
                  Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    // IFRA Check Checkbox
    Checkbox(
      value: formulaIngredientProvider.isTargetTotalEnabled,
      onChanged: (bool? value) {
        formulaIngredientProvider.toggleTargetTotalEnabled(value ?? false);
      },
    ),
    const Text("IFRA"),
    const SizedBox(width: 20), // Add space between IFRA Check and Input Mode toggle

    // Input Mode Toggle
    // Input Mode Toggle (Disable switch if editing an accord)
      const Text("Input:"),
      Switch(
        value: formulaIngredientProvider.isAccordFormula || formulaIngredientProvider.isRatioInput,
        onChanged: formulaIngredientProvider.isAccordFormula || formulaIngredientProvider.isInputModeLocked
            ? null // Disable switch if the formula is an accord
            : (bool value) {
                formulaIngredientProvider.toggleRatioInput(context, value);
              },
      ),
      Text(
        formulaIngredientProvider.isAccordFormula || formulaIngredientProvider.isRatioInput
            ? "Ratios"
            : "Amounts",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: formulaIngredientProvider.isInputModeLocked ? Colors.grey : null,
            ),
      ),


    // Add Sorting Dropdown
    Spacer(), // Push the dropdown to the right
    // const Text("Sort: "),
    DropdownButton<String>(
      value: formulaIngredientProvider.selectedSortOption,
      onChanged: (String? newValue) {
        formulaIngredientProvider.updateSorting(newValue ?? 'Add Order');
      },
      items: <String>['Add Order', 'Name', 'Category', 'Amount']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    ),
  ],
),
    if (formulaIngredientProvider.isTargetTotalEnabled)
      Column(
        children: [
          Text(
            formulaIngredientProvider.isRatioInput
                ? 'Total Ratio: ${formulaIngredientProvider.totalRatioAmount.toStringAsFixed(2)}'
                : 'Total Amount: ${formulaIngredientProvider.totalAmount.toStringAsFixed(2)} grams',
            style: TextStyle(fontSize: 16),
          ),
          Slider(
            value: formulaIngredientProvider.targetTotalAmount.toDouble(),
            min: 5,
            max: 25,
            divisions: 2,
            label: '${formulaIngredientProvider.targetTotalAmount}%',
            onChanged: formulaIngredientProvider.isTargetTotalEnabled
                ? (value) {
                    formulaIngredientProvider.setTargetTotalAmount(value.round());
                    formulaIngredientProvider.checkIfraCompliance();
                  }
                : null, // Disable slider if the checkbox is unchecked
          ),
        ],
      ),
    // Text(
    //   'Total Amount: ${formulaIngredientProvider.totalAmount.toStringAsFixed(2)} grams',
    //   style: TextStyle(fontSize: 16),
    // ),
                Expanded(
                    child: formulaIngredientProvider.formulaIngredients.isEmpty
                        ? Center(child: Text('No ingredients available'))
                        : ListView.builder(
                            itemCount: formulaIngredientProvider
                                .formulaIngredients.length,
                            itemBuilder: (context, index) {
                              
                              if (index >= formulaIngredientProvider.formulaIngredients.length ||
                                  index >= formulaIngredientProvider.amountControllers.length ||
                                  index >= formulaIngredientProvider.dilutionControllers.length) {
                                return SizedBox.shrink(); // Prevents accessing invalid indices
                              }
                               // Read-only if this is part of an accord
                              //  access controllers safely
                              //     if (index < formulaIngredientProvider.amountControllers.length &&
                              //  index < formulaIngredientProvider.dilutionControllers.length) {
                              final ingredient = formulaIngredientProvider.formulaIngredients[index];
                              bool isPartOfAccord = ingredient['is_accord_ingredient'] == true;
                              final amountController = formulaIngredientProvider
                                  .amountControllers[index];
                              final dilutionController = formulaIngredientProvider.dilutionControllers[index];

                              final ratioController = formulaIngredientProvider.ratioControllers[index];
                              //  final ingredient['name'] = formulaIngredientProvider.

                              final amountFocusNode = formulaIngredientProvider.amountFocusNodes                                             .isNotEmpty &&
                                                index <
                                                    formulaIngredientProvider.amountFocusNodes.length
                                            ? formulaIngredientProvider.amountFocusNodes[index]
                                            : null;
                              final dilutionFocusNode = formulaIngredientProvider.dilutionFocusNodes
                                                    .isNotEmpty &&
                                                index <
                                                    formulaIngredientProvider.dilutionFocusNodes.length
                                            ? formulaIngredientProvider.dilutionFocusNodes[index]
                                            : null;
                              final ratioFocusNode = formulaIngredientProvider.ratioFocusNodes
                                                    .isNotEmpty &&
                                                index <
                                                    formulaIngredientProvider.ratioFocusNodes.length
                                            ? formulaIngredientProvider.ratioFocusNodes[index]
                                            : null;

                              double dilution =
                                  double.tryParse(dilutionController.text) ??
                                      1.0;
                              double relativeAmount =
                                  (formulaIngredientProvider.totalAmount > 0)
                                      ? (ingredient['amount'] *
                                          dilution /
                                          formulaIngredientProvider.totalAmount)
                                      : 0.0;
                              if (formulaIngredientProvider.isRatioInput) {
                                return FormulaIngredientListItemRatio(
                                  title: ingredient['name'],
                                  // ratioFocusNode: ratioFocusNode,
                                  ratioFocusNode: isPartOfAccord ? null : formulaIngredientProvider.ratioFocusNodes[index],

                                  ratioController: ratioController,
                                  isCompliant: formulaIngredientProvider.isIngredientCompliant(index),
                                  categoryColor: ingredient['categoryColor'],
                                  // onChangedRatio: (value) {
                                  //   formulaIngredientProvider.handleRatioChange(index,value);
                                  // },
                                  onChangedRatio: isPartOfAccord ? (value) {} : (value) {
                                      formulaIngredientProvider.handleRatioChange(index, value);
                                  },
                                //   onDeletePressed: () => formulaIngredientProvider.removeIngredient(index),
                                // );
                                      onDeletePressed: isPartOfAccord ? () {} : () {
                                        formulaIngredientProvider.removeIngredient(index);
                                      },
                                    );
                                  } else {
                              //   return FormulaIngredientListItem(
                              //   title: ingredient['name'],
                              //   amountController: amountController,
                              //   dilutionController: dilutionController,
                              //   relativeAmountText:
                              //       (relativeAmount * 100).toStringAsFixed(2),
                              //   // amountFocusNode: amountFocusNode,
                              //   amountFocusNode: isPartOfAccord ? null : formulaIngredientProvider.amountFocusNodes[index],
                              //   // dilutionFocusNode: dilutionFocusNode,
                              //   dilutionFocusNode: isPartOfAccord ? null : formulaIngredientProvider.dilutionFocusNodes[index],

                              //   isCompliant: formulaIngredientProvider.isIngredientCompliant(index),
                              //   categoryColor: ingredient['categoryColor'],
                              //   // onChangedAmount: (value){
                              //   //     formulaIngredientProvider.handleAmountChange(index, value);
                              //   //   },
                              //   onChangedAmount: isPartOfAccord ? (value) {} : (value) {
                              //     formulaIngredientProvider.handleAmountChange(index, value);
                              //   },
                              //   //   onChangedDilution: (value){
                              //   //   formulaIngredientProvider.handleDilutionChange(index, value);
                              //   // },
                              //   onChangedDilution: (value) {
                              //     if (!isPartOfAccord) {
                              //       formulaIngredientProvider.handleDilutionChange(index, value);
                              //     }
                              //   },
                                
                              //   // onDeletePressed: () {
                              //   //   formulaIngredientProvider
                              //   //       .removeIngredient(index);
                              //   // },
                              //   onDeletePressed: isPartOfAccord ? () {} : () {
                              //     formulaIngredientProvider.removeIngredient(index);
                              //   },
                              // );

                              return FutureBuilder<bool>(
                                future: formulaIngredientProvider.isIngredientInInventory(ingredient['ingredient_id']),
                                builder: (context, snapshot) {
                                  bool isInInventory = snapshot.data ?? false;
                                  return FormulaIngredientListItem(
                                    title: ingredient['name'],
                                    amountController: amountController,
                                    dilutionController: dilutionController,
                                    relativeAmountText: (relativeAmount * 100).toStringAsFixed(2),
                                    isCompliant: formulaIngredientProvider.isIngredientCompliant(index),
                                    categoryColor: ingredient['categoryColor'],
                                    isInInventory: isInInventory,
                                    onInventoryChecked: (value) {
                                      if (value == true) {
                                        formulaIngredientProvider.addIngredientToInventory(ingredient['ingredient_id']);
                                      }
                                    },
                                    onChangedAmount: (value) => formulaIngredientProvider.handleAmountChange(index, value),
                                    onChangedDilution: (value) => formulaIngredientProvider.handleDilutionChange(index, value),
                                    onDeletePressed: () => formulaIngredientProvider.removeIngredient(index),
                                  );
                                },
                              );

                            }              
                  })
                )
              ]);
            },
          )),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // FloatingActionButton(
                //   heroTag: "iterFab",
                //   onPressed: () async {
                //     final formulaIngredientProvider =
                //         Provider.of<FormulaIngredientProvider>(context,
                //             listen: false);
                //     // await formulaIngredientProvider.saveAllChanges(formulaIngredientProvider.currentFormulaId!);
                //     await formulaIngredientProvider.iterateOnFormula(context);
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(content: Text('Iterating on formula ${formulaIngredientProvider.currentFormula!['name']}')),
                //     );
                //   },
                //   child: const Icon(Icons.copy_all_rounded),
                //   mini: true,
                // ),
                FloatingActionButton(
                  heroTag: "iterFab",
                  onPressed: formulaIngredientProvider.isAccordFormula
                      ? null // Disable if editing an accord
                      : () async {
                          await formulaIngredientProvider.iterateOnFormula(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Iterating on formula ${formulaIngredientProvider.currentFormula!['name']}')),
                          );
                        },
                  child: const Icon(Icons.copy_all_rounded),
                  mini: true,
                ),
                FloatingActionButton.extended(
                  heroTag: "addFab",
                  onPressed: () {
                    final formulaIngredientProvider = Provider.of<FormulaIngredientProvider>(context, listen: false);

                    // If editing an accord, directly show ingredient selection
                    if (formulaIngredientProvider.isAccordFormula) {
                      _showAddIngredientModal(context, isAccord: false);
                    } else {
                      _showAddIngredientSelectionDialog(context);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(formulaIngredientProvider.isAccordFormula ? 'Add Ingredient' : 'Add Ingredient/Accord'),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

