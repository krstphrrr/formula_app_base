import 'package:flutter/material.dart';

import '../domain/formula_add_service.dart';

// import '../domain/formula_list_service.dart';

class FormulaAddProvider extends ChangeNotifier {
  final FormulaAddService _service;
  FormulaAddProvider(this._service);

  // properties

  TextEditingController _formulaName = TextEditingController();
  TextEditingController _notes = TextEditingController();
  TextEditingController _formulaType = TextEditingController();
  TextEditingController _creationDate = TextEditingController();
  TextEditingController _modifiedDate = TextEditingController();

  TextEditingController get formulaName => _formulaName;
  TextEditingController get notes => _notes;
  TextEditingController get formulaType => _formulaType;
  TextEditingController get creationDate => _creationDate;
  TextEditingController get modifiedDate => _modifiedDate;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

   @override
  void dispose() {
    _formulaName.dispose();
    _notes.dispose();
    _formulaType.dispose();
    _creationDate.dispose();
    _modifiedDate.dispose();

    super.dispose();
  }

    void clearControllers() {
    _formulaName.clear();
    _notes.clear();
    _formulaType.clear();
    _creationDate.clear();
    _modifiedDate.clear();
    _selectedCategory=null;
     notifyListeners();
  }

  // setters
    set formulaName(TextEditingController value) {
    _formulaName = value;
    notifyListeners();  // Notify listeners of the change
  }
    set notes(TextEditingController value) {
    _notes = value;
    notifyListeners();  // Notify listeners of the change
  }
    set formulaType(TextEditingController value) {
    _formulaType = value;
    notifyListeners();  // Notify listeners of the change
  }
    set creationDate(TextEditingController value) {
    _creationDate = value;
    notifyListeners();  // Notify listeners of the change
  }

   set modifiedDate(TextEditingController value) {
    _modifiedDate = value;
    notifyListeners();  // Notify listeners of the change
  }

  // methods
  
  Future<void> loadCategories() async {
    final List<Map<String, dynamic>> categoryData = await _service.loadCategories();
    _categories = categoryData;
    notifyListeners(); // Notify listeners so that UI can update when data is loaded
  }

  void updateSelectedCategory(String? categoryId) {
    _selectedCategory = categoryId;
    // _formulaType.text = categoryId!;

    notifyListeners();
  }
  void printCategory(){
    print(_selectedCategory);
  }

   Future<void> addFormula(Map<String, dynamic> formula) async {
    await _service.addFormula(formula);
    clearControllers();
  }

    // Update existing formula
  Future<void> updateFormula(int id, Map<String, dynamic> updatedFormula) async {
    await _service.updateFormula(id, updatedFormula);
    clearControllers();
    // await fetchFormulas();
  }
}