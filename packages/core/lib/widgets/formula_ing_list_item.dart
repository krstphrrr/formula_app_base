import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FormulaIngredientListItem extends StatelessWidget {
  final String title;
  final TextEditingController amountController;
  final TextEditingController dilutionController;
  // final TextEditingController ratioController;
  final String relativeAmountText;
  final VoidCallback onDeletePressed;
  final Function(String) onChangedAmount;
  final Function(String) onChangedDilution;
  // final Function(String) onChangedRatio;
  final FocusNode? amountFocusNode;
  final FocusNode? dilutionFocusNode;
  final bool isCompliant;
  final Color categoryColor;
  final bool isInInventory;
  final Function(bool?)? onInventoryChecked;

  const FormulaIngredientListItem({
    super.key,
    required this.title,
    required this.amountController,
    required this.dilutionController,
    // required this.ratioController,
    required this.relativeAmountText,
    required this.onDeletePressed,
    required this.onChangedAmount,
    required this.onChangedDilution,
    // required this.onChangedRatio,
    this.amountFocusNode,
    this.dilutionFocusNode,
    required this.isInInventory,
    required this.onInventoryChecked,
    this.isCompliant = true,
    Color? categoryColor, // Nullable input
  }) : categoryColor = categoryColor ?? const Color(0xFFCCCCCC); // Default to gray if null

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onDeletePressed(),
            icon: Icons.delete,
            foregroundColor: Colors.black,
            backgroundColor: Colors.red,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: isCompliant ? Colors.transparent : Colors.red, width: 1.0),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          //   // Category Color Indicator
          Container(
            width: 16,
            height: 50,
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: categoryColor, // Pass the category color here
                borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                // bottomLeft: Radius.circular(8.0),
              ),
            ),
          ),

          // Container(
          //   width: 10, // Fixed width for the bar
          //   decoration: BoxDecoration(
          //     color: categoryColor, // Use the category color
          //     borderRadius: const BorderRadius.only(
          //       topLeft: Radius.circular(8.0),
          //       bottomLeft: Radius.circular(8.0),
          //     ),
          //   ),
          // ),
            // Ingredient Name with fixed width
            SizedBox(
              width: 120, // Set a fixed width for ingredient name
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Amount TextField with fixed width
             SizedBox(
              width: 60,
              child: TextField(
                focusNode: amountFocusNode,
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Amount (g)',
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
                onChanged: onChangedAmount,
              ),
            ),
            const SizedBox(width: 10),

            // Dilution TextField with fixed width
            SizedBox(
              width: 50, // Set a fixed width for dilution field
              child: TextField(
                focusNode: dilutionFocusNode,
                controller: dilutionController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Dilution (0-1)',
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
                onChanged: onChangedDilution,
              ),
            ),
            const SizedBox(width: 5),

            // Relative Amount Text
            SizedBox(
              width: 60, // Set a fixed width for relative amount text
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  'Rel: $relativeAmountText%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            Checkbox(
              value: isInInventory,
              onChanged: isInInventory ? null : onInventoryChecked, // Disable if already in inventory
            ),
          ],
        ),
      ),
    );
  }
}
