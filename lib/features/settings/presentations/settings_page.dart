import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../components/app_page_header.dart';
import '../../../components/app_theme.dart';
import '../../../components/settings_list_item.dart';
import '../../../components/bottom_nav_bar.dart';
import '../../../components/app_bottom_sheet.dart';
import '../../../components/app_button.dart';
import '../../../providers/teacher_provider.dart';
import '../../../shared/services/api_service.dart';
import '../../../app/app.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  int _navIndex = 2; // Settings is index 2

  @override
  Widget build(BuildContext context) {
    final teacher = ref.watch(teacherProvider);
    final language = teacher.language ?? 'english';

    // Map backend language to display string
    String getLanguageDisplay(String lang) {
      switch (lang.toLowerCase()) {
        case 'english':
          return 'english'.tr();
        case 'french':
          return 'french'.tr();
        case 'kiryanwanda':
          return 'kiryanwanda'.tr();
        default:
          return 'english'.tr();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              backButton: null, // No back button for root page
              title: 'settings'.tr(),
              showLogo: false,
              parentContext: context,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.addClassContainerBg,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          SettingsListItem(
                            icon: Icons.person_outline,
                            title: 'account'.tr(),
                            description: 'account_description'.tr(),
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed('/settings/account');
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTheme.outline,
                          ),
                          SettingsListItem(
                            icon: Icons.language_outlined,
                            title: 'language'.tr(),
                            description: getLanguageDisplay(language),
                            onTap: () {
                              // Show language bottom sheet
                              _showLanguageBottomSheet(context);
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTheme.outline,
                          ),
                          SettingsListItem(
                            icon: Icons.logout_outlined,
                            title: 'log_out'.tr(),
                            description: '',
                            onTap: () {
                              _showLogoutConfirmation(context);
                            },
                            isDestructive: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: BottomNavBar(
          currentIndex: _navIndex,
          onTap: (idx) {
            setState(() => _navIndex = idx);
            if (idx == 0) {
              // Navigate to home page
              Navigator.of(context).pushReplacementNamed('/home');
            } else if (idx == 1) {
              // Navigate to lesson plans page
              Navigator.of(context).pushReplacementNamed('/lesson-plans');
            } else if (idx == 2) {
              // Already on settings page
              Navigator.of(
                context,
              ).popUntil((route) => route.settings.name == '/settings');
            }
          },
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final teacher = ref.read(teacherProvider);
    final currentLanguage = teacher.language ?? 'english';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _LanguageBottomSheetContent(currentLanguage: currentLanguage);
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('log_out'.tr()),
          content: Text('logout_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout();
              },
              child: Text(
                'log_out'.tr(),
                style: const TextStyle(color: AppTheme.destructive),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      // Clear token
      ApiService().logout();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');

      // Navigate to login page
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'logout_error'.tr().replaceAll('{error}', e.toString()),
            ),
          ),
        );
      }
    }
  }
}

class _LanguageBottomSheetContent extends ConsumerStatefulWidget {
  final String currentLanguage;

  const _LanguageBottomSheetContent({required this.currentLanguage});

  @override
  ConsumerState<_LanguageBottomSheetContent> createState() =>
      _LanguageBottomSheetContentState();
}

class _LanguageBottomSheetContentState
    extends ConsumerState<_LanguageBottomSheetContent> {
  String? _selectedLanguage;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
  }

  // Map backend language to locale code
  String _backendLanguageToLocaleCode(String backendLang) {
    switch (backendLang.toLowerCase()) {
      case 'english':
        return 'en';
      case 'french':
        return 'fr';
      case 'kiryanwanda':
        return 'rw';
      default:
        return 'en';
    }
  }

  Future<void> _updateLanguage(String language) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // Map display language to backend format
      String backendLanguage;
      switch (language.toLowerCase()) {
        case 'english':
          backendLanguage = 'english';
          break;
        case 'french':
          backendLanguage = 'french';
          break;
        case 'kiryanwanda':
          backendLanguage = 'kiryanwanda';
          break;
        default:
          backendLanguage = 'english';
      }

      await ApiService().setLanguagePreference(backendLanguage);

      // Refresh teacher data
      await ref.read(teacherProvider.notifier).fetchTeacherDetailsAndCounts();

      // Update locale provider and EasyLocalization context
      final localeCode = _backendLanguageToLocaleCode(backendLanguage);
      final locale = Locale(localeCode);

      if (ref.read(localeProvider).languageCode != localeCode) {
        await context.setLocale(locale);
        ref.read(localeProvider.notifier).state = locale;

        // Force rebuild of all pages by navigating to current route
        final routeName = ModalRoute.of(context)?.settings.name ?? '/settings';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pushReplacementNamed(routeName);
          } else {
            // Fallback: force rebuild
            (context as Element).markNeedsBuild();
          }
        });
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('language_updated_success'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'language_update_error'.tr().replaceAll('{error}', e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'code': 'english', 'label': 'english'.tr()},
      {'code': 'french', 'label': 'french'.tr()},
      {'code': 'kiryanwanda', 'label': 'kiryanwanda'.tr()},
    ];

    return AppBottomSheet(
      title: 'language'.tr(),
      body: Column(
        children: [
          ...languages.map((lang) {
            final isSelected = _selectedLanguage == lang['code'];
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isUpdating
                        ? null
                        : () {
                            setState(() {
                              _selectedLanguage = lang['code'];
                            });
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.inputDescription,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lang['label']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (lang != languages.last)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.outline,
                  ),
              ],
            );
          }),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'close'.tr(),
              onPressed: () {
                Navigator.of(context).pop();
              },
              variant: ButtonVariant.secondary,
              borderRadius: 22,
              height: 48,
              expanded: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: _isUpdating ? 'updating'.tr() : 'save'.tr(),
              onPressed:
                  _isUpdating || _selectedLanguage == widget.currentLanguage
                  ? null
                  : () => _updateLanguage(_selectedLanguage!),
              variant: ButtonVariant.primary,
              borderRadius: 22,
              height: 48,
              expanded: true,
            ),
          ),
        ],
      ),
    );
  }
}
