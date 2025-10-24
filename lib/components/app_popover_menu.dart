import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppPopoverMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;
  final bool isDivider;

  const AppPopoverMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  }) : isDivider = false;

  const AppPopoverMenuItem.divider()
    : label = '',
      icon = null,
      onTap = null,
      trailing = null,
      isDestructive = false,
      isDivider = true;
}

class AppPopoverMenu extends StatelessWidget {
  final List<AppPopoverMenuItem> items;
  final Widget anchor;
  final double menuWidth;
  final AlignmentGeometry alignment;
  final EdgeInsets menuPadding;

  const AppPopoverMenu({
    Key? key,
    required this.items,
    required this.anchor,
    this.menuWidth = 230,
    this.alignment = Alignment.topRight,
    this.menuPadding = const EdgeInsets.symmetric(vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 12),
      color: AppTheme.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      itemBuilder: (_) {
        int idx = -1;
        return items.map<PopupMenuEntry<int>>((item) {
          idx++;
          if (item.isDivider) {
            return const PopupMenuDivider(height: 1);
          }
          return PopupMenuItem<int>(
            value: idx,
            enabled: item.onTap != null,
            child: Row(
              children: [
                if (item.icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      item.icon,
                      color: item.isDestructive
                          ? AppTheme.destructive
                          : AppTheme.popoverForeground,
                      size: 22,
                    ),
                  ),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: item.isDestructive
                          ? AppTheme.destructive
                          : AppTheme.popoverForeground,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (item.trailing != null) ...[
                  const SizedBox(width: 8),
                  item.trailing!,
                ],
              ],
            ),
          );
        }).toList();
      },
      onSelected: (index) {
        final item = items[index];
        if (item.onTap != null) item.onTap!();
      },
      padding: EdgeInsets.zero,
      child: anchor,
      constraints: BoxConstraints(minWidth: menuWidth),
    );
  }
}
