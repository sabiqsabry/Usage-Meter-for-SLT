import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../../features/usage/models/usage_models.dart';

/// Saves usage data into shared storage so native home-screen widgets can read it.
class WidgetService {
  static const _appGroupId = 'group.com.sabiqsabry.sltUsageMeter';
  static const _androidName = 'SLTUsageWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.registerInteractivityCallback(_backgroundCallback);
  }

  static Future<void> saveAndUpdate({
    required String subscriberId,
    required UsageSummaryBundle? summary,
    required List<UsageDetail> vasBundles,
  }) async {
    await HomeWidget.setAppGroupId(_appGroupId);

    await HomeWidget.saveWidgetData<String>('subscriber_id', subscriberId);
    await HomeWidget.saveWidgetData<String>(
        'status', summary?.status ?? 'Unknown');

    // Main package
    final mainDetails = summary?.myPackageInfo?.usageDetails ?? [];
    final mainJson = jsonEncode(mainDetails.map(_detailToMap).toList());
    await HomeWidget.saveWidgetData<String>('main_usage', mainJson);

    // Bonus / Extra
    final bonusJson = summary?.bonusDataSummary != null
        ? jsonEncode(_summaryToMap(summary!.bonusDataSummary!))
        : null;
    await HomeWidget.saveWidgetData<String?>('bonus_data', bonusJson);

    final extraJson = summary?.extraGbDataSummary != null
        ? jsonEncode(_summaryToMap(summary!.extraGbDataSummary!))
        : null;
    await HomeWidget.saveWidgetData<String?>('extra_gb', extraJson);

    // VAS
    final vasJson = jsonEncode(vasBundles.map(_detailToMap).toList());
    await HomeWidget.saveWidgetData<String>('vas_bundles', vasJson);

    // Timestamp
    await HomeWidget.saveWidgetData<String>(
        'last_updated', DateTime.now().toIso8601String());

    await HomeWidget.updateWidget(
      iOSName: 'SLTUsageMeterWidget',
      androidName: _androidName,
    );
  }

  static Map<String, dynamic> _detailToMap(UsageDetail d) => {
        'name': d.name,
        'used': d.used,
        'limit': d.limit,
        'volume_unit': d.volumeUnit,
        'percentage': d.percentage,
      };

  static Map<String, dynamic> _summaryToMap(PackageSummary s) => {
        'used': s.used,
        'limit': s.limit,
        'volume_unit': s.volumeUnit,
      };

  // Required for interactive widget callbacks (not used yet but required by the package)
  @pragma('vm:entry-point')
  static Future<void> _backgroundCallback(Uri? uri) async {}
}
