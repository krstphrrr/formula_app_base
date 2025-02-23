import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_data/settings_data.dart';
import 'package:settings_data/state/settings_data_provider.dart';

class SettingsDataPage extends StatefulWidget {
  @override
  _SettingsDataPageState createState() => _SettingsDataPageState();
}

class _SettingsDataPageState extends State<SettingsDataPage> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select the feature (IFRA or Ingredients)
            DropdownButton<String>(
              value: settingsProvider.selectedFeature,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setSelectedFeature(value);
                }
              },
              items: [
                DropdownMenuItem(
                  value: 'IFRA',
                  child: Text('Manage IFRA Data'),
                ),
                DropdownMenuItem(
                  value: 'Ingredients',
                  child: Text('Manage Ingredients Data'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Call provider to pick CSV file
                await settingsProvider.importData(context);
              },
              child: Text('Choose CSV File'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: TextEditingController(
                text: settingsProvider.csvFileName,
              ),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Selected File',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Truncate table based on selected feature
                await settingsProvider.truncateTable();
              },
              child: Text('Truncate Table'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Ingest CSV based on selected feature
                await settingsProvider.ingestCsv();
              },
              child: Text('Ingest CSV to Table'),
            ),
          ],
        ),
      ),
    );
  }
}