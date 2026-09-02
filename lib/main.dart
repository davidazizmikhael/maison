import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/theme.dart';
import 'data/backend.dart';
import 'data/notifications.dart';
import 'features/session/bootstrap_screen.dart';
import 'features/session/locale_cubit.dart';
import 'features/session/session_cubit.dart';
import 'features/timeline/timeline_cubit.dart';
import 'l10n/gen/app_localizations.dart';

/// Root navigator: lets a notification tap land the user back on the home
/// screen (where Up next lives) from anywhere in the app.
final appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initBackend(); // no-op in demo mode (no --dart-define credentials)
  await NotificationService.init(
      onTap: () => appNavigatorKey.currentState?.popUntil((route) => route.isFirst));
  final localeCubit = LocaleCubit();
  await localeCubit.load();

  // Crash reporting activates only when a DSN is configured (env.json →
  // SENTRY_DSN). Without one — demo mode, tests, local dev — this is inert.
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  if (sentryDsn.isEmpty) {
    runApp(MaisonApp(localeCubit: localeCubit));
  } else {
    await SentryFlutter.init(
      (options) => options
        ..dsn = sentryDsn
        ..tracesSampleRate = 0.2
        ..sendDefaultPii = false,
      appRunner: () => runApp(MaisonApp(localeCubit: localeCubit)),
    );
  }
}

class MaisonApp extends StatelessWidget {
  const MaisonApp({super.key, this.localeCubit});
  final LocaleCubit? localeCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => localeCubit ?? LocaleCubit()),
        BlocProvider(create: (_) => SessionCubit(Backend.instance)),
        BlocProvider(create: (_) => TimelineCubit(Backend.instance)),
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) {
          return MaterialApp(
            navigatorKey: appNavigatorKey,
            title: 'Maison',
            debugShowCheckedModeBanner: false,
            theme: maisonTheme(Brightness.light),
            darkTheme: maisonTheme(Brightness.dark),
            themeMode: ThemeMode.system, // follows the device setting
            locale: locale, // null = follow the device language
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const BootstrapScreen(),
          );
        },
      ),
    );
  }
}
