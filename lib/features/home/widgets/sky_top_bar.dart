import 'package:flutter/material.dart';

class SkyTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final bool showMenuIcon;

  const SkyTopBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.showMenuIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showMenuIcon
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/travel_logo.png', height: 28),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, size: 20),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.account_circle_outlined, size: 20),
        ),
        const SizedBox(width: 12),
      ],
      elevation: 0,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
