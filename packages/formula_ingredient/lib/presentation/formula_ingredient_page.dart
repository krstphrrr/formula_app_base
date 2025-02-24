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
      // formulaIngredientProvider.currentFormulaId = widget.formula['id'];
      // formulaIngredientProvider.formulaDisplayName = widget.formula['name'];
      // formulaIngredientProvider.fetchFormulaIngredients(widget.formula['id']);
      formulaIngredientProvider.setFormula(widget.formula);
      formulaIngredientProvider.fetchAvailableIngredients();
      formulaIngredientProvider.calculateTotalAmount();
      if (formulaIngredientProvider.isTargetTotalEnabled) {
      complianceCheckFuture = formulaIngredientProvider.checkIfraCompliance();
    } else {
      complianceCheckFuture = Future.value();
    }
   
    });
  }

 void _showAddIngredientModal(BuildContext context) {
  final formulaIngredientProvider = Provider.of<FormulaIngredientProvider>(context, listen: false);

  showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder:(BuildContext context) {
    return PopScope(
      canPop: false, // Disable the default back button behavior
      onPopInvokedWithResult: (context, result) {
        print("attempting to pop out");
      },
      child:  DraggableScrollableSheet(
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
                TextField(
                  controller: formulaIngredientProvider.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search ingredients by name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    formulaIngredientProvider.filterAvailableIngredients(value);
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Consumer<FormulaIngredientProvider>(
                    builder: (context, provider, child) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: provider.filteredIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = provider.filteredIngredients[index];
                          return ListTile(
                            title: Text(ingredient['name']),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                final selectedIngredient = provider.filteredIngredients[index];
                                provider.addIngredientRow(context, selectedIngredient['id']);
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
    ));
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


  @override
  Widget build(BuildContext context) {
    final formulaIngredientProvider = Provider.of<FormulaIngredientProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Consumer<FormulaIngredientProvider>(
        builder: (context, provider, child) {
          return Text(provider.formulaDisplayName ?? 'Loading...');
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
    const Text("Input:"),
    Switch(
      value: formulaIngredientProvider.isRatioInput,
      onChanged: formulaIngredientProvider.isInputModeLocked
          ? null // Disable the switch if the input mode is locked
          : (bool value) {
              formulaIngredientProvider.toggleRatioInput(context, value);
            },
    ),
    Text(
      formulaIngredientProvider.isRatioInput ? "Ratios" : "Amounts",
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: formulaIngredientProvider.isInputModeLocked
                ? Colors.grey
                : null,
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
                              //  access controllers safely
                              //     if (index < formulaIngredientProvider.amountControllers.length &&
                              //  index < formulaIngredientProvider.dilutionControllers.length) {
                              final ingredient = formulaIngredientProvider
                                  .formulaIngredients[index];
                              final amountController = formulaIngredientProvider
                                  .amountControllers[index];
                              final dilutionController =
                                  formulaIngredientProvider
                                      .dilutionControllers[index];

                              final ratioController = formulaIngredientProvider.ratioControllers[index];
                              //  final ingredient['name'] = formulaIngredientProvider.

                              final amountFocusNode = formulaIngredientProvider.amountFocusNodes
                                                    .isNotEmpty &&
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
                                  ratioFocusNode: ratioFocusNode,
                                  ratioController: ratioController,
                                  isCompliant: formulaIngredientProvider.isIngredientCompliant(index),
                                  categoryColor: ingredient['categoryColor'],
                                  onChangedRatio: (value) {
                                    formulaIngredientProvider.handleRatioChange(index,value);
                                  },
                                  onDeletePressed: () => formulaIngredientProvider.removeIngredient(index),
                                );
                              } else {
                                return FormulaIngredientListItem(
                                title: ingredient['name'],
                                amountController: amountController,
                                dilutionController: dilutionController,
                                relativeAmountText:
                                    (relativeAmount * 100).toStringAsFixed(2),
                                amountFocusNode: amountFocusNode,
                                dilutionFocusNode: dilutionFocusNode,
                                isCompliant: formulaIngredientProvider.isIngredientCompliant(index),
                                categoryColor: ingredient['categoryColor'],
                                onChangedAmount: (value){
                                    formulaIngredientProvider.handleAmountChange(index, value);
                                  },
                                  onChangedDilution: (value){
                                  formulaIngredientProvider.handleDilutionChange(index, value);
                                },
                                
                                onDeletePressed: () {
                                  formulaIngredientProvider
                                      .removeIngredient(index);
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
                FloatingActionButton(
                  heroTag: "iterFab",
                  onPressed: () async {
                    final formulaIngredientProvider =
                        Provider.of<FormulaIngredientProvider>(context,
                            listen: false);
                    // await formulaIngredientProvider.saveAllChanges(formulaIngredientProvider.currentFormulaId!);
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
                    final formulaIngredientProvider =
                        Provider.of<FormulaIngredientProvider>(context,
                            listen: false);
                    _showAddIngredientModal(context);
                    // formulaIngredientProvider.addIngredientRow(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ingredient'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

