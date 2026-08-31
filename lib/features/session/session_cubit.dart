import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/backend.dart';
import '../../data/models.dart';

/// Who is signed in and which home they own.
sealed class SessionState {
  const SessionState();
}

/// Startup: signing in / looking for an existing home.
class SessionLoading extends SessionState {
  const SessionLoading();
}

/// No home on record — run onboarding.
class SessionNeedsOnboarding extends SessionState {
  const SessionNeedsOnboarding();
}

/// Onboarding finished; the home row is being created on the backend.
class SessionCreatingHome extends SessionState {
  const SessionCreatingHome();
}

/// Signed in with a home. [homeId] is null in demo mode.
class SessionReady extends SessionState {
  const SessionReady({required this.homeId, required this.address, required this.profile});
  final String? homeId;
  final String address;
  final HomeProfile? profile;
}

class SessionError extends SessionState {
  const SessionError(this.message, {this.duringOnboarding = false});
  final String message;
  final bool duringOnboarding;
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._backend) : super(const SessionLoading());

  final Backend _backend;

  /// App launch: demo mode goes straight to onboarding; live mode signs in
  /// and restores the existing home if there is one.
  Future<void> start() async {
    emit(const SessionLoading());
    if (!BackendConfig.enabled) {
      emit(const SessionNeedsOnboarding());
      return;
    }
    try {
      await _backend.signInAnonymously();
      final home = await _backend.existingHome();
      if (home == null) {
        emit(const SessionNeedsOnboarding());
      } else {
        emit(SessionReady(homeId: home.id, address: home.address, profile: home.profile));
      }
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  /// Onboarding finish: persist the home in live mode, then become ready.
  Future<void> completeOnboarding({required String address, required HomeProfile profile}) async {
    String? homeId;
    if (BackendConfig.enabled) {
      emit(const SessionCreatingHome());
      try {
        await _backend.signInAnonymously();
        homeId = await _backend.upsertHome(address: address, profile: profile);
      } catch (e) {
        emit(SessionError(e.toString(), duringOnboarding: true));
        emit(const SessionNeedsOnboarding());
        return;
      }
    }
    emit(SessionReady(homeId: homeId, address: address, profile: profile));
  }
}
