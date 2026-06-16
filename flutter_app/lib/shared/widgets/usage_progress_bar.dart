import 'package:flutter/material.dart';
import '../../features/usage/models/usage_models.dart';

class UsageProgressBar extends StatelessWidget {
  final UsageDetail usage;
  final bool invertProgress;

  const UsageProgressBar({
    super.key,
    required this.usage,
    this.invertProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayFraction =
        invertProgress ? (1 - usage.usedFraction) : usage.usedFraction;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  usage.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (usage.isUnlimited)
                Row(
                  children: [
                    Text(
                      '${usage.formattedUsed()} ${usage.volumeUnit}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(width: 6),
                    _UnlimitedBadge(),
                  ],
                )
              else
                Text(
                  '${usage.formattedUsed()} / ${usage.formattedLimit()} ${usage.volumeUnit}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
            ],
          ),
          if (!usage.isUnlimited) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: displayFraction,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (usage.expiryDate != null)
                  Text(
                    'Expires: ${usage.expiryDate}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                const Spacer(),
                if (usage.remaining != null) ...[
                  Text(
                    'Remaining: ${usage.formattedRemaining()} ${usage.volumeUnit}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  '${usage.remainingPercentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _UnlimitedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF9C27B0).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Unlimited',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.purple,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
      ),
    );
  }
}

class UsageCard extends StatelessWidget {
  final String title;
  final UsageDetail usage;
  final Color accentColor;
  final IconData icon;

  const UsageCard({
    super.key,
    required this.title,
    required this.usage,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: accentColor),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                ),
                const Spacer(),
                if (usage.isUnlimited)
                  Row(
                    children: [
                      Text(
                        '${usage.formattedUsed()} ${usage.volumeUnit}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: 6),
                      _UnlimitedBadge(),
                    ],
                  )
                else
                  Text(
                    '${usage.formattedUsed()} / ${usage.formattedLimit()} ${usage.volumeUnit}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
            if (!usage.isUnlimited) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: usage.usedFraction,
                  minHeight: 6,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    'Remaining: ${usage.formattedRemaining()} ${usage.volumeUnit}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${usage.remainingPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: accentColor,
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
