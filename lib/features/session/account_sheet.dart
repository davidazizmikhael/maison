import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
import '../../data/backend.dart';
import '../timeline/timeline_cubit.dart';
import 'bootstrap_screen.dart';
import 'session_cubit.dart';

/// Account state, Sign in with Apple linking, and account deletion.
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
  bool _deleting = false;

  Future<void> _deleteAccount() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAccountConfirm,
                style: TextStyle(color: dialogContext.mc.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      await context.read<SessionCubit>().deleteAccount();
      if (!mounted) return;
      context.read<TimelineCubit>().reset(); // also cancels scheduled notifications
      // Restart the whole flow: a fresh bootstrap signs in anew → onboarding.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BootstrapScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.deleteAccountDoneSnack)));
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.saveError('$e'))));
      }
    }
  }

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
            if (!linked && BackendConfig.enabled) ...[
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
            const SizedBox(height: 18),
            Container(height: 1, color: context.mc.line),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: _deleting
                  ? const Center(
                      child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5)))
                  : TextButton.icon(
                      onPressed: _deleteAccount,
                      style: TextButton.styleFrom(
                          foregroundColor: context.mc.red,
                          alignment: Alignment.centerLeft),
                      icon: const Icon(Icons.delete_forever_outlined, size: 20),
                      label: Text(context.l10n.deleteAccountAction,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
