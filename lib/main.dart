import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme.dart';
import 'data/backend.dart';
import 'data/notifications.dart';
import 'features/session/bootstrap_screen.dart';
import 'features/session/session_cubit.dart';
import 'features/timeline/timeline_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initBackend(); // no-op in demo mode (no --dart-define credentials)
  await NotificationService.init();
  runApp(const MaisonApp());
}

class MaisonApp extends StatelessWidget {
  const MaisonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SessionCubit(Backend.instance)),
        BlocProvider(create: (_) => TimelineCubit(Backend.instance)),
      ],
      child: MaterialApp(
        title: 'Maison',
        debugShowCheckedModeBanner: false,
        theme: maisonTheme(),
        home: const BootstrapScreen(),
      ),
    );
  }
}
