import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
import '../../data/backend.dart';

/// Account state + Sign in with Apple linking (live mode only).
void showAccountSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: context.mc.paper,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (_) => const _AccountSheet(),
  );
}

class _AccountSheet extends StatefulWidget {
  const _AccountSheet();

  @override
  State<_AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends State<_AccountSheet> {
  bool _linking = false;

  Future<void> _link() async {
    setState(() => _linking = true);
    try {
      final linked = await Backend.instance.linkWithApple();
      if (!mounted) return;
      if (linked) {
        setState(() {}); // re-read account state
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.linkedSnack)));
      }
    } on SignInWithAppleAuthorizationException {
      // Entitlement missing (free team) or SiwA unavailable on this build.
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.appleUnavailable)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.saveError('$e'))));
      }
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = Backend.instance.account;
    final linked = !account.isAnonymous;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 ${context.l10n.accountTitle}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: linked ? context.mc.greenWash : context.mc.accentWash,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    linked
                        ? '✅ ${context.l10n.accountLinkedTitle}'
                        : '⚠️ ${context.l10n.accountAnonymousTitle}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: linked ? context.mc.green : context.mc.accentDeep),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    linked ? context.l10n.accountLinkedBody : context.l10n.accountAnonymousBody,
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: linked ? context.mc.green : context.mc.accentDeep),
                  ),
                  if (linked && account.email != null) ...[
                    const SizedBox(height: 8),
                    Text(account.email!,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.mc.green)),
                  ],
                ],
              ),
            ),
            if (!linked) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: _linking
                    ? const Center(
                        child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5)))
                    : SignInWithAppleButton(
                        text: context.l10n.linkWithApple,
                        height: 48,
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        onPressed: _link,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
