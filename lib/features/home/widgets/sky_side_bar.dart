import 'package:flutter/material.dart';

class SkySideBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool isPermanent;
  final bool isCollapsed;

  const SkySideBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.isPermanent = false,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.none,
                  backgroundColor: Colors.white,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text('Tracciato Contabile'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.account_balance_wallet_outlined),
                      selectedIcon: Icon(Icons.account_balance_wallet),
                      label: Text('Estratti Conto'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.warning_amber_outlined),
                      selectedIcon: Icon(Icons.warning_amber),
                      label: Text('Scarti Tracciato'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.credit_card_outlined),
                      selectedIcon: Icon(Icons.credit_card),
                      label: Text('Estratti AMEX'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text('Tracciato SAP'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.flight_takeoff_outlined),
                      selectedIcon: Icon(Icons.flight_takeoff),
                      label: Text('Trasferte SAP'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.fact_check_outlined),
                      selectedIcon: Icon(Icons.fact_check),
                      label: Text('Controlli Trasferte'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map),
                      label: Text('Dove Viaggi'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Anagrafica'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.file_upload_outlined),
                      selectedIcon: Icon(Icons.file_upload),
                      label: Text('Carica File'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.sync_outlined),
                      selectedIcon: Icon(Icons.sync),
                      label: Text('Sync File'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: Text('Log History'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Impostazioni'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.help_outline),
                      selectedIcon: Icon(Icons.help),
                      label: Text('Supporto'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return OverflowBox(
      maxWidth: 260,
      minWidth: 260,
      alignment: Alignment.centerLeft,
      child: NavigationDrawer(
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
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber),
            label: Text('Scarti Tracciato'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: Text('Estratti AMEX'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: Text('Tracciato SAP'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.flight_takeoff_outlined),
            selectedIcon: Icon(Icons.flight_takeoff),
            label: Text('Trasferte SAP'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: Text('Controlli Trasferte'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: Text('Dove Viaggi'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: Text('Anagrafica'),
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
            icon: Icon(Icons.file_upload_outlined),
            selectedIcon: Icon(Icons.file_upload),
            label: Text('Carica File'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.sync_outlined),
            selectedIcon: Icon(Icons.sync),
            label: Text('Sync File'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: Text('Log History'),
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
      ),
    );
  }
}
