import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  final VoidCallback? onTap;
  final ImageProvider? centerImage;
  final Color? categoryColor;
  final bool isRatioFormula;

  const CustomListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onEditPressed,
    required this.onDeletePressed,
    this.onTap,
    this.centerImage,
    this.categoryColor,
    this.isRatioFormula = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: onEditPressed,
                icon: Icons.edit,
              ),
              SlidableAction(
                onPressed: onDeletePressed,
                icon: Icons.delete,
                foregroundColor: Colors.black,
                backgroundColor: Colors.red,
              ),
            ],
          ),
          child: ListTile(
            onTap: onTap,
            title: Row(
              children: [
                // Title and ratio icon
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                       ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200), // Set a maximum width
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 5),
                      if (isRatioFormula)
                        Icon(
                          Icons.pie_chart,
                          color: Colors.blueAccent,
                          size: 20,
                        ), // Icon indicating ratio formula
                    ],
                  ),
                ),
                // Center column for the image
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: centerImage != null
                        ? Image(
                            image: centerImage!,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fit: BoxFit.fitHeight,
                            height: 34,
                            width: 34,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        // Colored line below the ListTile as a divider
        if (categoryColor != null)
          Container(
            height: 3,
            color: categoryColor,
          ),
      ],
    );
  }
}