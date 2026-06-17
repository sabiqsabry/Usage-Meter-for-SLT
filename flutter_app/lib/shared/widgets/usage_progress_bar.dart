import 'package:flutter/material.dart';
import '../../features/usage/models/usage_models.dart';

class UsageProgressBar extends StatelessWidget {
  final UsageDetail usage;

  const UsageProgressBar({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + amount
          Row(
            children: [
              Expanded(
                child: Text(
                  usage.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
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

          // Progress bar
          if (!usage.isUnlimited) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: usage.usedFraction,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _barColor(usage.usedFraction, cs),
                ),
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
                if (usage.remaining != null)
                  Text(
                    'Remaining: ${usage.formattedRemaining()} ${usage.volumeUnit}  ',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                Text(
                  '${((1 - usage.usedFraction) * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _barColor(usage.usedFraction, cs),
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Green → orange → red as usage increases
  Color _barColor(double fraction, ColorScheme cs) {
    if (fraction < 0.7) return cs.primary;
    if (fraction < 0.9) return Colors.orange;
    return Colors.red;
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
              color: const Color(0xFF9C27B0),
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
      ),
    );
  }
}
