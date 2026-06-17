import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Account
// ---------------------------------------------------------------------------

class AccountInfo {
  final String accountno;
  final String telephoneno;
  final String status;

  AccountInfo({
    required this.accountno,
    required this.telephoneno,
    required this.status,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) => AccountInfo(
        accountno: json['accountno'] as String? ?? '',
        telephoneno: json['telephoneno'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) =>
      other is AccountInfo && other.accountno == accountno;

  @override
  int get hashCode => accountno.hashCode;
}

// ---------------------------------------------------------------------------
// Service Detail
// ---------------------------------------------------------------------------

class BroadbandService {
  final String serviceId;
  final String packageName;
  final String serviceStatus;
  final String serviceType;

  BroadbandService({
    required this.serviceId,
    required this.packageName,
    required this.serviceStatus,
    required this.serviceType,
  });

  factory BroadbandService.fromJson(Map<String, dynamic> json) =>
      BroadbandService(
        serviceId: json['serviceID'] as String? ?? '',
        packageName: json['packageName'] as String? ?? '',
        serviceStatus: json['serviceStatus'] as String? ?? '',
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

// ---------------------------------------------------------------------------
// Usage Detail  (used in both package info and VAS bundles)
// ---------------------------------------------------------------------------

class UsageDetail {
  final String name;
  final String? limit;
  final String? remaining;
  final String used;
  final int percentage;
  final String volumeUnit;
  final String? expiryDate;
  final String? subscriptionId;

  UsageDetail({
    required this.name,
    this.limit,
    this.remaining,
    required this.used,
    required this.percentage,
    required this.volumeUnit,
    this.expiryDate,
    this.subscriptionId,
  });

  factory UsageDetail.fromJson(Map<String, dynamic> json) => UsageDetail(
        name: _sanitize(json['name'] as String? ?? ''),
        limit: json['limit']?.toString(),
        remaining: json['remaining']?.toString(),
        used: json['used']?.toString() ?? '0',
        percentage: _parseInt(json['percentage']),
        volumeUnit: json['volume_unit'] as String? ?? 'GB',
        expiryDate: json['expiry_date'] as String?,
        subscriptionId: json['subscriptionid'] as String?,
      );

  // Strip trailing period (mirrors Swift's removingTrailingPeriod)
  static String _sanitize(String s) {
    final t = s.trim();
    return t.endsWith('.') ? t.substring(0, t.length - 1).trim() : t;
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  double get usedDouble => double.tryParse(used) ?? 0;
  double? get limitDouble => limit != null ? double.tryParse(limit!) : null;
  double? get remainingDouble =>
      remaining != null ? double.tryParse(remaining!) : null;

  bool get isUnlimited => limitDouble == null;

  double get usedFraction {
    if (isUnlimited) return 0;
    final l = limitDouble!;
    return l <= 0 ? 0 : (usedDouble / l).clamp(0.0, 1.0);
  }

  String formattedUsed() => _fmt(usedDouble);
  String formattedLimit() => _fmt(limitDouble ?? 0);
  String formattedRemaining() => _fmt(remainingDouble ?? 0);

  static String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
}

// ---------------------------------------------------------------------------
// Package Summary  (used for bonus / extra-gb quick stats)
// ---------------------------------------------------------------------------

class PackageSummary {
  final String? limit;
  final String used;
  final String volumeUnit;

  PackageSummary({this.limit, required this.used, required this.volumeUnit});

  factory PackageSummary.fromJson(Map<String, dynamic> json) => PackageSummary(
        limit: json['limit']?.toString(),
        used: json['used']?.toString() ?? '0',
        volumeUnit: json['volume_unit'] as String? ?? 'GB',
      );
}

// ---------------------------------------------------------------------------
// Package Info  (holds the main usage bars for a connection)
// ---------------------------------------------------------------------------

class PackageInfo {
  final String packageName;
  final List<UsageDetail> usageDetails;

  PackageInfo({required this.packageName, required this.usageDetails});

  factory PackageInfo.fromJson(Map<String, dynamic> json) => PackageInfo(
        packageName: UsageDetail._sanitize(
            json['package_name'] as String? ?? ''),
        usageDetails: ((json['usageDetails'] as List?) ?? [])
            .map((e) => UsageDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// Usage Summary Bundle  (top-level response from /BBVAS/UsageSummary)
// ---------------------------------------------------------------------------

class UsageSummaryBundle {
  final String status;
  final PackageSummary? myPackageSummary;
  final PackageSummary? bonusDataSummary;
  final PackageSummary? extraGbDataSummary;
  final PackageInfo? myPackageInfo;

  UsageSummaryBundle({
    required this.status,
    this.myPackageSummary,
    this.bonusDataSummary,
    this.extraGbDataSummary,
    this.myPackageInfo,
  });

  factory UsageSummaryBundle.fromJson(Map<String, dynamic> json) =>
      UsageSummaryBundle(
        status: json['status'] as String? ?? 'Unknown',
        myPackageSummary: json['my_package_summary'] != null
            ? PackageSummary.fromJson(
                json['my_package_summary'] as Map<String, dynamic>)
            : null,
        bonusDataSummary: json['bonus_data_summary'] != null
            ? PackageSummary.fromJson(
                json['bonus_data_summary'] as Map<String, dynamic>)
            : null,
        extraGbDataSummary: json['extra_gb_data_summary'] != null
            ? PackageSummary.fromJson(
                json['extra_gb_data_summary'] as Map<String, dynamic>)
            : null,
        myPackageInfo: json['my_package_info'] != null
            ? PackageInfo.fromJson(
                json['my_package_info'] as Map<String, dynamic>)
            : null,
      );

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'NORMAL':
      case 'ACTIVE':
        return const Color(0xFF2ECC71);
      case 'THROTTLED':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFFF39C12);
    }
  }
}
