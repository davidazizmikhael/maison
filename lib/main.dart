import 'package:flutter/material.dart';
import 'models.dart';
import 'screens/bootstrap.dart';
import 'services/backend.dart';
import 'services/notifications.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initBackend(); // no-op in demo mode (no --dart-define credentials)
  await NotificationService.init();
  AppState.onRemindersChanged = NotificationService.sync;
  runApp(const MaisonApp());
}

class MaisonApp extends StatelessWidget {
  const MaisonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maison',
      debugShowCheckedModeBanner: false,
      theme: maisonTheme(),
      home: const BootstrapScreen(),
    );
  }
}
