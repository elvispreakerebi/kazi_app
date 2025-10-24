import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../app/app.dart';
import 'app_popover_menu.dart';
import '../shared/services/api_service.dart';
import 'app_theme.dart';

class LanguagePopover extends ConsumerWidget {
  const LanguagePopover({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
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
            onTap: () async {
              ref.read(languageProvider.notifier).state = item['code']!;
              context.setLocale(Locale(item['code']!));
              try {
                await ApiService().post(
                  '/api/teacher/language-preference',
                  body: {'language': item['code']!},
                );
                // Optionally show feedback
              } catch (_) {
                // Optionally show error
              }
            },
          ),
        ),
      ],
    );
  }
}
