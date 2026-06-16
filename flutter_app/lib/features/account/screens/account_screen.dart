import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../usage/providers/usage_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usage = context.watch<UsageProvider>();
    final service = usage.serviceDetail;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (service != null) ...[
          _SectionCard(
            title: 'Service Information',
            children: [
              _InfoRow(
                  label: 'Account Name',
                  value: service.contactNameWithInit ?? '—'),
              _InfoRow(label: 'Account No', value: service.accountNo),
              _InfoRow(label: 'Plan', value: service.promotionName ?? '—'),
              if (service.bbServices.isNotEmpty) ...[
                _InfoRow(
                    label: 'Service ID',
                    value: service.bbServices.first.serviceId),
                _InfoRow(
                    label: 'Service Type',
                    value: service.bbServices.first.serviceType),
              ],
            ],
          ),
          const SizedBox(height: 12),
        ],

        // App info card
        _SectionCard(
          title: 'About',
          children: const [
            _InfoRow(label: 'App', value: 'SLT Usage Meter'),
            _InfoRow(label: 'Version', value: '1.0.0'),
            _InfoRow(label: 'Platform', value: 'Cross-platform (Flutter)'),
          ],
        ),

        const SizedBox(height: 24),

        // Logout button
        Consumer<AuthProvider>(
          builder: (context, auth, _) => OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text(
                      'Are you sure you want to logout? Your saved session will be cleared.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Logout')),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                context.read<UsageProvider>().reset();
                await auth.logout();
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Usage Meter for SLT is an independent app and is not affiliated with or endorsed by SLT Mobitel.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children
                .map((w) => Column(
                      children: [
                        w,
                        if (w != children.last)
                          Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: cs.outlineVariant.withValues(alpha: 0.5)),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
          const Spacer(),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
