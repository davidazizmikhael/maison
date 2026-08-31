import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme.dart';
import 'data/backend.dart';
import 'data/notifications.dart';
import 'features/session/bootstrap_screen.dart';
import 'features/session/locale_cubit.dart';
import 'features/session/session_cubit.dart';
import 'features/timeline/timeline_cubit.dart';
import 'l10n/gen/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initBackend(); // no-op in demo mode (no --dart-define credentials)
  await NotificationService.init();
  final localeCubit = LocaleCubit();
  await localeCubit.load();
  runApp(MaisonApp(localeCubit: localeCubit));
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
