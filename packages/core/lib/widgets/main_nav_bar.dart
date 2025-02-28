import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:core/providers/theme_provider.dart';
import 'package:settings_data/presentation/settings_data_page.dart';

import 'package:settings_data/settings_data.dart';
import 'package:formula_list/formula_list.dart';
import 'package:inventory_list/inventory_list.dart';
import 'package:settings_category/settings_category.dart';

class MainNavBar extends StatefulWidget {
  @override
  _MainNavBarState createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // Method to handle index changes when a new tab is selected
  void onTabTapped(int index) {
    if (_currentIndex == index) {
      // If tapping the same tab, navigate to root
      switch (index) {
        case 0:
        case 1:
          Navigator.of(context).popUntil((route) => route.isFirst);
          break;
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);

  return PopScope(
    canPop: false, // Allow popping if there is a route to pop
    onPopInvokedWithResult:(didPop, result) {
      if (didPop) {
        return;
      }
    // Check if there is a modal sheet or a route to pop
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // Close the modal sheet or pop the current route
    } else if (_currentIndex > 0) {
      // If not on the first tab, switch to the first tab
      setState(() {
        _currentIndex = 0;
      });
    }
    // No need to return a value; the callback is void
  },
    child: Scaffold(
       appBar: AppBar(
  leading: Builder(
    builder: (context) => IconButton(
      icon: Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
  ),
  title: Text('Main Navigation Bar'),
),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/momo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Text(
                'Navigation Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.light_mode_outlined),
              title: const Text('Light Mode/Dark Mode'),
              onTap: () {
                themeProvider.toggleTheme();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsDataPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_color_fill_rounded),
              title: const Text('Categories manager'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsCategoryPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
  index: _currentIndex,
  children: [
    
    Consumer<FormulaListProvider>(
      builder: (context, formulaListProvider, child) {
        return Navigator(
          key: GlobalKey<NavigatorState>(),
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => FormulaListPage(),
            );
          },
        );
      },
    ),

    
    Consumer<InventoryListProvider>(
      builder: (context, inventoryListProvider, child) {
        return Navigator(
          key: GlobalKey<NavigatorState>(),
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => InventoryListPage(), 
            );
          },
        );
      },
    ),
  ],
),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Formulas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.colorize),
            label: 'Ingredients',
          ),
        ],
      ),
    ),
  );
}

}


class _PlaceholderPage extends StatelessWidget {
  final String title;
  final Color color;

  const _PlaceholderPage({
    required this.title,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Placeholder for $title page',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}