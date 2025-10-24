import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppPopoverMenuItem {
  final String label;
  final IconData? icon;
  final Widget? leading;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;
  final bool isDivider;
  final bool isTitle;

  const AppPopoverMenuItem({
    required this.label,
    this.icon,
    this.leading,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
    this.isTitle = false,
  }) : isDivider = false;

  const AppPopoverMenuItem.title(String label)
    : label = label,
      icon = null,
      leading = null,
      onTap = null,
      trailing = null,
      isDestructive = false,
      isTitle = true,
      isDivider = false;

  const AppPopoverMenuItem.divider()
    : label = '',
      icon = null,
      leading = null,
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
  final List<BoxShadow>? boxShadow;

  const AppPopoverMenu({
    Key? key,
    required this.items,
    required this.anchor,
    this.menuWidth = 230,
    this.alignment = Alignment.topRight,
    this.menuPadding = const EdgeInsets.symmetric(vertical: 8),
    this.boxShadow,
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
        // idx is not needed anymore
        List<Widget> menuContent = [];
        if (items.isNotEmpty && items.first.isTitle) {
          menuContent.add(
            Container(
              height: 48,
              alignment: Alignment.centerLeft,
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
            Container(
              height: 1,
              width: double.infinity,
              color: AppTheme.baseMuted,
            ),
          );
        }
        for (final item in items.skip(
          (items.isNotEmpty && items.first.isTitle) ? 1 : 0,
        )) {
          if (item.isDivider) {
            menuContent.add(
              Container(
                height: 1,
                width: double.infinity,
                color: AppTheme.baseMuted,
              ),
            );
            continue;
          }
          menuContent.add(
            InkWell(
              onTap: item.onTap,
              child: Container(
                height: 48,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    if (item.leading != null) ...[
                      item.leading!,
                      const SizedBox(width: 8),
                    ],
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
            ),
          );
        }
        return [
          PopupMenuItem<int>(
            enabled: false,
            height: 0,
            padding: EdgeInsets.zero,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: boxShadow ?? [],
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: menuContent,
              ),
            ),
          ),
        ];
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
