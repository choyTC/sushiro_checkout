import 'plate_type.dart';

enum AppLanguage { en, cantonese }

/// Contains localized UI strings for English and Cantonese.
class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  bool get isCantonese => language == AppLanguage.cantonese;

  // --- App Title MUST REMAIN IN ENGLISH AS REQUIRED ---
  String get appTitle => 'Sushiro\nCheckout';

  String workspaceName(String name) =>
      isCantonese ? '$name 的結帳單' : '$name\'s Workspace';

  String get resetTableTooltip => isCantonese ? '重置全枱' : 'Reset Seating Table';
  String get resetTableTitle => isCantonese ? '重置整張枱？' : 'Reset Entire Table?';
  String get resetTableContent => isCantonese
      ? '這將永久清除所有食客紀錄並重新開始。'
      : 'This will permanently wipe all diners data fields and clear the active seating matrix back to scratch.';
  String get cancel => isCantonese ? '取消' : 'Cancel';
  String get reset => isCantonese ? '重置' : 'Reset';

  String plateLabel(PlateType type) {
    if (isCantonese) {
      switch (type) {
        case PlateType.red:
          return '紅碟';
        case PlateType.silver:
          return '銀碟';
        case PlateType.gold:
          return '金碟';
        case PlateType.black:
          return '黑碟';
      }
    } else {
      switch (type) {
        case PlateType.red:
          return 'Red Dish';
        case PlateType.silver:
          return 'Metallic Silver';
        case PlateType.gold:
          return 'Amber Gold';
        case PlateType.black:
          return 'Deep Black';
      }
    }
  }

  String get priceTagsHeader => isCantonese
      ? '價錢牌與微調 (點擊新增，長按扣減)'
      : 'Price Tags & Adjustments (Tap to Add, Long Press to Subtract)';

  String get adjTag => isCantonese ? '微調' : 'Adj';

  String get customPriceWorkspaceTitle =>
      isCantonese ? '自訂金額工作區' : 'Custom Price Entry Workspace';
  String get subtractItem => isCantonese ? '扣減項目' : 'Subtract Item';
  String addItem(int qty) {
    if (qty > 0) {
      return isCantonese ? '新增項目 ($qty)' : 'Add Item ($qty)';
    }
    return isCantonese ? '新增項目' : 'Add Item';
  }

  String get dinerSubtotal => isCantonese ? '個人小計：' : 'Diner Subtotal:';
  String get dinerTotalWithService =>
      isCantonese ? '個人總額 (含10%加一)：' : 'Diner Total (Incl. 10% Service):';
  String get resetPerson => isCantonese ? '重置個人' : 'Reset Person';
  String get calculateNext => isCantonese ? '計算下一位' : 'Calculate Next';

  String viewTableSummary(int dinersCount, int itemsCount) => isCantonese
      ? '查看全枱結算 ($dinersCount 位食客 • $itemsCount 件)'
      : 'View Table Summary ($dinersCount Diners • $itemsCount Items)';

  String get masterTableOverview => isCantonese ? '全枱總覽' : 'Master Table Overview';
  String get grandTotalWithService =>
      isCantonese ? '全枱總額 (含10%加一)' : 'Grand Total (Inc. 10% Service)';
  String tableSummarySubtitle(int items, int diners) => isCantonese
      ? '$items 件項目，共 $diners 位食客'
      : '$items items across $diners diners';
  String get activeTag => isCantonese ? '現時' : 'Active';
  String itemsTracked(int count) =>
      isCantonese ? '$count 件項目' : '$count items tracked';
  String get startNewTable => isCantonese ? '開始新一枱' : 'Start New Table';
  String get startFresh => isCantonese ? '重新開始' : 'Start Fresh';

  String get renameDiner => isCantonese ? '更改食客名稱' : 'Rename Diner';
  String get dinerNameLabel => isCantonese ? '食客名稱' : 'Diner Name';
  String get enterNameHint => isCantonese ? '輸入名稱' : 'Enter name';
  String get save => isCantonese ? '儲存' : 'Save';

  // --- Remove Diner Strings ---
  String get removeDiner => isCantonese ? '刪除食客' : 'Remove Diner';
  String confirmRemoveDinerTitle(String name) =>
      isCantonese ? '刪除 $name？' : 'Remove $name?';
  String confirmRemoveDinerContent(String name) => isCantonese
      ? '此操作將刪除 $name 並清除其所有已選碟數紀錄。'
      : 'This will remove $name and clear all their selected dishes from the bill.';
  String get remove => isCantonese ? '刪除' : 'Remove';

  // --- History Feature Strings ---
  String get historyTooltip => isCantonese ? '消費歷史紀錄' : 'Spending History';
  String get historyTitle => isCantonese ? '消費歷史紀錄' : 'Spending History';
  String get noHistory => isCantonese ? '暫無消費紀錄' : 'No history records yet';
  String get clearHistory => isCantonese ? '清除歷史' : 'Clear History';
  String get confirmClearHistoryTitle => isCantonese ? '清除所有歷史紀錄？' : 'Clear All History?';
  String get confirmClearHistoryContent => isCantonese
      ? '此操作將永久清除所有儲存的消費紀錄。'
      : 'This action will permanently wipe all saved spending history records.';
  String get historyDetailTitle => isCantonese ? '歷史紀錄詳情' : 'History Record Details';
  String recordSavedAt(String dateStr) =>
      isCantonese ? '儲存時間: $dateStr' : 'Saved at: $dateStr';
}
