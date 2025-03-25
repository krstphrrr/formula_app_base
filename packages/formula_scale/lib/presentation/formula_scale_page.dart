import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../../formula_provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:csv/csv.dart'; // For CSV conversion
// import 'dart:io'; // For file handling
// import 'package:flutter/services.dart';
import 'package:formula_scale/formula_scale.dart';

class FormulaScalePage extends StatefulWidget {
  final int formulaId;

  FormulaScalePage({required this.formulaId});

  @override
  _FormulaScalePageState createState() => _FormulaScalePageState();
}

class _FormulaScalePageState extends State<FormulaScalePage> {
  double scaler = 1.0;
  // List<Map<String, dynamic>> formulaDetails = [];
  // Map<int, double> ingredientCosts = {}; // Map to hold ingredient costs per gram
  // double totalCost = 0.0; // Store the total cost of the formula
  // TextEditingController scalerController = TextEditingController();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final formulaScaleProvider =
        Provider.of<FormulaScaleProvider>(context, listen: false);
    formulaScaleProvider.currentFormulaId = widget.formulaId;

    // Fetch formula details
    formulaScaleProvider.fetchFormulaDetails(context);

    // Check if the formula is ratio-based
    if (formulaScaleProvider.isRatioBasedFormula()) {
      // Set default scaler to 1g and calculate amounts based on ratios
      setState(() {
        scaler = 1.0;
        formulaScaleProvider.scalerController.text = scaler.toString();
        formulaScaleProvider.scaleFormula(scaler); // Calculate based on default 1g
      });
    }
  });
}



@override
Widget build(BuildContext context) {
  final formulaScaleProvider = Provider.of<FormulaScaleProvider>(context, listen: false);

  return Scaffold(
    appBar: AppBar(
      title: Text('Scale Formula'),
      actions: [
        IconButton(
          icon: Icon(Icons.file_download),
          onPressed: (){
            formulaScaleProvider.exportScalerCSV(context);
            }, // Call the export CSV function
        ),
      ],
    ),
    body: Consumer<FormulaScaleProvider>(
  builder: (context, formulaScaleProvider, child) {
    final scaledDetails = formulaScaleProvider.scaledDetails;
    return Column(
      children: [
        // Target Amount and Total Cost in the same row
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: formulaScaleProvider.scalerController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Amount (g)',
                  ),
                  onChanged: (value) {
                    setState(() {
                      scaler = double.tryParse(value) ?? 1.0;
                      formulaScaleProvider.scaleFormula(scaler);
                    });
                  },
                ),
              ),
              SizedBox(width: 20),
              Text(
                'Total Cost: \$${formulaScaleProvider.totalCost.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: formulaScaleProvider.scaledDetails == null ||
                  formulaScaleProvider.scaledDetails!.isEmpty
              ? Center(child: Text('No ingredients available'))
              : ListView.builder(
                  itemCount: formulaScaleProvider.scaledDetails!.length,  // No `.toSet()`
                  itemBuilder: (context, index) {
                    final ingredient = formulaScaleProvider.scaledDetails![index];

                    String ingredientName = ingredient['name'] ?? 'Unknown ingredient';
                    double scaledAmount = ingredient['scaledAmount'] ?? 0.0;

                    return ListTile(
                      title: Text(ingredientName),
                      subtitle: Text('Amount: ${scaledAmount.toStringAsFixed(3)} g'),
                    );
                  },
                ),
        ),


      ],
    );
  },
),

  );
}
}