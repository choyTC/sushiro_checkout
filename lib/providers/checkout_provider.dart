import 'package:flutter/material.dart';
import '../models/plate_type.dart';
import '../models/person_order.dart';
import '../models/app_strings.dart';
import '../models/table_history_record.dart';

/// Manages table state, diners billing data, custom item input pricing,
/// theme mode, language state, spending history, and split-billing operations for Sushiro Checkout.
class CheckoutProvider extends ChangeNotifier {
  final List<PersonOrder> _diners = [];
  final List<TableHistoryRecord> _historyRecords = [];
  int _currentDinerIndex = 0;

  // Theme mode state
  ThemeMode _themeMode = ThemeMode.system;

  // Language state (English default, Cantonese toggle)
  AppLanguage _language = AppLanguage.en;

  // Custom Item Picker workspace state
  double _customPricePickerValue = 0.0;

  CheckoutProvider() {
    // Add default initial diner
    _addNewDiner();
  }

  // --- Getters ---
  List<PersonOrder> get diners => List.unmodifiable(_diners);
  List<TableHistoryRecord> get historyRecords => List.unmodifiable(_historyRecords);
  int get currentDinerIndex => _currentDinerIndex;
  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;

  /// Returns localized string manager based on active language setting.
  AppStrings get strings => AppStrings(_language);

  // --- History Management ---

  /// Records the current state of the master table into spending history records.
  void saveCurrentTableToHistory() {
    if (totalItemCountAllDiners == 0 && masterTableSubtotal == 0) {
      return; // Do not record completely empty tables
    }

    final snapshots = _diners.map((diner) {
      final int totalItems = diner.plateCounts.values.fold<int>(0, (a, b) => a + b) +
          diner.fixedTagCounts.values.fold<int>(0, (a, b) => a + b) +
          diner.quickAdjustmentCounts.values.fold<int>(0, (a, b) => a + b) +
          diner.customItems.values.fold<int>(0, (a, b) => a + b.quantity);

      return DinerHistorySnapshot(
        dinerName: diner.name,
        totalItems: totalItems,
        individualSubtotal: diner.individualSubtotal,
        individualTotal: diner.individualTotal,
      );
    }).toList();

    final record = TableHistoryRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      totalDiners: _diners.length,
      totalItemsAllDiners: totalItemCountAllDiners,
      masterTableSubtotal: masterTableSubtotal,
      masterTableFinalTotal: masterTableFinalTotal,
      dinerSnapshots: snapshots,
    );

