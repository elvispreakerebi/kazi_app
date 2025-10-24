import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../app/app.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final languages = [
      {'code': 'en', 'label': 'English', 'abbr': 'EN'},
      {'code': 'fr', 'label': 'French', 'abbr': 'FR'},
      {'code': 'rw', 'label': 'Kiryanwanda', 'abbr': 'RW'},
    ];
    // final selected = languages.firstWhere(
    //   (lang) => lang['code'] == currentLang,
    //   orElse: () => languages[0],
    // );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder for branding/image etc.
                  const SizedBox(height: 60),
                  Text(
                    'welcome_title'.tr(),
                    style: const TextStyle(fontSize: 28),
                  ),
                ],
              ),
            ),
            // Language switcher (top right)
            Positioned(
              top: 16,
              right: 16,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentLang,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  borderRadius: BorderRadius.circular(16),
                  style: const TextStyle(fontSize: 15),
                  dropdownColor: Colors.white,
                  onChanged: (String? code) {
                    if (code != null) {
                      ref.read(languageProvider.notifier).state = code;
                      context.setLocale(Locale(code));
                      // (Optional: Also sync to backend)
                    }
                  },
                  items: languages
                      .map(
                        (lang) => DropdownMenuItem<String>(
                          value: lang['code'],
                          child: Row(
                            children: [
                              Text(lang['label']!),
                              const SizedBox(width: 4),
                              Text(
                                lang['abbr']!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
