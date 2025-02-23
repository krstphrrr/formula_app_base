import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FormulaIngredientListItemRatio extends StatelessWidget {
  final String title;
  final TextEditingController ratioController;
  final FocusNode? ratioFocusNode;
  final VoidCallback onDeletePressed;
  final Function(String) onChangedRatio;
  final bool isCompliant;
  final Color categoryColor;


  const FormulaIngredientListItemRatio({
    super.key,
    required this.title,
    required this.ratioController,
    this.ratioFocusNode,
    required this.onDeletePressed,
    required this.onChangedRatio,
    this.isCompliant = true,
   Color? categoryColor, // Make nullable
}) : categoryColor = categoryColor ?? const Color(0xFFCCCCCC); 

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
             // Category Color Indicator
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
          //   width: 8, // Fixed width for the bar
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
              width: 80,
              child: TextField(
                focusNode: ratioFocusNode,
                controller: ratioController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Ratio amount',
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
                onChanged: onChangedRatio,
              ),
            ),
            const SizedBox(width: 10),

            // Dilution TextField with fixed width
            // SizedBox(
            //   width: 80, // Set a fixed width for dilution field
            //   child: TextField(
            //     // focusNode: dilutionFocusNode,
            //     controller: dilutionController,
            //     keyboardType: TextInputType.number,
            //     textAlign: TextAlign.center,
            //     decoration: InputDecoration(
            //       hintText: 'Dilution (0-1)',
            //       border: OutlineInputBorder(),
            //       contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            //     ),
            //     onChanged: onChangedDilution,
            //   ),
            // ),
            const SizedBox(width: 10),

            // Relative Amount Text
            // SizedBox(
            //   width: 80, // Set a fixed width for relative amount text
            //   child: FittedBox(
            //     fit: BoxFit.scaleDown,
            //     alignment: Alignment.centerRight,
            //     child: Text(
            //       'Rel: $relativeAmountText%',
            //       style: Theme.of(context).textTheme.bodySmall,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
