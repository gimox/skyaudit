import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:travel_check/shared/widgets/sky_animated_background.dart';
import 'package:travel_check/features/home/widgets/sky_side_bar.dart';
import 'package:travel_check/features/home/widgets/sky_top_bar.dart';
import 'package:travel_check/features/upload/upload_view.dart';
import 'package:travel_check/features/analysis/analysis_view.dart';
import 'package:travel_check/features/controls/controls_view.dart';
import 'package:travel_check/features/dashboard/dashboard_view.dart';
import 'package:travel_check/features/settings/settings_view.dart';
import 'package:travel_check/features/log_history/log_history_view.dart';
import 'package:travel_check/features/analysis/estratti_conto_view.dart';
import 'package:travel_check/features/analysis/sap_analysis_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _setupWindow();
  }

  Future<void> _setupWindow() async {
    if (!kIsWeb &&
        (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await windowManager.setResizable(true);
      // await windowManager.setAspectRatio(16 / 9);
      await windowManager.setSize(const Size(1400, 720));
      await windowManager.setMinimumSize(const Size(600, 400));
      await windowManager.center();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isMedium = screenWidth >= 600 && screenWidth < 1000;

    // Se lo schermo è medio, forziamo il collapse se non è già stato fatto
    final bool effectiveCollapsed = isMedium || _isSidebarCollapsed;

    return Scaffold(
      key: _scaffoldKey,
      appBar: SkyTopBar(
        title: _getTitleForIndex(_selectedIndex),
        showMenuIcon: true,
        onMenuPressed: () {
          if (!isMobile) {
            setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
          } else {
            _scaffoldKey.currentState?.openDrawer();
          }
        },
      ),
      drawer: isMobile
          ? SkySideBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
                Navigator.pop(context);
              },
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: effectiveCollapsed ? 80 : 260,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.withAlpha(25)),
                ),
              ),
              child: SkySideBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) =>
                    setState(() => _selectedIndex = index),
                isPermanent: true,
                isCollapsed: effectiveCollapsed,
              ),
            ),
          Expanded(
            child: Stack(
              children: [const SkyAnimatedBackground(), _buildMainContent()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedIndex == 0) {
      return const DashboardView();
    }
    if (_selectedIndex == 1) {
      return const UploadView();
    }
    if (_selectedIndex == 2) {
      return const AnalysisView();
    }
    if (_selectedIndex == 3) {
      return const EstrattiContoView();
    }
    if (_selectedIndex == 4) {
      return const SapAnalysisView();
    }
    if (_selectedIndex == 5) {
      return const ControlsView();
    }
    if (_selectedIndex == 6) {
      return const LogHistoryView();
    }
    if (_selectedIndex == 7) {
      return const SettingsView();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForIndex(_selectedIndex),
            size: 64,
            color: Theme.of(context).colorScheme.primary.withAlpha(75),
          ),
          const SizedBox(height: 20),
          Text(
            _getTitleForIndex(_selectedIndex).toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w200,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sezione in fase di sviluppo',
            style: TextStyle(
              color: Colors.grey.withAlpha(200),
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard_outlined;
      case 1:
        return Icons.file_upload_outlined;
      case 2:
        return Icons.analytics_outlined;
      case 3:
        return Icons.account_balance_wallet_outlined;
      case 4:
        return Icons.analytics_outlined;
      case 5:
        return Icons.fact_check_outlined;
      case 6:
        return Icons.history_outlined;
      case 7:
        return Icons.settings_outlined;
      case 8:
        return Icons.help_outline;
      default:
        return Icons.home_outlined;
    }
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Carica File';
      case 2:
        return 'Tracciato Contabile';
      case 3:
        return 'Estratti Conto';
      case 4:
        return 'Tracciato SAP';
      case 5:
        return 'Controlli';
      case 6:
        return 'Log History';
      case 7:
        return 'Impostazioni';
      case 8:
        return 'Supporto';
      default:
        return 'Home';
    }
  }
}