    _historyRecords.insert(0, record); // Most recent record first
    notifyListeners();
  }

  /// Clears all historical spending records.
  void clearHistory() {
    _historyRecords.clear();
    notifyListeners();
  }

  /// Toggles language between English and Cantonese.
  void toggleLanguage() {
    _language = _language == AppLanguage.en ? AppLanguage.cantonese : AppLanguage.en;
    notifyListeners();
  }

  /// Toggles theme mode between light and dark based on active brightness.
  void toggleThemeMode([Brightness? activeBrightness]) {
    if (activeBrightness != null) {
      _themeMode = activeBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    } else {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
    notifyListeners();
  }
  
  PersonOrder get currentDiner {
    if (_diners.isEmpty) {
      _addNewDiner();
    }
    if (_currentDinerIndex >= _diners.length) {
      _currentDinerIndex = _diners.length - 1;
    }
    return _diners[_currentDinerIndex];
  }

  double get customPricePickerValue => _customPricePickerValue;

  // --- Diner Navigation / Management ---
  
  /// Advances focus to the next person, or creates a new diner if at the end of the roster (up to 15).
  void calculateNext() {
    if (_diners.isEmpty) {
      _addNewDiner();
      _currentDinerIndex = 0;
      notifyListeners();
      return;
    }

    // Automatically record spending snapshot into history
    saveCurrentTableToHistory();

    if (_currentDinerIndex < _diners.length - 1) {
      _currentDinerIndex++;
    } else if (_diners.length < 15) {
      _addNewDiner();
      _currentDinerIndex = _diners.length - 1;
    } else {
      _currentDinerIndex = 0;
    }
    notifyListeners();
  }

  /// Advances focus to the next person, or cycles back to the first.
  void nextPerson() {
    if (_diners.isNotEmpty) {
      _currentDinerIndex = (_currentDinerIndex + 1) % _diners.length;
      notifyListeners();
    }
  }

  /// Switches active selection to a specific diner index.
  void selectPerson(int index) {
    if (index >= 0 && index < _diners.length) {
      _currentDinerIndex = index;
      notifyListeners();
    }
  }

  /// Adds a new member/diner to the split bill roster.
  void addPerson([String? name]) {
    _addNewDiner(name);
    notifyListeners();
  }

  /// Updates the name of a specific diner.
  void updateDinerName(int index, String newName) {
    if (index >= 0 && index < _diners.length && newName.trim().isNotEmpty) {
      _diners[index].name = newName.trim();
      notifyListeners();
    }
  }

  /// Removes a diner from the roster by index and clears their dish selections.
  void removeDiner(int index) {
    if (index < 0 || index >= _diners.length) return;

    if (_diners.length == 1) {
      // If only one diner remains, clear selections instead of removing the last diner
      _diners[0].clear();
      notifyListeners();
      return;
    }

    _diners[index].clear();
    _diners.removeAt(index);

    if (_currentDinerIndex >= _diners.length) {
      _currentDinerIndex = _diners.length - 1;
    } else if (_currentDinerIndex > index) {
      _currentDinerIndex--;
    }
    notifyListeners();
  }

  /// Internal utility to create a PersonOrder instance.
  void _addNewDiner([String? name]) {
    final newIndex = _diners.length + 1;
    final defaultPrefix = _language == AppLanguage.cantonese ? '食客' : 'Diner';
    final dinerName = name ?? '$defaultPrefix $newIndex';
    _diners.add(PersonOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_$newIndex',
      name: dinerName,
    ));
  }

  // --- Core Items / Plates State Mutators ---

  /// Adjusts core plate quantity for the current active diner.
  void updatePlateCount(PlateType type, int delta) {
    final currentQty = currentDiner.plateCounts[type] ?? 0;
    final target = currentQty + delta;
    currentDiner.plateCounts[type] = target < 0 ? 0 : target;
    notifyListeners();
  }

  /// Adjusts fixed tag quantity ($3 to $59) for the current active diner.
  void updateFixedTagCount(double price, int delta) {
    if (currentDiner.fixedTagCounts.containsKey(price)) {
      final currentQty = currentDiner.fixedTagCounts[price] ?? 0;
      final target = currentQty + delta;
      currentDiner.fixedTagCounts[price] = target < 0 ? 0 : target;
      notifyListeners();
    }
  }

  /// Adjusts quick adjustment tag quantity ($1 or $2) for the current active diner.
  void updateQuickAdjustmentCount(double price, int delta) {
    if (currentDiner.quickAdjustmentCounts.containsKey(price)) {
      final currentQty = currentDiner.quickAdjustmentCounts[price] ?? 0;
      final target = currentQty + delta;
      currentDiner.quickAdjustmentCounts[price] = target < 0 ? 0 : target;
      notifyListeners();
    }
  }

  // --- Custom Price Item Picker Logic ---

  /// Updates or sets custom price base level.
  void adjustCustomPricePicker(double delta) {
    _customPricePickerValue += delta;
    if (_customPricePickerValue < 0.0) {
      _customPricePickerValue = 0.0;
    }
    notifyListeners();
  }

  /// Adds a unit of the custom picker value item to the active person's subtotal.
  void addCustomItemToCurrentPerson() {
    if (_customPricePickerValue <= 0.0) return;
    
    final price = _customPricePickerValue;
    if (currentDiner.customItems.containsKey(price)) {
      currentDiner.customItems[price]!.quantity += 1;
    } else {
      currentDiner.customItems[price] = CustomItem(price: price, quantity: 1);
    }
    notifyListeners();
  }

  /// Subtracts a unit of the custom picker value item from the active person's subtotal.
  void subtractCustomItemFromCurrentPerson() {
    if (_customPricePickerValue <= 0.0) return;
    
    final price = _customPricePickerValue;
    if (currentDiner.customItems.containsKey(price)) {
      final item = currentDiner.customItems[price]!;
      item.quantity -= 1;
      if (item.quantity <= 0) {
        currentDiner.customItems.remove(price);
      }
      notifyListeners();
    }
  }

  // --- Reset Methods ---

  /// Resets selections back to 0 for the currently focused person.
  void resetCurrentPerson() {
    currentDiner.clear();
    notifyListeners();
  }

  /// Wipes out all table records, resets back to a single clean diner.
  void resetEntireTable() {
    saveCurrentTableToHistory();
    _diners.clear();
    _currentDinerIndex = 0;
    _customPricePickerValue = 0.0;
    _addNewDiner();
    notifyListeners();
  }

  // --- Master Table Calculation Getters ---

  /// Sums total quantities of all items combined across all diners.
  int get totalItemCountAllDiners {
    int count = 0;
    for (var diner in _diners) {
      diner.plateCounts.values.forEach((qty) => count += qty);
      diner.fixedTagCounts.values.forEach((qty) => count += qty);
      diner.quickAdjustmentCounts.values.forEach((qty) => count += qty);
      diner.customItems.values.forEach((item) => count += item.quantity);
    }
    return count;
  }

  /// Aggregated table subtotal before service charge.
  double get masterTableSubtotal {
    double total = 0.0;
    for (var diner in _diners) {
      total += diner.individualSubtotal;
    }
    return total;
  }

  /// Aggregated final table total (with 1.1x service charge, rounded to nearest integer).
  int get masterTableFinalTotal {
    return (masterTableSubtotal * 1.10).round();
  }
}
