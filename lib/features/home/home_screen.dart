import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:travel_check/shared/widgets/sky_animated_background.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/core/services/update_service.dart';
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
import 'package:travel_check/features/analysis/amex_analysis_view.dart';
import 'package:travel_check/features/travel_history/travel_history_view.dart';
import 'package:travel_check/features/anagrafica/anagrafica_view.dart';
import 'package:travel_check/features/analysis/scarti_ec_view.dart';
import 'package:travel_check/features/sync_file/sync_file_view.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _setupWindow() async {
    if (!kIsWeb &&
        (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await windowManager.setResizable(true);
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
      return const AnalysisView();
    }
    if (_selectedIndex == 2) {
      return const EstrattiContoView();
    }
    if (_selectedIndex == 3) {
      return const ScartiEcView();
    }
    if (_selectedIndex == 4) {
      return const AmexAnalysisView();
    }
    if (_selectedIndex == 5) {
      return const SapAnalysisView();
    }
    if (_selectedIndex == 6) {
      return const ControlsView();
    }
    if (_selectedIndex == 7) {
      return const TravelHistoryView();
    }
    if (_selectedIndex == 8) {
      return const AnagraficaView();
    }
    if (_selectedIndex == 9) {
      return const UploadView();
    }
    if (_selectedIndex == 10) {
      return const SyncFileView();
    }
    if (_selectedIndex == 11) {
      return const LogHistoryView();
    }
    if (_selectedIndex == 12) {
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
        return Icons.analytics_outlined;
      case 2:
        return Icons.account_balance_wallet_outlined;
      case 3:
        return Icons.warning_amber_outlined;
      case 4:
        return Icons.credit_card_outlined;
      case 5:
        return Icons.analytics_outlined;
      case 6:
        return Icons.fact_check_outlined;
      case 7:
        return Icons.map_outlined;
      case 8:
        return Icons.people_outline;
      case 9:
        return Icons.file_upload_outlined;
      case 10:
        return Icons.sync_outlined;
      case 11:
        return Icons.history_outlined;
      case 12:
        return Icons.settings_outlined;
      case 13:
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
        return 'Tracciato Contabile';
      case 2:
        return 'Estratti Conto';
      case 3:
        return 'Scarti Tracciato';
      case 4:
        return 'Estratti AMEX';
      case 5:
        return 'Tracciato SAP';
      case 6:
        return 'Controlli Trasferte';
      case 7:
        return 'Dove Viaggi';
      case 8:
        return 'Anagrafica';
      case 9:
        return 'Carica File';
      case 10:
        return 'Sync File';
      case 11:
        return 'Log History';
      case 12:
        return 'Impostazioni';
      case 13:
        return 'Supporto';
      default:
        return 'Home';
    }
  }

  Future<void> _checkForUpdates() async {
    final updateInfo = await UpdateService.checkForUpdate();
    if (updateInfo != null && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(AppUpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: !info.mandatory,
      builder: (context) {
        return PopScope(
          canPop: !info.mandatory,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SkyTheme.timBlue.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.system_update_alt,
                          color: SkyTheme.timBlue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aggiornamento Disponibile',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: SkyTheme.timBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nuova versione: ${info.version}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'È disponibile una nuova versione di SkyAudit. Si consiglia di procedere all\'aggiornamento per usufruire delle ultime ottimizzazioni e funzionalità.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (info.changelog.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Novità introdotte:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SkyTheme.timBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: info.changelog.map((log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: SkyTheme.timRed)),
                                Expanded(
                                  child: Text(
                                    log,
                                    style: const TextStyle(fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!info.mandatory)
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Più tardi',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SkyTheme.timBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          try {
                            await UpdateService.performUpdate(info);
                            if (!info.mandatory && mounted) {
                              navigator.pop();
                            }
                          } catch (e) {
                            if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Errore nel lancio dell\'aggiornamento: $e'),
                                backgroundColor: SkyTheme.timRed,
                              ),
                            );
                          }
                        },
                        child: const Text('Aggiorna Ora'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
