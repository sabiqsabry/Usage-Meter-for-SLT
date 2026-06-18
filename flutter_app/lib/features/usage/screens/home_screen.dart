import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usage_provider.dart';
import '../../account/screens/account_screen.dart';
import 'usage_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    (label: 'Usage',   icon: CupertinoIcons.chart_bar,    selectedIcon: CupertinoIcons.chart_bar_fill),
    (label: 'Account', icon: CupertinoIcons.person,        selectedIcon: CupertinoIcons.person_fill),
  ];

  static const _bodies = <Widget>[
    UsageScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsageProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Usage Meter for SLT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          _AccountSelectorButton(),
        ],
      ),
      body: _bodies[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _AccountSelectorButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UsageProvider>(
      builder: (context, provider, _) {
        if (provider.accounts.length <= 1) return const SizedBox.shrink();

        return PopupMenuButton(
          icon: const Icon(CupertinoIcons.person_circle),
          tooltip: 'Select account',
          itemBuilder: (_) => provider.accounts
              .map((acc) => PopupMenuItem(
                    value: acc,
                    child: Row(
                      children: [
                        if (provider.selectedAccount == acc)
                          const Icon(CupertinoIcons.checkmark_circle, size: 18)
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Text(acc.telephoneno),
                      ],
                    ),
                  ))
              .toList(),
          onSelected: provider.selectAccount,
        );
      },
    );
  }
}
