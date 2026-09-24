import 'package:flutter/material.dart';
import '../models/plate_type.dart';
import '../theme/sushiro_theme.dart';
import '../providers/checkout_provider.dart';
import '../widgets/table_summary_bottom_sheet.dart';
import '../widgets/history_bottom_sheet.dart';

/// Interactive checkout workspace for the Sushiro Checkout & Split-Bill application.
class SushiroMainScreen extends StatelessWidget {
  const SushiroMainScreen({super.key, required this.provider});

  final CheckoutProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final currentDiner = provider.currentDiner;
        final strings = provider.strings;

        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            titleSpacing: 16.0,
            title: InkWell(
              onTap: () => _showRenameDinerDialog(context, provider.currentDinerIndex, currentDiner.name),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          strings.workspaceName(currentDiner.name),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 16, color: Colors.white70),
                  ],
                ),
              ),
            ),
            actions: [
              // Language toggle button (English <-> Cantonese)
              IconButton(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language, size: 20),
                    const SizedBox(width: 2),
                    Text(
                      strings.isCantonese ? '廣' : 'EN',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                tooltip: strings.isCantonese ? 'Switch to English' : '切換至廣東話',
                onPressed: () => provider.toggleLanguage(),
              ),
              // Theme switcher toggle button
              IconButton(
                icon: Icon(
                  theme.brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                tooltip: theme.brightness == Brightness.dark
                    ? 'Switch to Light Theme'
                    : 'Switch to Dark Theme',
                onPressed: () => provider.toggleThemeMode(theme.brightness),
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: strings.historyTooltip,
                onPressed: () => _showHistorySheet(context),
              ),
            ],
          ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Title header block (STAYS IN ENGLISH AS REQUESTED)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 8.0),
                    child: Text(
                      strings.appTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        fontSize: 32,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                // Top Section: Core Plate List matching the layout card spec exactly
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final plateType = PlateType.values[index];
                        final currentQty = currentDiner.plateCounts[plateType] ?? 0;
                        return _buildPlateListRow(context, plateType, currentQty);
                      },
                      childCount: PlateType.values.length,
                    ),
                  ),
                ),

                // Middle Section Label: Fixed Tags & Adjustments
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      strings.priceTagsHeader,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Grid for Fixed Price Tags + Quick Adjustments
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.25,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final List<double> allTags = [
                          1.0, 2.0, // Quick Adjustments
                          3.0, 6.0, 8.0, 9.0, 12.0, 13.0, 17.0, 18.0, 19.0, 20.0,
                          22.0, 24.0, 27.0, 28.0, 32.0, 33.0, 39.0, 42.0, 48.0, 59.0,
                        ];

                        final price = allTags[index];
                        final isQuickAdj = price == 1.0 || price == 2.0;

                        int qty = 0;
                        if (isQuickAdj) {
                          qty = currentDiner.quickAdjustmentCounts[price] ?? 0;
                        } else {
                          qty = currentDiner.fixedTagCounts[price] ?? 0;
                        }

                        return _buildGridTagItem(context, price, qty, isQuickAdj);
                      },
                      childCount: 22,
                    ),
                  ),
                ),

                // Workspace: Custom Price Picker Block
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildCustomPricePickerCard(context),
                  ),
                ),

                // Bottom Section: Individual real-time totals panel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildIndividualTotalsCard(context),
                  ),
                ),

                // Spacing block before sticky layout footer anchors
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100.0),
                ),
              ],
            ),
          ),
          bottomSheet: _buildStickyFooter(context),
        );
      },
    );
  }

  // --- Top Component Helper: Core Plates Row Layout ---
  Widget _buildPlateListRow(BuildContext context, PlateType type, int qty) {
    final Color plateColor = Color(int.parse(type.hexCode.replaceFirst('#', '0xFF')));
    final bool isDarkPlate = type == PlateType.black;
    final displayLabel = provider.strings.plateLabel(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: plateColor,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayLabel,
              style: TextStyle(
                color: isDarkPlate ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDarkPlate ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: isDarkPlate ? Colors.white : Colors.black87, size: 20),
                    onPressed: () => provider.updatePlateCount(type, -1),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      '$qty',
                      style: TextStyle(
                        color: isDarkPlate ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: isDarkPlate ? Colors.white : Colors.black87, size: 20),
                    onPressed: () => provider.updatePlateCount(type, 1),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Middle Component Helper: Grids ---
  Widget _buildGridTagItem(BuildContext context, double price, int qty, bool isQuickAdj) {
    final theme = Theme.of(context);
    final labelText = '\$${price.toStringAsFixed(0)}';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () {
            if (isQuickAdj) {
              provider.updateQuickAdjustmentCount(price, 1);
            } else {
              provider.updateFixedTagCount(price, 1);
            }
          },
          onLongPress: () {
            if (isQuickAdj) {
              provider.updateQuickAdjustmentCount(price, -1);
            } else {
              provider.updateFixedTagCount(price, -1);
            }
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Ink(
            decoration: BoxDecoration(
              color: isQuickAdj ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12.0),
              border: qty > 0 ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    labelText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isQuickAdj ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isQuickAdj)
                    Text(
                      provider.strings.adjTag,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (qty > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  '$qty',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- Middle Component Helper: Custom Price Workspace Picker ---
  Widget _buildCustomPricePickerCard(BuildContext context) {
    final theme = Theme.of(context);
    final currentDiner = provider.currentDiner;
    final strings = provider.strings;
    
    final matchingPickerQty = currentDiner.customItems[provider.customPricePickerValue]?.quantity ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.customPriceWorkspaceTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 28),
                  onPressed: () => provider.adjustCustomPricePicker(-1.0),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        '\$${provider.customPricePickerValue.toStringAsFixed(0)}',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 28),
                  onPressed: () => provider.adjustCustomPricePicker(1.0),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.customPricePickerValue > 0 ? () => provider.subtractCustomItemFromCurrentPerson() : null,
                    icon: const Icon(Icons.remove),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(strings.subtractItem),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.customPricePickerValue > 0 ? () => provider.addCustomItemToCurrentPerson() : null,
                    icon: const Icon(Icons.add),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(strings.addItem(matchingPickerQty)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Bottom Component Helper: Real-time Roster Summary ---
  Widget _buildIndividualTotalsCard(BuildContext context) {
    final theme = Theme.of(context);
    final currentDiner = provider.currentDiner;
    final strings = provider.strings;

    return Card(
      elevation: 4,
      color: theme.colorScheme.primaryContainer.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strings.dinerSubtotal, style: theme.textTheme.titleMedium),
                Text(
                  '\$${currentDiner.individualSubtotal.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    strings.dinerTotalWithService,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${currentDiner.individualTotal.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (provider.diners.length > 1) ...[
                  IconButton(
                    icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent),
                    tooltip: strings.removeDiner,
                    onPressed: () => _confirmRemoveDinerDialog(context, provider.currentDinerIndex, currentDiner.name),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(strings.resetPerson, style: const TextStyle(color: Colors.red)),
                    ),
                    onPressed: () => provider.resetCurrentPerson(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.navigate_next),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(strings.calculateNext),
                    ),
                    onPressed: () => provider.calculateNext(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- Sticky Roster Footer Element ---
  Widget _buildStickyFooter(BuildContext context) {
    final strings = provider.strings;

    return Container(
      color: Theme.of(context).cardColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SushiroTheme.brandRed,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            onPressed: () => _showTableSummarySheet(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    strings.viewTableSummary(provider.diners.length, provider.totalItemCountAllDiners),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Launch Separated Modal Bottom Sheet ---
  void _showTableSummarySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TableSummaryBottomSheet(provider: provider),
    );
  }

  // --- Launch Spending History Modal Sheet ---
  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoryBottomSheet(provider: provider),
    );
  }

  /*
  // --- Reset Entire Table Confirmation dialog ---
  void _confirmResetTable(BuildContext context) {
    final strings = provider.strings;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.resetTableTitle),
        content: Text(strings.resetTableContent),
        actions: [
          TextButton(
            child: Text(strings.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(strings.reset, style: const TextStyle(color: Colors.red)),
            onPressed: () {
              provider.resetEntireTable();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  */

  // --- Show Dialog to Rename a Diner ---
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
