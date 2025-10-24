import 'package:flutter/material.dart';
import 'package:convex_flutter/convex_flutter.dart';
import 'core/constants/backend.dart';
import 'app/router.dart';
import 'features/splash/splash_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

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
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('rw')],
      path: 'lib/l10n',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user's selected language from Riverpod
    final language = ref.watch(languageProvider);
    Locale currentLocale;
    switch (language) {
      case 'french':
        currentLocale = const Locale('fr');
        break;
      case 'kiryanwanda':
        currentLocale = const Locale('rw');
        break;
      default:
        currentLocale = const Locale('en');
    }
    context.setLocale(currentLocale); // Update EasyLocalization context
    return MaterialApp(
      title: 'Kazi App',
      theme: ThemeData(fontFamily: 'Inter'),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: SplashRoute.path,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
