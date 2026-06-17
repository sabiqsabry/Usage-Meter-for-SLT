import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usage_provider.dart';
import '../models/usage_models.dart';
import '../../../shared/widgets/usage_progress_bar.dart';

class UsageScreen extends StatelessWidget {
  const UsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UsageProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Fetching usage data…'),
              ],
            ),
          );
        }

        if (provider.errorMessage != null) {
          return _ErrorView(
            message: provider.errorMessage!,
            onRetry: provider.init,
          );
        }

        final summary = provider.usageSummary;

        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: CustomScrollView(
            slivers: [
              // ── Status card ──────────────────────────────────────────────
              if (summary != null)
                SliverToBoxAdapter(
                  child: _StatusCard(summary: summary),
                ),

              // ── Main package usage bars ──────────────────────────────────
              if (summary?.myPackageInfo != null) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                    child: Text(
                      summary!.myPackageInfo!.packageName,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: UsageProgressBar(
                          usage: summary.myPackageInfo!.usageDetails[i],
                        ),
                      ),
                    ),
                    childCount:
                        summary.myPackageInfo!.usageDetails.length,
                  ),
                ),
              ],

              // ── Bonus / Extra GB quick stats ─────────────────────────────
              if (summary != null &&
                  (summary.bonusDataSummary != null ||
                      summary.extraGbDataSummary != null)) ...[
                _sectionHeader(context, 'Data Packs'),
                if (summary.bonusDataSummary != null)
                  SliverToBoxAdapter(
                    child: _SummaryCard(
                      title: 'Bonus Data',
                      summary: summary.bonusDataSummary!,
                      color: Colors.purple,
                      icon: Icons.card_giftcard_rounded,
                    ),
                  ),
                if (summary.extraGbDataSummary != null)
                  SliverToBoxAdapter(
                    child: _SummaryCard(
                      title: 'Extra GB',
                      summary: summary.extraGbDataSummary!,
                      color: Colors.orange,
                      icon: Icons.add_circle_outline_rounded,
                    ),
                  ),
              ],

              // ── VAS / Add-on bundles ─────────────────────────────────────
              if (provider.vasBundles.isNotEmpty) ...[
                _sectionHeader(context, 'Add-on Bundles'),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: UsageProgressBar(
                            usage: provider.vasBundles[i]),
                      ),
                    ),
                    childCount: provider.vasBundles.length,
                  ),
                ),
              ],

              // ── Empty state ──────────────────────────────────────────────
              if (summary != null &&
                  summary.myPackageInfo == null &&
                  provider.vasBundles.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No usage data available for this connection.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  SliverToBoxAdapter _sectionHeader(BuildContext context, String title) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );
}

// ── Status card ──────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final UsageSummaryBundle summary;
  const _StatusCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: summary.statusColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: summary.statusColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Status',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.status,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.wifi_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

// ── Bonus / Extra GB summary card ─────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String title;
  final PackageSummary summary;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.summary,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final used = double.tryParse(summary.used) ?? 0;
    final limit = summary.limit != null ? double.tryParse(summary.limit!) : null;
    final fraction =
        limit != null && limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final remaining = limit != null ? (limit - used).clamp(0.0, double.infinity) : null;

    String fmt(double v) =>
        v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        )),
                const Spacer(),
                if (limit != null)
                  Text(
                    '${fmt(used)} / ${fmt(limit)} ${summary.volumeUnit}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  )
                else
                  Text('${fmt(used)} ${summary.volumeUnit}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          )),
              ],
            ),
            if (limit != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    'Remaining: ${fmt(remaining!)} ${summary.volumeUnit}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${((1 - fraction) * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
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
}

// ── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
