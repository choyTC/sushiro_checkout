/// Represents a snapshot of a single diner's order in a historical session.
class DinerHistorySnapshot {
  final String dinerName;
  final int totalItems;
  final double individualSubtotal;
  final double individualTotal;

  DinerHistorySnapshot({
    required this.dinerName,
    required this.totalItems,
    required this.individualSubtotal,
    required this.individualTotal,
  });
}

/// Represents a historical spending record for a master table checkout session.
class TableHistoryRecord {
  final String id;
  final DateTime timestamp;
  final int totalDiners;
  final int totalItemsAllDiners;
  final double masterTableSubtotal;
  final int masterTableFinalTotal;
  final List<DinerHistorySnapshot> dinerSnapshots;

  TableHistoryRecord({
    required this.id,
    required this.timestamp,
    required this.totalDiners,
    required this.totalItemsAllDiners,
    required this.masterTableSubtotal,
    required this.masterTableFinalTotal,
    required this.dinerSnapshots,
  });

  /// Formats timestamp as YYYY-MM-DD HH:mm:ss.
  String get formattedTimestamp {
    final y = timestamp.year;
    final m = timestamp.month.toString().padLeft(2, '0');
    final d = timestamp.day.toString().padLeft(2, '0');
    final hh = timestamp.hour.toString().padLeft(2, '0');
    final mm = timestamp.minute.toString().padLeft(2, '0');
    final ss = timestamp.second.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm:$ss';
  }
}
