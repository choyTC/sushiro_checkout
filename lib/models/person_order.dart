import 'plate_type.dart';

/// Represents a custom item added to a person's order.
class CustomItem {
  final double price;
  int quantity;

  CustomItem({
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

/// Represents the breakdown of a single diner's selected items and totals.
class PersonOrder {
  final String id;
  String name;

  // 1. Core Plates mapping
  final Map<PlateType, int> plateCounts;

  // 2. Fixed Price Tags mapping ($3 to $59)
  final Map<double, int> fixedTagCounts;

  // 3. Quick Adjustments ($1 and $2)
  final Map<double, int> quickAdjustmentCounts;

  // 4. Custom Items mapping (keyed by price for tracking unique custom inputs)
  final Map<double, CustomItem> customItems;

  PersonOrder({
    required this.id,
    required this.name,
  })  : plateCounts = {for (var type in PlateType.values) type: 0},
        fixedTagCounts = {
          3.0: 0, 6.0: 0, 8.0: 0, 9.0: 0, 12.0: 0, 13.0: 0, 17.0: 0, 18.0: 0,
          19.0: 0, 20.0: 0, 22.0: 0, 24.0: 0, 27.0: 0, 28.0: 0, 32.0: 0, 33.0: 0,
          39.0: 0, 42.0: 0, 48.0: 0, 59.0: 0,
        },
        quickAdjustmentCounts = {
          1.0: 0,
          2.0: 0,
        },
        customItems = {};

  /// Resets all item selections for this specific individual.
  void clear() {
    plateCounts.updateAll((key, value) => 0);
    fixedTagCounts.updateAll((key, value) => 0);
    quickAdjustmentCounts.updateAll((key, value) => 0);
    customItems.clear();
  }

  /// Calculates the individual raw subtotal before taxes/service charge.
  double get individualSubtotal {
    double total = 0.0;

    // Core plates
    plateCounts.forEach((plate, qty) {
      total += plate.price * qty;
    });

    // Fixed price tags
    fixedTagCounts.forEach((price, qty) {
      total += price * qty;
    });

    // Quick adjustments
    quickAdjustmentCounts.forEach((price, qty) {
      total += price * qty;
    });

    // Custom items
    customItems.forEach((price, item) {
      total += item.total;
    });

    return total;
  }

  /// Calculates individual total including a 10% service charge.
  double get individualTotal => individualSubtotal * 1.10;
}
