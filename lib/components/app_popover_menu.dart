import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppPopoverMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;
  final bool isDivider;
  final bool isTitle;

  const AppPopoverMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
    this.isTitle = false,
  }) : isDivider = false;

  const AppPopoverMenuItem.title(String label)
    : label = label,
      icon = null,
      onTap = null,
      trailing = null,
      isDestructive = false,
      isTitle = true,
      isDivider = false;

  const AppPopoverMenuItem.divider()
    : label = '',
      icon = null,
      onTap = null,
      trailing = null,
      isDestructive = false,
      isTitle = false,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      elevation: 0,
      itemBuilder: (_) {
        int idx = -1;
        List<PopupMenuEntry<int>> menuContent = [];
        if (items.isNotEmpty && items.first.isTitle) {
          menuContent.add(
            PopupMenuItem<int>(
              enabled: false,
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                items.first.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.foreground,
                ),
              ),
            ),
          );
          // Divider below title with custom color
          menuContent.add(
            PopupMenuDivider(height: 1, color: AppTheme.baseMuted),
          );
          idx++;
        }
        for (final item in items.skip(
          (items.isNotEmpty && items.first.isTitle) ? 1 : 0,
        )) {
          idx++;
          if (item.isDivider) {
            menuContent.add(
              PopupMenuDivider(height: 1, color: AppTheme.baseMuted),
            );
            continue;
          }
          menuContent.add(
            PopupMenuItem<int>(
              value: idx,
              enabled: item.onTap != null,
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (item.trailing != null) ...[
                    const SizedBox(width: 8),
                    item.trailing!,
                  ],
                ],
              ),
            ),
          );
        }
        return menuContent;
      },
      onSelected: (index) {
        final shiftedIndex = items.isNotEmpty && items.first.isTitle
            ? index + 1
            : index;
        final item = items[shiftedIndex];
        if (item.onTap != null) item.onTap!();
      },
      padding: EdgeInsets.zero,
      child: anchor,
      constraints: BoxConstraints(minWidth: menuWidth),
    );
  }
}
