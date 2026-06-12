import 'package:flutter/material.dart';
import 'package:travel_check/core/theme/app_theme.dart';

class SidebarItemData {
  final int index;
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  const SidebarItemData({
    required this.index,
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });
}

const List<SidebarItemData> travelItems = [
  SidebarItemData(
    index: 0,
    title: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  SidebarItemData(
    index: 1,
    title: 'Tracciato Contabile',
    icon: Icons.analytics_outlined,
    selectedIcon: Icons.analytics,
  ),
  SidebarItemData(
    index: 2,
    title: 'Estratti Conto',
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet,
  ),
  SidebarItemData(
    index: 3,
    title: 'Scarti Tracciato',
    icon: Icons.warning_amber_outlined,
    selectedIcon: Icons.warning_amber,
  ),
  SidebarItemData(
    index: 4,
    title: 'Estratti AMEX',
    icon: Icons.credit_card_outlined,
    selectedIcon: Icons.credit_card,
  ),
  SidebarItemData(
    index: 5,
    title: 'Tracciato SAP',
    icon: Icons.analytics_outlined,
    selectedIcon: Icons.analytics,
  ),
  SidebarItemData(
    index: 6,
    title: 'Trasferte SAP',
    icon: Icons.flight_takeoff_outlined,
    selectedIcon: Icons.flight_takeoff,
  ),
  SidebarItemData(
    index: 7,
    title: 'Controlli Trasferte',
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check,
  ),
  SidebarItemData(
    index: 8,
    title: 'Dove Viaggi',
    icon: Icons.map_outlined,
    selectedIcon: Icons.map,
  ),
  SidebarItemData(
    index: 15,
    title: 'Trasferte Scartate',
    icon: Icons.block_outlined,
    selectedIcon: Icons.block,
  ),
];

const SidebarItemData anagraficaItem = SidebarItemData(
  index: 9,
  title: 'Anagrafica',
  icon: Icons.people_outline,
  selectedIcon: Icons.people,
);

const List<SidebarItemData> hroItems = [
  anagraficaItem,
];

const List<SidebarItemData> configItems = [
  SidebarItemData(
    index: 10,
    title: 'Carica File',
    icon: Icons.file_upload_outlined,
    selectedIcon: Icons.file_upload,
  ),
  SidebarItemData(
    index: 11,
    title: 'Sync File',
    icon: Icons.sync_outlined,
    selectedIcon: Icons.sync,
  ),
  SidebarItemData(
    index: 12,
    title: 'Log History',
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
  ),
  SidebarItemData(
    index: 13,
    title: 'Impostazioni',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

class SkySideBar extends StatefulWidget {
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
  State<SkySideBar> createState() => _SkySideBarState();
}

class _SkySideBarState extends State<SkySideBar> {
  final ExpansionTileController _travelExpansionController = ExpansionTileController();
  final ExpansionTileController _hroExpansionController = ExpansionTileController();
  bool _isTravelExpanded = false;
  bool _isHroExpanded = false;

  @override
  void initState() {
    super.initState();
    _isTravelExpanded = (widget.selectedIndex >= 0 && widget.selectedIndex <= 8) || widget.selectedIndex == 15;
    _isHroExpanded = widget.selectedIndex == 9;
  }

  @override
  void didUpdateWidget(covariant SkySideBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isTravelSelected = (widget.selectedIndex >= 0 && widget.selectedIndex <= 8) || widget.selectedIndex == 15;
    final isHroSelected = widget.selectedIndex == 9;

    if (isTravelSelected && !_isTravelExpanded) {
      setState(() {
        _isTravelExpanded = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_travelExpansionController.isExpanded) {
          _travelExpansionController.expand();
        }
      });
    }

    if (isHroSelected && !_isHroExpanded) {
      setState(() {
        _isHroExpanded = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hroExpansionController.isExpanded) {
          _hroExpansionController.expand();
        }
      });
    }
  }

  void _showTravelPopup(BuildContext context, GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double left = offset.dx + renderBox.size.width + 8;
    final double top = offset.dy;

    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, left + 220, top + 400),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      items: travelItems.map((item) {
        final isSelected = widget.selectedIndex == item.index;
        return PopupMenuItem<int>(
          value: item.index,
          child: Row(
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: isSelected ? SkyTheme.timBlue : Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                item.title,
                style: TextStyle(
                  fontFamily: 'TIMSans',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? SkyTheme.timBlue : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        widget.onDestinationSelected(value);
      }
    });
  }

  void _showHroPopup(BuildContext context, GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final double left = offset.dx + renderBox.size.width + 8;
    final double top = offset.dy;

    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, left + 220, top + 400),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      items: hroItems.map((item) {
        final isSelected = widget.selectedIndex == item.index;
        return PopupMenuItem<int>(
          value: item.index,
          child: Row(
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: isSelected ? SkyTheme.timBlue : Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                item.title,
                style: TextStyle(
                  fontFamily: 'TIMSans',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? SkyTheme.timBlue : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        widget.onDestinationSelected(value);
      }
    });
  }

  Widget _buildMenuItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: SkyTheme.timBlue.withOpacity(0.04),
        splashColor: SkyTheme.timBlue.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? SkyTheme.timBlue.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? SkyTheme.timBlue : Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'TIMSans',
                    color: isSelected ? SkyTheme.timBlue : Colors.grey.shade800,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedItem({
    Key? key,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: SkyTheme.timBlue.withOpacity(0.04),
          splashColor: SkyTheme.timBlue.withOpacity(0.1),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? SkyTheme.timBlue.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? SkyTheme.timBlue : Colors.grey.shade700,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildExpanded(BuildContext context) {
    final isTravelSelected = (widget.selectedIndex >= 0 && widget.selectedIndex <= 8) || widget.selectedIndex == 15;
    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
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
                fontFamily: 'TIMSans',
              ),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              controller: _travelExpansionController,
              initiallyExpanded: _isTravelExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isTravelExpanded = expanded;
                });
              },
              shape: const Border(),
              collapsedShape: const Border(),
              iconColor: isTravelSelected
                  ? SkyTheme.timBlue
                  : Colors.grey.shade700,
              collapsedIconColor: isTravelSelected
                  ? SkyTheme.timBlue
                  : Colors.grey.shade700,
              leading: Icon(
                Icons.flight_takeoff_outlined,
                color: isTravelSelected
                    ? SkyTheme.timBlue
                    : Colors.grey.shade700,
              ),
              title: Text(
                'Travel',
                style: TextStyle(
                  fontFamily: 'TIMSans',
                  fontSize: 14,
                  fontWeight: isTravelSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: isTravelSelected
                      ? SkyTheme.timBlue
                      : Colors.grey.shade800,
                ),
              ),
              children: travelItems.map((item) {
                final isSelected = widget.selectedIndex == item.index;
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildMenuItem(
                    icon: item.icon,
                    selectedIcon: item.selectedIcon,
                    label: item.title,
                    isSelected: isSelected,
                    onTap: () => widget.onDestinationSelected(item.index),
                  ),
                );
              }).toList(),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              controller: _hroExpansionController,
              initiallyExpanded: _isHroExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isHroExpanded = expanded;
                });
              },
              shape: const Border(),
              collapsedShape: const Border(),
              iconColor: widget.selectedIndex == 9
                  ? SkyTheme.timBlue
                  : Colors.grey.shade700,
              collapsedIconColor: widget.selectedIndex == 9
                  ? SkyTheme.timBlue
                  : Colors.grey.shade700,
              leading: Icon(
                Icons.badge_outlined,
                color: widget.selectedIndex == 9
                    ? SkyTheme.timBlue
                    : Colors.grey.shade700,
              ),
              title: Text(
                'Gestione HRO',
                style: TextStyle(
                  fontFamily: 'TIMSans',
                  fontSize: 14,
                  fontWeight: widget.selectedIndex == 9
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: widget.selectedIndex == 9
                      ? SkyTheme.timBlue
                      : Colors.grey.shade800,
                ),
              ),
              children: hroItems.map((item) {
                final isSelected = widget.selectedIndex == item.index;
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildMenuItem(
                    icon: item.icon,
                    selectedIcon: item.selectedIcon,
                    label: item.title,
                    isSelected: isSelected,
                    onTap: () => widget.onDestinationSelected(item.index),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(indent: 28, endIndent: 28, height: 20),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'CONFIGURAZIONE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.5,
                fontFamily: 'TIMSans',
              ),
            ),
          ),
          ...configItems.map((item) {
            return _buildMenuItem(
              icon: item.icon,
              selectedIcon: item.selectedIcon,
              label: item.title,
              isSelected: widget.selectedIndex == item.index,
              onTap: () => widget.onDestinationSelected(item.index),
            );
          }),
        ],
      ),
    );
  }

  Widget buildCollapsed(BuildContext context) {
    final GlobalKey travelKey = GlobalKey();
    final GlobalKey hroKey = GlobalKey();
    final bool isTravelSelected = (widget.selectedIndex >= 0 && widget.selectedIndex <= 8) || widget.selectedIndex == 15;
    final bool isHroSelected = widget.selectedIndex == 9;

    return Container(
      color: Colors.white,
      width: 80,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildCollapsedItem(
            key: travelKey,
            icon: Icons.flight_takeoff_outlined,
            selectedIcon: Icons.flight_takeoff,
            label: 'Travel',
            isSelected: isTravelSelected,
            onTap: () => _showTravelPopup(context, travelKey),
          ),
          _buildCollapsedItem(
            key: hroKey,
            icon: Icons.badge_outlined,
            selectedIcon: Icons.badge,
            label: 'Gestione HRO',
            isSelected: isHroSelected,
            onTap: () => _showHroPopup(context, hroKey),
          ),
          const Divider(indent: 16, endIndent: 16, height: 20),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: configItems.length,
              itemBuilder: (context, index) {
                final item = configItems[index];
                return _buildCollapsedItem(
                  icon: item.icon,
                  selectedIcon: item.selectedIcon,
                  label: item.title,
                  isSelected: widget.selectedIndex == item.index,
                  onTap: () => widget.onDestinationSelected(item.index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsed) {
      return OverflowBox(
        maxWidth: 80,
        minWidth: 80,
        alignment: Alignment.centerLeft,
        child: buildCollapsed(context),
      );
    }

    return OverflowBox(
      maxWidth: 260,
      minWidth: 260,
      alignment: Alignment.centerLeft,
      child: buildExpanded(context),
    );
  }
}
