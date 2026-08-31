import 'package:flutter/material.dart';
import '../models.dart';
import '../services/backend.dart';
import '../theme.dart';
import 'home.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  final _addressController = TextEditingController(text: '214 Rue Clark, Montréal');
  final _placeController = TextEditingController(
      text: 'Duplex, 3 bedrooms, 1.5 bathrooms, garage, unfinished basement');
  int _page = 0;
  bool _creating = false;

  @override
  void dispose() {
    _controller.dispose();
    _addressController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < 3) {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
      return;
    }
    final state = AppState.instance;
    state.address = _addressController.text.trim().isEmpty
        ? '214 Rue Clark, Montréal'
        : _addressController.text.trim();
    // If the user skipped the "structure it" tap, parse their text silently.
    state.profile ??= HomeProfile.parse(_placeController.text);

    if (BackendConfig.enabled) {
      setState(() => _creating = true);
      try {
        final backend = Backend.instance;
        await backend.signInAnonymously();
        state.homeId = await backend.upsertHome(address: state.address, profile: state.profile);
      } catch (e) {
        if (!mounted) return;
        setState(() => _creating = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Couldn\'t create your home — check your connection. ($e)')));
        return;
      }
    } else {
      state.seedDemoData();
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaisonColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(),
                  _AddressPage(controller: _addressController),
                  _DescribePlacePage(controller: _placeController),
                  _HowItWorksPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page ? MaisonColors.accent : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _creating ? null : _next,
                      child: Text(_creating
                          ? 'Setting up your home…'
                          : (_page == 3 ? 'Start my home profile' : 'Continue')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('M A I S O N',
              style: TextStyle(color: MaisonColors.accent, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 4)),
          const SizedBox(height: 24),
          const Text('Snap it.\nMaison files it.\nForever.',
              style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, height: 1.15)),
          const SizedBox(height: 20),
          Text(
            'Every appliance, receipt, repair and warranty in your home — photographed once, organized for good.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 17, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _AddressPage extends StatelessWidget {
  const _AddressPage({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏠', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 16),
          const Text('Where\'s home?',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text('One logbook per home. You can add a condo, rental or chalet later.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 16, height: 1.5)),
          const SizedBox(height: 28),
          TextField(
            controller: controller,
            style: const TextStyle(color: MaisonColors.ink, fontSize: 17, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Street address',
              prefixIcon: const Icon(Icons.home_outlined, color: MaisonColors.accentDeep),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Describe your place like you'd tell a friend" — the AI structures the
/// sentence into a home profile (bedrooms, bathrooms, garage, basement).
class _DescribePlacePage extends StatefulWidget {
  const _DescribePlacePage({required this.controller});
  final TextEditingController controller;

  @override
  State<_DescribePlacePage> createState() => _DescribePlacePageState();
}

class _DescribePlacePageState extends State<_DescribePlacePage> {
  HomeProfile? _parsed;
  bool _thinking = false;

  Future<void> _structure() async {
    setState(() {
      _thinking = true;
      _parsed = null;
    });
    // Fake AI latency so the "structuring" moment reads on screen.
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final profile = HomeProfile.parse(widget.controller.text);
    AppState.instance.setProfile(profile);
    setState(() {
      _thinking = false;
      _parsed = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text('🛋️', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 16),
          const Text('Describe your place\nlike you\'d tell a friend.',
              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 10),
          Text('No steppers, no dropdowns. Maison turns your words into your home\'s profile — rooms, checklists, and reminders follow from it.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 15, height: 1.5)),
          const SizedBox(height: 24),
          TextField(
            controller: widget.controller,
            maxLines: 3,
            style: const TextStyle(color: MaisonColors.ink, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: MaisonColors.accent,
                side: const BorderSide(color: MaisonColors.accent, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _thinking ? null : _structure,
              icon: _thinking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: MaisonColors.accent))
                  : const Icon(Icons.auto_awesome, size: 19),
              label: Text(_thinking ? 'Structuring…' : 'Structure it',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
            ),
          ),
          if (_parsed != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MaisonColors.accent.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HERE\'S YOUR PLACE',
                      style: TextStyle(
                          color: MaisonColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _parsed!.chips
                        .map((c) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(c,
                                  style: const TextStyle(
                                      color: MaisonColors.ink,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Wrong? Just edit the sentence and structure it again. Maison keeps refining this as you log.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _HowItWorksPage extends StatelessWidget {
  Widget _step(String emoji, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(body,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 14.5, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Three ways to log.\nZero forms.',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 32),
          _step('📸', 'Snap a nameplate', 'AI reads the model & serial, finds the manual, and schedules its maintenance.'),
          _step('🧾', 'Snap a receipt', 'Price, store, warranty end date and return window — extracted and deadline-tracked.'),
          _step('⌨️', 'Type it like a note', '"Water heater replaced, \$1,850, Joe\'s Plumbing" becomes a structured record.'),
        ],
      ),
    );
  }
}
