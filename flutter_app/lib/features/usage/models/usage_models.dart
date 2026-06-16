import 'package:flutter/material.dart';

class AccountInfo {
  final String telephoneno;
  final String? accountName;

  AccountInfo({required this.telephoneno, this.accountName});

  factory AccountInfo.fromJson(Map<String, dynamic> json) => AccountInfo(
        telephoneno: json['telephoneno'] as String? ?? '',
        accountName: json['accountName'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is AccountInfo && other.telephoneno == telephoneno;

  @override
  int get hashCode => telephoneno.hashCode;
}

class BroadbandService {
  final String serviceId;
  final String serviceType;

  BroadbandService({required this.serviceId, required this.serviceType});

  factory BroadbandService.fromJson(Map<String, dynamic> json) =>
      BroadbandService(
        serviceId: json['serviceID'] as String? ?? '',
        serviceType: json['serviceType'] as String? ?? '',
      );
}

class ServiceDetailBundle {
  final String accountNo;
  final String? contactNameWithInit;
  final String? promotionName;
  final List<BroadbandService> bbServices;

  ServiceDetailBundle({
    required this.accountNo,
    this.contactNameWithInit,
    this.promotionName,
    required this.bbServices,
  });

  factory ServiceDetailBundle.fromJson(Map<String, dynamic> json) =>
      ServiceDetailBundle(
        accountNo: json['accountNo'] as String? ?? '',
        contactNameWithInit: json['contactNamewithInit'] as String?,
        promotionName: json['promotionName'] as String?,
        bbServices: ((json['listofBBService'] as List?) ?? [])
            .map((e) => BroadbandService.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class UsageDetail {
  final String name;
  final String used;
  final String? limit;
  final String? remaining;
  final String volumeUnit;
  final String? expiryDate;

  UsageDetail({
    required this.name,
    required this.used,
    this.limit,
    this.remaining,
    required this.volumeUnit,
    this.expiryDate,
  });

  factory UsageDetail.fromJson(Map<String, dynamic> json) => UsageDetail(
        name: json['name'] as String? ?? '',
        used: json['used']?.toString() ?? '0',
        limit: json['limit']?.toString(),
        remaining: json['remaining']?.toString(),
        volumeUnit: json['volumeUnit'] as String? ?? 'GB',
        expiryDate: json['expiryDate'] as String?,
      );

  double get usedDouble => double.tryParse(used) ?? 0;
  double? get limitDouble => limit != null ? double.tryParse(limit!) : null;
  double? get remainingDouble =>
      remaining != null ? double.tryParse(remaining!) : null;

  bool get isUnlimited => limitDouble == null;

  double get usedFraction {
    if (isUnlimited) return 0;
    final l = limitDouble!;
    if (l <= 0) return 0;
    return (usedDouble / l).clamp(0.0, 1.0);
  }

  double get remainingPercentage =>
      isUnlimited ? 100 : (1 - usedFraction) * 100;

  String formattedUsed() => _formatVolume(usedDouble);
  String formattedLimit() => _formatVolume(limitDouble ?? 0);
  String formattedRemaining() => _formatVolume(remainingDouble ?? 0);

  static String _formatVolume(double value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(2)} TB';
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}

class UsageSummaryBundle {
  final String status;
  final UsageDetail? totalBundle;
  final UsageDetail? bonusDataSummary;
  final UsageDetail? extraGbDataSummary;

  UsageSummaryBundle({
    required this.status,
    this.totalBundle,
    this.bonusDataSummary,
    this.extraGbDataSummary,
  });

  factory UsageSummaryBundle.fromJson(Map<String, dynamic> json) =>
      UsageSummaryBundle(
        status: json['status'] as String? ?? 'Unknown',
        totalBundle: json['totalBundle'] != null
            ? UsageDetail.fromJson(json['totalBundle'] as Map<String, dynamic>)
            : null,
        bonusDataSummary: json['bonusDataSummary'] != null
            ? UsageDetail.fromJson(
                json['bonusDataSummary'] as Map<String, dynamic>)
            : null,
        extraGbDataSummary: json['extraGBDataSummary'] != null
            ? UsageDetail.fromJson(
                json['extraGBDataSummary'] as Map<String, dynamic>)
            : null,
      );

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF2ECC71);
      case 'suspended':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFFF39C12);
    }
  }
}
