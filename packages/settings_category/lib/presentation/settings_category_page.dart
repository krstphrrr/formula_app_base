import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import 'package:settings_category/settings_category.dart';

class SettingsCategoryPage extends StatefulWidget {
  @override
  _SettingsCategoryPageState createState() => _SettingsCategoryPageState();
}

class _SettingsCategoryPageState extends State<SettingsCategoryPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsCategoryProvider =
          Provider.of<SettingsCategoryProvider>(context, listen: false);
      settingsCategoryProvider.loadCategories(); // Fetch categories when the page loads
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsCategoryProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Category Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for category selection
            Consumer<SettingsCategoryProvider>(
              builder: (context, provider, _) {
                return DropdownButton<String>(
                  isExpanded: true,
                  hint: Text("Select a Category"),
                  value: provider.selectedCategory,
                  items: provider.categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['name'],
                      child: Text(category['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    provider.selectCategory(value!);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            // Display selected category, color preview, and color picker button
            Consumer<SettingsCategoryProvider>(
              builder: (context, provider, _) {
                if (provider.selectedCategory == null) return Container();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.selectedCategory!,
                      style: TextStyle(fontSize: 18),
                    ),
                    Row(
                      children: [
                        // Show current color preview if assigned
                        if (provider.selectedColor != null)
                          Container(
                            width: 24,
                            height: 24,
                            color: provider.selectedColor,
                            margin: const EdgeInsets.only(right: 8),
                          ),
                        ElevatedButton(
                          onPressed: () async {
                            final Color? pickedColor = await showColorPickerDialog(
                              context,
                              provider.selectedColor ?? Colors.blue, // Set current color or default
                              title: Text("Pick a Color"),
                              showColorName: true,
                              showColorCode: true,
                              borderRadius: 0,
                              spacing: 0,
                              runSpacing: 0,
                              colorNameTextStyle: Theme.of(context).textTheme.titleSmall,
                              pickersEnabled: const <ColorPickerType, bool>{
                                ColorPickerType.both: false,
                                ColorPickerType.accent: false,
                                ColorPickerType.wheel: true,
                              },
                            );
                            if (pickedColor != null) {
                              provider.selectColor(pickedColor);
                            }
                          },
                          child: Text("Pick Color"),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: (){
                        provider.saveCategoryColor(context);
                      },
                      child: Text("Save"),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 20),
            // Add new category section
            TextField(
              controller: provider.newCategoryController,
              decoration: InputDecoration(
                labelText: "New Category",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<SettingsCategoryProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: () {
                    if (provider.newCategoryController.text.isNotEmpty) {
                      provider.addCategory(provider.newCategoryController.text.trim());
                      provider.newCategoryController.clear();
                    }
                  },
                  child: Text("Add Category"),
                );
              },
            ),
             const SizedBox(height: 20),
          // Button to consolidate categories
          ElevatedButton(
            onPressed: () {
              provider.consolidateCategories();
            },
            child: Text("Consolidate Categories"),
          ),
          ],
        ),
      ),
    );
  }
}
