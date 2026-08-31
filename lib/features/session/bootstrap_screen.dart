import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
import '../onboarding/onboarding_screen.dart';
import '../timeline/home_screen.dart';
import '../timeline/timeline_cubit.dart';
import 'session_cubit.dart';

/// First screen: kicks off the session and routes on the outcome.
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SessionCubit>().start());
  }

  Future<void> _onState(BuildContext context, SessionState state) async {
    switch (state) {
      case SessionNeedsOnboarding():
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      case SessionReady(:final homeId):
        if (homeId != null) {
          await context.read<TimelineCubit>().load(homeId);
        }
        if (context.mounted) {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      case _:
        break; // loading and error render below
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      listener: _onState,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: MaisonColors.ink,
          body: Center(
            child: state is SessionError
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.bootCantReach,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        Text(state.message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () => context.read<SessionCubit>().start(),
                          child: Text(context.l10n.bootTryAgain),
                        ),
                      ],
                    ),
                  )
                : const Column(
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
                  ),
          ),
        );
      },
    );
  }
}
