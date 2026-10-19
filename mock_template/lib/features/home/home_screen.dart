import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/proxy_service.dart';
import '../settings/settings_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // SIDEBAR LATERALE
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarCollapsed ? 76 : 240,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Header Sidebar con Logo e Toggle
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isSidebarCollapsed)
                        const Row(
                          children: [
                            Icon(Icons.dashboard_customize_rounded, color: AppTheme.primaryBlue, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'App Template',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                            ),
                          ],
                        ),
                      IconButton(
                        icon: Icon(_isSidebarCollapsed ? Icons.menu : Icons.menu_open, color: Colors.grey.shade700),
                        onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                        tooltip: _isSidebarCollapsed ? 'Espandi menu' : 'Comprimi menu',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Voci di Menu
                _buildNavItem(index: 0, icon: Icons.home_outlined, selectedIcon: Icons.home, title: 'Home'),
                _buildNavItem(index: 1, icon: Icons.settings_outlined, selectedIcon: Icons.settings, title: 'Impostazioni'),

                const Spacer(),

                // Stato Proxy in basso
                if (!_isSidebarCollapsed)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          ProxyService.resolvedProxy != null ? Icons.wifi_protected_setup : Icons.wifi,
                          size: 18,
                          color: ProxyService.resolvedProxy != null ? Colors.green.shade700 : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ProxyService.resolvedProxy != null ? 'Proxy attivo' : 'Rete standard',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // CONTENUTO PRINCIPALE
          Expanded(
            child: Column(
              children: [
                // TopBar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedIndex == 0 ? 'Home' : 'Impostazioni',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        avatar: const Icon(Icons.circle, color: Colors.green, size: 10),
                        label: const Text('Modalità Standalone Locale', style: TextStyle(fontSize: 12)),
                        backgroundColor: Colors.grey.shade100,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),

                // Body delle Viste
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _buildEmptyHomeView(),
                      const SettingsView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
  }) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue.withAlpha(20) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(isSelected ? selectedIcon : icon, color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade700, size: 22),
              if (!_isSidebarCollapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Home pulita con segnaposto neutro
  Widget _buildEmptyHomeView() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Benvenuto nello Scheletro Applicativo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Questa è una schermata Home iniziale pulita. Il core dell\'applicazione, il database Isar e il modulo Proxy sono già operativi e pronti per accogliere nuove funzionalità.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
