import 'package:flutter/material.dart';

class SkySideBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool isPermanent;

  const SkySideBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.isPermanent = false,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 20, 16, 10),
          child: Text(
            'MENU PRINCIPALE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.file_upload_outlined),
          selectedIcon: Icon(Icons.file_upload),
          label: Text('Carica File'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: Text('Tracciato Contabile'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet),
          label: Text('Estratti Conto'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.fact_check_outlined),
          selectedIcon: Icon(Icons.fact_check),
          label: Text('Controlli Trasferte'),
        ),
        const Divider(indent: 28, endIndent: 28),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            'CONFIGURAZIONE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Impostazioni'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.help_outline),
          selectedIcon: Icon(Icons.help),
          label: Text('Supporto'),
        ),
      ],
    );
  }
}
