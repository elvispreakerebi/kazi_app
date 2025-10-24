import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/app.dart';
import 'app_popover_menu.dart';
import 'app_theme.dart';

class LanguagePopover extends ConsumerWidget {
  final BuildContext parentContext;
  const LanguagePopover({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final languages = [
      {'code': 'en', 'label': 'English', 'abbr': 'EN'},
      {'code': 'fr', 'label': 'French', 'abbr': 'FR'},
      {'code': 'rw', 'label': 'Kiryanwanda', 'abbr': 'RW'},
    ];
    final current = languages.firstWhere(
      (l) => l['code'] == lang,
      orElse: () => languages[0],
    );
    return AppPopoverMenu(
      anchor: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E4E7)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current['abbr']!,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
      ),
      boxShadow: AppTheme.shadowMd,
      items: [
        AppPopoverMenuItem.title('Change language'),
        ...languages.map(
          (item) => AppPopoverMenuItem(
            label: item['label']!,
            icon: null,
            leading: Opacity(
              opacity: item['code'] == lang ? 1.0 : 0.0,
              child: const Icon(Icons.check, size: 18, color: Colors.black),
            ),
            trailing: Text(
              item['abbr']!,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            onTap: (menuCtx) async {
              final locale = Locale(item['code']!);
              ref.read(localeProvider.notifier).state = locale;
              await parentContext.setLocale(locale); // Await fully!
              final routeName =
                  ModalRoute.of(parentContext)?.settings.name ?? '/';
              Navigator.of(
                parentContext,
                rootNavigator: true,
              ).pushReplacementNamed(routeName);
              Navigator.of(menuCtx).pop();
            },
          ),
        ),
      ],
    );
  }
}
