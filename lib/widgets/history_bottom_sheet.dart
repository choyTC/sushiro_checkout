import 'package:flutter/material.dart';
import '../providers/checkout_provider.dart';
import '../models/table_history_record.dart';
import '../theme/sushiro_theme.dart';

/// Modal bottom sheet displaying recorded spending history items.
class HistoryBottomSheet extends StatelessWidget {
  const HistoryBottomSheet({super.key, required this.provider});

  final CheckoutProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = provider.strings;
    final records = provider.historyRecords;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: SushiroTheme.brandRed),
                    const SizedBox(width: 8),
                    Text(
                      strings.historyTitle,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 12.0),

            // History list or empty state
            Expanded(
              child: records.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            strings.noHistory,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: records.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final record = records[index];

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor: theme.colorScheme.onPrimaryContainer,
                            child: Text('#${records.length - index}'),
                          ),
                          title: Text(
                            '\$${record.masterTableFinalTotal}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: SushiroTheme.brandRed,
                            ),
                          ),
                          subtitle: Text(
                            '${strings.recordSavedAt(record.formattedTimestamp)}\n${strings.tableSummarySubtitle(record.totalItemsAllDiners, record.totalDiners)}',
                            style: theme.textTheme.bodySmall,
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showRecordDetailDialog(context, record),
                        );
                      },
                    ),
            ),

            if (records.isNotEmpty) ...[
              const Divider(height: 24, thickness: 1.5),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: Text(strings.clearHistory),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _confirmClearHistoryDialog(context),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Displays detailed breakdown for a clicked historical record.
  void _showRecordDetailDialog(BuildContext context, TableHistoryRecord record) {
    final theme = Theme.of(context);
    final strings = provider.strings;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.historyDetailTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.recordSavedAt(record.formattedTimestamp),
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Grand total card
              Card(
                color: theme.colorScheme.primaryContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.grandTotalWithService,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            strings.tableSummarySubtitle(record.totalItemsAllDiners, record.totalDiners),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${record.masterTableFinalTotal}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Diners list breakdown
              ...record.dinerSnapshots.map(
                (diner) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diner.dinerName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            strings.itemsTracked(diner.totalItems),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Text(
                        '\$${diner.individualTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(strings.cancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Displays confirmation dialog before wiping history.
  void _confirmClearHistoryDialog(BuildContext context) {
    final strings = provider.strings;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmClearHistoryTitle),
        content: Text(strings.confirmClearHistoryContent),
        actions: [
          TextButton(
            child: Text(strings.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(strings.clearHistory, style: const TextStyle(color: Colors.red)),
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
