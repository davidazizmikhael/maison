import 'package:flutter/material.dart';
import '../models.dart';
import '../services/backend.dart';
import '../theme.dart';
import 'home.dart';
import 'onboarding.dart';

/// Decides the first screen. Demo mode goes straight to onboarding; live mode
/// signs in and, if this user already has a home, loads it and skips to the
/// timeline.
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!BackendConfig.enabled) {
      _go(const OnboardingScreen());
      return;
    }
    try {
      final backend = Backend.instance;
      await backend.signInAnonymously();
      final home = await backend.existingHome();
      if (home == null) {
        _go(const OnboardingScreen());
        return;
      }
      final state = AppState.instance;
      state.homeId = home.id;
      state.address = home.address;
      state.profile = home.profile;
      final (records, reminders) = await backend.fetchAll(home.id);
      state.hydrate(newRecords: records, newReminders: reminders);
      _go(const HomeScreen());
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _go(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaisonColors.ink,
      body: Center(
        child: _error == null
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('M A I S O N',
                      style: TextStyle(
                          color: MaisonColors.accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 5)),
                  SizedBox(height: 28),
                  SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: MaisonColors.accent)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Couldn\'t reach your logbook',
                        style: TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Text(_error!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        setState(() => _error = null);
                        _start();
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
