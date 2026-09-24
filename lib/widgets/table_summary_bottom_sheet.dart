import 'package:flutter/material.dart';
import '../providers/checkout_provider.dart';
import '../theme/sushiro_theme.dart';

/// A modal bottom sheet displaying a comprehensive checkout receipt summary
/// for all diners at the table, along with billing breakdown and factory reset options.
class TableSummaryBottomSheet extends StatelessWidget {
  const TableSummaryBottomSheet({super.key, required this.provider});

  final CheckoutProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = provider.strings;
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
            // Drag handle bar indicator
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
                Text(
                  strings.masterTableOverview,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 8.0),

            // Scrollable body containing cost summary card and itemized diners list
            Expanded(
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverToBoxAdapter(
                    child: Card(
                      color: theme.colorScheme.primaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.grandTotalWithService,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    strings.tableSummarySubtitle(provider.totalItemCountAllDiners, provider.diners.length),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '\$${provider.masterTableFinalTotal}',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final diner = provider.diners[index];
                        final isCurrent = provider.currentDinerIndex == index;
                        
                        final int totalItems = diner.plateCounts.values.fold<int>(0, (a, b) => a + b) +
                            diner.fixedTagCounts.values.fold<int>(0, (a, b) => a + b) +
                            diner.quickAdjustmentCounts.values.fold<int>(0, (a, b) => a + b) +
                            diner.customItems.values.fold<int>(0, (a, b) => a + b.quantity);

                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              leading: CircleAvatar(
                                backgroundColor: isCurrent ? SushiroTheme.brandRed : theme.colorScheme.outlineVariant,
                                foregroundColor: isCurrent ? Colors.white : theme.colorScheme.onSurface,
                                child: Text('${index + 1}'),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      diner.name,
                                      style: TextStyle(
                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () => _showRenameDinerDialog(context, index, diner.name),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                    tooltip: strings.removeDiner,
                                    onPressed: () => _confirmRemoveDinerDialog(context, index, diner.name),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: SushiroTheme.brandRed.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        strings.activeTag,
                                        style: const TextStyle(fontSize: 10, color: SushiroTheme.brandRed, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              subtitle: Text(strings.itemsTracked(totalItems)),
                              trailing: Text(
                                '\$${diner.individualTotal.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? SushiroTheme.brandRed : theme.colorScheme.onSurface,
                                ),
                              ),
                              onTap: () {
                                provider.selectPerson(index);
                                Navigator.pop(context);
                              },
                            ),
                            if (index < provider.diners.length - 1) const Divider(height: 1),
                          ],
                        );
                      },
                      childCount: provider.diners.length,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 24, thickness: 1.5),

            // Action operations row summary block
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: Text(strings.startNewTable),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _confirmNewTableDialog(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Displays warning confirmation prompt before wiping billing data.
  void _confirmNewTableDialog(BuildContext context) {
    final strings = provider.strings;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${strings.startNewTable}?'),
        content: Text(strings.resetTableContent),
        actions: [
          TextButton(
            child: Text(strings.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(strings.startFresh, style: const TextStyle(color: Colors.red)),
            onPressed: () {
              provider.resetEntireTable();
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// Displays dialog to rename an itemized diner from the summary board list view.
  void _showRenameDinerDialog(BuildContext context, int index, String currentName) {
    final textController = TextEditingController(text: currentName);
    final strings = provider.strings;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.renameDiner),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: strings.dinerNameLabel,
            hintText: strings.enterNameHint,
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            child: Text(strings.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(strings.save),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                provider.updateDinerName(index, textController.text.trim());
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// Displays confirmation dialog before removing a diner and clearing their dishes.
  void _confirmRemoveDinerDialog(BuildContext context, int index, String dinerName) {
    final strings = provider.strings;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmRemoveDinerTitle(dinerName)),
        content: Text(strings.confirmRemoveDinerContent(dinerName)),
        actions: [
          TextButton(
            child: Text(strings.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(strings.remove, style: const TextStyle(color: Colors.red)),
            onPressed: () {
              provider.removeDiner(index);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
