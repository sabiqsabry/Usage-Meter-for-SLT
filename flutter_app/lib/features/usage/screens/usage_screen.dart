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
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return _ErrorView(
            message: provider.errorMessage!,
            onRetry: provider.init,
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: CustomScrollView(
            slivers: [
              // Status card
              if (provider.usageSummary != null)
                SliverToBoxAdapter(
                  child: _StatusCard(summary: provider.usageSummary!),
                ),

              // Total bundle
              if (provider.usageSummary?.totalBundle != null) ...[
                _SectionHeader(title: 'Main Bundle'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: UsageProgressBar(
                      usage: provider.usageSummary!.totalBundle!,
                    ),
                  ),
                ),
              ],

              // Data packs
              if (provider.usageSummary?.bonusDataSummary != null ||
                  provider.usageSummary?.extraGbDataSummary != null) ...[
                _SectionHeader(title: 'Data Packs'),
                if (provider.usageSummary?.bonusDataSummary != null)
                  SliverToBoxAdapter(
                    child: UsageCard(
                      title: 'Bonus Data',
                      usage: provider.usageSummary!.bonusDataSummary!,
                      accentColor: Colors.purple,
                      icon: Icons.card_giftcard_rounded,
                    ),
                  ),
                if (provider.usageSummary?.extraGbDataSummary != null)
                  SliverToBoxAdapter(
                    child: UsageCard(
                      title: 'Extra GB',
                      usage: provider.usageSummary!.extraGbDataSummary!,
                      accentColor: Colors.orange,
                      icon: Icons.add_circle_outline_rounded,
                    ),
                  ),
              ],

              // VAS bundles
              if (provider.vasBundles.isNotEmpty) ...[
                _SectionHeader(title: 'Add-on Bundles'),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: UsageProgressBar(
                            usage: provider.vasBundles[index],
                          ),
                        ),
                      ),
                    ),
                    childCount: provider.vasBundles.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

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
