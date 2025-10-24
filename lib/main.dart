import 'package:flutter/material.dart';
import 'package:convex_flutter/convex_flutter.dart';
import 'core/constants/backend.dart';
import 'app/router.dart';
import 'features/splash/splash_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart'; // required for localeProvider

late ConvexClient convexClient;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  convexClient = await ConvexClient.init(
    deploymentUrl: convexBackend,
    clientId: "kazi-app-v1.0-demo1",
  );
  print('Connected to Convex backend!');

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('fr'), Locale('rw')],
        path: 'lib/l10n',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'), // Always boot in English
        useOnlyLangCode: true,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocale = EasyLocalization.of(context)?.locale;
    final providerLocale = ref.watch(localeProvider);
    // Ensure sync between provider and EasyLocalization
    if (appLocale != null && appLocale != providerLocale) {
      Future.microtask(() {
        ref.read(localeProvider.notifier).state = appLocale;
      });
    }
    return MaterialApp(
      title: 'Kazi App',
      theme: ThemeData(fontFamily: 'Inter'),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: SplashRoute.path,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: providerLocale,
      // Suppress Material warning for rw; let EasyLocalization handle tr()
      localeResolutionCallback: (loc, supportedLocales) {
        // If current is rw, Material/Cupertino fallback to en
        if (loc?.languageCode == 'rw') {
          return const Locale('en');
        }
        // If exact match en/fr, allow
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == loc?.languageCode) {
            return supportedLocale;
          }
        }
        // fallback to en
        return const Locale('en');
      },
    );
  }
}
